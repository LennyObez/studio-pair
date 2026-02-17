-- ============================================================================
-- Migration 022: Full-Text Search Indexes, Composite Indexes, and Optimizations
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Adds tsvector columns and GIN indexes for full-text search across key
-- tables (activities, files). Creates trigram GIN indexes for fuzzy text
-- matching. Adds composite and partial indexes to optimize common query
-- patterns across all modules.
-- ============================================================================

-- ==========================================================================
-- FULL-TEXT SEARCH: Activities
-- ==========================================================================

-- Add tsvector column for pre-computed search vector
ALTER TABLE activities
    ADD COLUMN search_vector TSVECTOR;

-- Populate the search vector from title and description
-- Title is weighted higher (A) than description (B)
CREATE OR REPLACE FUNCTION activities_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_activities_search_vector
    BEFORE INSERT OR UPDATE OF title, description ON activities
    FOR EACH ROW
    EXECUTE FUNCTION activities_search_vector_update();

-- GIN index for full-text search on activities
CREATE INDEX idx_activities_search
    ON activities USING GIN (search_vector)
    WHERE deleted_at IS NULL;

-- Trigram index for fuzzy matching on activity title
CREATE INDEX idx_activities_title_trgm
    ON activities USING GIN (title gin_trgm_ops)
    WHERE deleted_at IS NULL;

-- ==========================================================================
-- FULL-TEXT SEARCH: Files
-- ==========================================================================

-- Add tsvector column for file name search
ALTER TABLE files
    ADD COLUMN search_vector TSVECTOR;

