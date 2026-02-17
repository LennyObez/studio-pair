-- ============================================================================
-- Migration 016: Memories, Media, Participants, Comments, and Reactions
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Shared memory/photo album system. Memories capture events, milestones,
-- and moments with media attachments, participant tagging, comments,
-- and emoji reactions.
-- ============================================================================

-- ==========================================================================
-- TABLE: memories
-- ==========================================================================
-- A shared memory/event record. Can be geotagged, linked to activities,
-- and marked as milestones (anniversary, first trip, etc.).
-- ==========================================================================
CREATE TABLE memories (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id            UUID         NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by          UUID         NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    title               VARCHAR(255) NOT NULL,
    date                DATE         NOT NULL,
    location            VARCHAR(500),
    location_lat        DECIMAL(10,7),
    location_lng        DECIMAL(10,7),
    description         TEXT,

    -- Activity link
    linked_activity_id  UUID REFERENCES activities(id) ON DELETE SET NULL,

    -- Milestone
    is_milestone        BOOLEAN     NOT NULL DEFAULT FALSE,
    milestone_type      VARCHAR(100),   -- e.g., 'anniversary', 'first_trip', 'birthday'

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT mem_title_not_empty CHECK (length(trim(title)) > 0),
    CONSTRAINT mem_lat_range       CHECK (location_lat IS NULL OR (location_lat >= -90 AND location_lat <= 90)),
    CONSTRAINT mem_lng_range       CHECK (location_lng IS NULL OR (location_lng >= -180 AND location_lng <= 180)),
    CONSTRAINT mem_coords_both_or_neither CHECK (
        (location_lat IS NULL AND location_lng IS NULL)
        OR (location_lat IS NOT NULL AND location_lng IS NOT NULL)
    ),
    CONSTRAINT mem_milestone_consistency CHECK (
        (is_milestone = FALSE AND milestone_type IS NULL)
        OR (is_milestone = TRUE AND milestone_type IS NOT NULL)
    )
);

-- List memories for a space by date
CREATE INDEX idx_memories_space_date
    ON memories (space_id, date DESC)
    WHERE deleted_at IS NULL;

-- Milestones for a space
CREATE INDEX idx_memories_milestones
    ON memories (space_id, date)
    WHERE is_milestone = TRUE AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_memories_updated_at
    BEFORE UPDATE ON memories
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE memories IS 'Shared memories with geolocation, milestones, and activity linking.';

-- ==========================================================================
-- TABLE: memory_media
-- ==========================================================================
-- Media attachments for a memory. References files from the files table.
-- One media item can be the cover image, and items can be marked private.
-- ==========================================================================
CREATE TABLE memory_media (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_id       UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    file_id         UUID NOT NULL REFERENCES files(id)    ON DELETE CASCADE,
    caption         TEXT,
    is_cover        BOOLEAN NOT NULL DEFAULT FALSE,
    is_private      BOOLEAN NOT NULL DEFAULT FALSE,
    display_order   INT     NOT NULL DEFAULT 0,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- List media for a memory in order
CREATE INDEX idx_mm_memory_order
    ON memory_media (memory_id, display_order);

COMMENT ON TABLE memory_media IS 'Media attachments for memories with ordering and privacy controls.';

-- ==========================================================================
-- TABLE: memory_participants
-- ==========================================================================
-- Tags which space members were part of a memory.
-- Composite primary key.
-- ==========================================================================
CREATE TABLE memory_participants (
    memory_id   UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id)    ON DELETE CASCADE,

    PRIMARY KEY (memory_id, user_id)
);

COMMENT ON TABLE memory_participants IS 'Participants tagged in a memory.';

-- ==========================================================================
-- TABLE: memory_comments
-- ==========================================================================
-- User comments on memories. Soft-deletable.
-- ==========================================================================
CREATE TABLE memory_comments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_id   UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    content     TEXT NOT NULL,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT mc_content_not_empty CHECK (length(trim(content)) > 0)
);

-- List comments for a memory
CREATE INDEX idx_mc_memory
    ON memory_comments (memory_id, created_at)
    WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_memory_comments_updated_at
    BEFORE UPDATE ON memory_comments
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE memory_comments IS 'User comments on shared memories.';

-- ==========================================================================
-- TABLE: memory_reactions
-- ==========================================================================
-- Emoji reactions on memories. One reaction per user per memory.
-- ==========================================================================
CREATE TABLE memory_reactions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_id   UUID        NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    user_id     UUID        NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    emoji       VARCHAR(20) NOT NULL,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT mr_emoji_not_empty CHECK (length(trim(emoji)) > 0)
);

-- One reaction per user per memory
CREATE UNIQUE INDEX idx_mr_memory_user
    ON memory_reactions (memory_id, user_id);

COMMENT ON TABLE memory_reactions IS 'Emoji reactions on shared memories (one per user per memory).';
