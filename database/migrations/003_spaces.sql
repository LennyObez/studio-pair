-- ============================================================================
-- Migration 003: Spaces and Space Memberships
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Spaces are the core multi-tenant unit. Every shared resource (activities,
-- calendars, finances, etc.) belongs to a space. Supports multiple
-- relationship types and role-based access.
-- ============================================================================

-- ==========================================================================
-- ENUM: space_type
-- ==========================================================================
CREATE TYPE space_type AS ENUM (
    'couple',
    'family',
    'polyamorous',
    'friends',
    'roommates',
    'colleagues'
);

-- ==========================================================================
-- ENUM: membership_role
-- ==========================================================================
CREATE TYPE membership_role AS ENUM (
    'owner',
    'admin',
    'member'
);

-- ==========================================================================
-- ENUM: access_level
-- ==========================================================================
CREATE TYPE access_level AS ENUM (
    'read_only',
    'read_write'
);

-- ==========================================================================
-- ENUM: membership_status
-- ==========================================================================
CREATE TYPE membership_status AS ENUM (
    'active',
    'invited',
    'left',
    'removed'
);

-- ==========================================================================
-- TABLE: spaces
-- ==========================================================================
-- A shared space where members collaborate. Each space has a unique invite
-- code for onboarding new members. Soft-deletable with optional scheduled
-- deletion for grace-period workflows.
-- ==========================================================================
CREATE TABLE spaces (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                    VARCHAR(100) NOT NULL,
    type                    space_type   NOT NULL,
    avatar_url              TEXT,
    invite_code             VARCHAR(20)  NOT NULL UNIQUE DEFAULT generate_invite_code(),
    max_members             INT          NOT NULL DEFAULT 2,

    -- Timestamps
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    deletion_scheduled_at   TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT spaces_max_members_positive CHECK (max_members >= 2),
    CONSTRAINT spaces_name_not_empty       CHECK (length(trim(name)) > 0)
);

-- Active (non-deleted) spaces
CREATE INDEX idx_spaces_active
    ON spaces (created_at)
    WHERE deleted_at IS NULL;

-- Look up space by invite code (only active spaces)
CREATE INDEX idx_spaces_invite_code
    ON spaces (invite_code)
    WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_spaces_updated_at
    BEFORE UPDATE ON spaces
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE spaces IS 'Shared space for a group of users (couple, family, friends, etc.).';

-- ==========================================================================
-- TABLE: space_memberships
-- ==========================================================================
-- Junction table linking users to spaces with role and status tracking.
-- A user can only have one active/invited membership per space (enforced
-- by partial unique index).
-- ==========================================================================
CREATE TABLE space_memberships (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id    UUID              NOT NULL REFERENCES spaces(id)  ON DELETE CASCADE,
    user_id     UUID              NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
    role        membership_role   NOT NULL DEFAULT 'member',
    access_level access_level    NOT NULL DEFAULT 'read_write',
    status      membership_status NOT NULL DEFAULT 'invited',
    invited_by  UUID              REFERENCES users(id) ON DELETE SET NULL,
    joined_at   TIMESTAMPTZ,
    left_at     TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT sm_joined_after_created CHECK (joined_at IS NULL OR joined_at >= created_at)
);

-- A user can only have one non-'left' membership per space
CREATE UNIQUE INDEX idx_sm_space_user_active
    ON space_memberships (space_id, user_id)
    WHERE status NOT IN ('left', 'removed');

-- Look up all memberships for a user
CREATE INDEX idx_sm_user_id
    ON space_memberships (user_id);

-- Look up all members of a space
CREATE INDEX idx_sm_space_id
    ON space_memberships (space_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_space_memberships_updated_at
    BEFORE UPDATE ON space_memberships
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE space_memberships IS 'Tracks user membership, role, and status within a space.';
