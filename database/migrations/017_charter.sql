-- ============================================================================
-- Migration 017: Charter (Relationship Agreement / Space Constitution)
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Each space has one charter (relationship agreement / house rules).
-- Charters are versioned - every edit creates a new version. Members
-- must acknowledge each new version to confirm they have read it.
-- ============================================================================

-- ==========================================================================
-- TABLE: charters
-- ==========================================================================
-- One charter per space. current_version tracks the latest version number.
-- ==========================================================================
CREATE TABLE charters (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id        UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    current_version INT  NOT NULL DEFAULT 1,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT charters_version_positive CHECK (current_version >= 1)
);

-- One charter per space
CREATE UNIQUE INDEX idx_charters_space
    ON charters (space_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_charters_updated_at
    BEFORE UPDATE ON charters
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE charters IS 'Space charter (relationship agreement) - one per space.';

-- ==========================================================================
-- TABLE: charter_versions
-- ==========================================================================
-- Immutable version history of the charter. Each edit creates a new row
-- with an incremented version_number. content stores the full charter text
-- for that version. change_summary explains what was modified.
-- ==========================================================================
CREATE TABLE charter_versions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    charter_id      UUID NOT NULL REFERENCES charters(id) ON DELETE CASCADE,
    version_number  INT  NOT NULL,
    content         TEXT NOT NULL,
    edited_by       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    change_summary  TEXT,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT cv_version_positive  CHECK (version_number >= 1),
    CONSTRAINT cv_content_not_empty CHECK (length(trim(content)) > 0)
);

-- Unique version number per charter
CREATE UNIQUE INDEX idx_cv_charter_version
    ON charter_versions (charter_id, version_number);

-- List versions for a charter in order
CREATE INDEX idx_cv_charter_created
    ON charter_versions (charter_id, version_number DESC);

COMMENT ON TABLE charter_versions IS 'Immutable version history of the space charter.';

-- ==========================================================================
-- TABLE: charter_acknowledgments
-- ==========================================================================
-- Tracks which users have acknowledged (read and accepted) each charter
-- version. Used to prompt users to review new versions.
-- ==========================================================================
CREATE TABLE charter_acknowledgments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    charter_version_id  UUID        NOT NULL REFERENCES charter_versions(id) ON DELETE CASCADE,
    user_id             UUID        NOT NULL REFERENCES users(id)            ON DELETE CASCADE,
    acknowledged_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One acknowledgment per user per version
CREATE UNIQUE INDEX idx_ca_version_user
    ON charter_acknowledgments (charter_version_id, user_id);

COMMENT ON TABLE charter_acknowledgments IS 'User acknowledgments of charter versions.';