-- Populate the search vector from filename
CREATE OR REPLACE FUNCTION files_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        to_tsvector('simple', COALESCE(NEW.filename, ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_files_search_vector
    BEFORE INSERT OR UPDATE OF filename ON files
    FOR EACH ROW
    EXECUTE FUNCTION files_search_vector_update();

-- GIN index for full-text search on files
CREATE INDEX idx_files_search
    ON files USING GIN (search_vector)
    WHERE deleted_at IS NULL;

-- Trigram index for fuzzy matching on filename
CREATE INDEX idx_files_filename_trgm
    ON files USING GIN (filename gin_trgm_ops)
    WHERE deleted_at IS NULL;

-- ==========================================================================
-- FULL-TEXT SEARCH: Messages
-- ==========================================================================
-- NOTE: Messages are E2E encrypted, so full-text search on encrypted
-- content is not possible server-side. Instead, we create a trigram
-- index on the content_type for filtering, and application-level
-- search should be done client-side after decryption.
--
-- If a search index on plaintext content is needed in the future
-- (e.g., for server-assisted search with user consent), add a
-- search_content_plaintext column here.
-- ==========================================================================

-- Index for filtering messages by content type
CREATE INDEX idx_messages_content_type
    ON messages (conversation_id, content_type, created_at DESC)
    WHERE deleted_at IS NULL;

-- ==========================================================================
-- FULL-TEXT SEARCH: Memories
-- ==========================================================================

-- Add tsvector column for memory search
ALTER TABLE memories
    ADD COLUMN search_vector TSVECTOR;

-- Populate from title, description, and location
CREATE OR REPLACE FUNCTION memories_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('simple', COALESCE(NEW.location, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_memories_search_vector
    BEFORE INSERT OR UPDATE OF title, description, location ON memories
    FOR EACH ROW
    EXECUTE FUNCTION memories_search_vector_update();

-- GIN index for full-text search on memories
CREATE INDEX idx_memories_search
    ON memories USING GIN (search_vector)
    WHERE deleted_at IS NULL;

-- ==========================================================================
-- FULL-TEXT SEARCH: Tasks
-- ==========================================================================

-- Add tsvector column for task search
ALTER TABLE tasks
    ADD COLUMN search_vector TSVECTOR;

-- Populate from title and description
CREATE OR REPLACE FUNCTION tasks_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tasks_search_vector
    BEFORE INSERT OR UPDATE OF title, description ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION tasks_search_vector_update();

-- GIN index for full-text search on tasks
CREATE INDEX idx_tasks_search
    ON tasks USING GIN (search_vector)
    WHERE deleted_at IS NULL;

-- ==========================================================================
-- FULL-TEXT SEARCH: Vault Entries (label and domain only, not encrypted blob)
-- ==========================================================================

-- Trigram index for fuzzy search on vault entry labels
CREATE INDEX idx_ve_label_trgm
    ON vault_entries USING GIN (label gin_trgm_ops)
    WHERE deleted_at IS NULL;

-- Trigram index for fuzzy search on vault entry domains
CREATE INDEX idx_ve_domain_trgm
    ON vault_entries USING GIN (domain gin_trgm_ops)
    WHERE domain IS NOT NULL AND deleted_at IS NULL;

-- ==========================================================================
-- COMPOSITE INDEXES: Common Query Optimizations
-- ==========================================================================

-- Users: look up by display_name (for mentions, search)
CREATE INDEX idx_users_display_name_trgm
    ON users USING GIN (display_name gin_trgm_ops)
    WHERE deleted_at IS NULL;

-- Space memberships: active members of a space with role
CREATE INDEX idx_sm_space_role_active
    ON space_memberships (space_id, role)
    WHERE status = 'active';

-- Calendar events: upcoming events for a space
CREATE INDEX idx_ce_space_upcoming
    ON calendar_events (space_id, start_at)
    WHERE deleted_at IS NULL AND start_at >= NOW();

-- Finance entries: monthly aggregation
CREATE INDEX idx_fe_space_month
    ON finance_entries (space_id, date, entry_type)
    WHERE deleted_at IS NULL;

-- Tasks: overdue tasks
CREATE INDEX idx_tasks_overdue
    ON tasks (space_id, due_date)
    WHERE deleted_at IS NULL AND status != 'done' AND due_date < CURRENT_DATE;

-- Conversations: recent conversations for a user (via participants)
CREATE INDEX idx_cp_user_joined
    ON conversation_participants (user_id, joined_at DESC)
    WHERE left_at IS NULL;

-- Grocery items: category grouping within a list
CREATE INDEX idx_gi_list_category
    ON grocery_items (list_id, category, display_order);

-- Polls: active polls with deadline
CREATE INDEX idx_polls_active_deadline
    ON polls (space_id, deadline)
    WHERE is_closed = FALSE AND deadline IS NOT NULL;

-- ==========================================================================
-- PARTIAL INDEXES: Soft-Delete Optimization
-- ==========================================================================
-- These partial indexes ensure queries on active (non-deleted) records
-- remain fast even as soft-deleted records accumulate.
-- (Many were already created in individual migration files above;
-- these are additional ones for commonly queried patterns.)

-- Cards: active cards for listing
CREATE INDEX idx_cards_space_active
    ON cards (space_id, card_type, created_at DESC)
    WHERE deleted_at IS NULL;

-- Vault entries: active entries for a space
CREATE INDEX idx_ve_space_active
    ON vault_entries (space_id, created_at DESC)
    WHERE deleted_at IS NULL;

-- Finance entries: unsettled expenses (for balance dashboard)
CREATE INDEX idx_fe_unsettled_expenses
    ON finance_entries (space_id, date DESC)
    WHERE deleted_at IS NULL AND entry_type = 'expense';

-- ==========================================================================
-- JSONB INDEXES
-- ==========================================================================
-- GIN indexes on JSONB metadata columns for flexible querying

-- Activities metadata (e.g., filtering by genre, platform, etc.)
CREATE INDEX idx_activities_metadata
    ON activities USING GIN (metadata jsonb_path_ops)
    WHERE metadata IS NOT NULL AND deleted_at IS NULL;

-- Calendar events metadata
CREATE INDEX idx_ce_metadata
    ON calendar_events USING GIN (metadata jsonb_path_ops)
    WHERE metadata IS NOT NULL AND deleted_at IS NULL;

-- Notifications metadata (e.g., deep-link targets, action buttons)
CREATE INDEX idx_notifications_metadata
    ON notifications USING GIN (metadata jsonb_path_ops)
    WHERE metadata IS NOT NULL;

-- Audit logs metadata (e.g., searching for specific changed fields)
CREATE INDEX idx_al_metadata
    ON audit_logs USING GIN (metadata jsonb_path_ops)
    WHERE metadata IS NOT NULL;
