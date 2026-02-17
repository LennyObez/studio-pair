-- ============================================================================
-- Migration 019: Polls, Options, and Votes
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Decision-making polls with single-choice, multiple-choice, and
-- ranked-choice voting. Supports anonymous voting, deadlines, and
-- image options.
-- ============================================================================

-- ==========================================================================
-- ENUM: poll_type
-- ==========================================================================
CREATE TYPE poll_type AS ENUM (
    'single_choice',
    'multiple_choice',
    'ranked_choice'
);

-- ==========================================================================
-- TABLE: polls
-- ==========================================================================
-- A poll / question posed to the space. Can be anonymous, have a deadline,
-- and be manually closed.
-- ==========================================================================
CREATE TABLE polls (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id    UUID      NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by  UUID      NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    question    TEXT      NOT NULL,
    poll_type   poll_type NOT NULL DEFAULT 'single_choice',
    is_anonymous BOOLEAN  NOT NULL DEFAULT FALSE,
    deadline    TIMESTAMPTZ,
    is_closed   BOOLEAN   NOT NULL DEFAULT FALSE,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT polls_question_not_empty CHECK (length(trim(question)) > 0)
);

-- List polls for a space
CREATE INDEX idx_polls_space
    ON polls (space_id, created_at DESC);

-- Active (open) polls
CREATE INDEX idx_polls_space_open
    ON polls (space_id, deadline)
    WHERE is_closed = FALSE;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_polls_updated_at
    BEFORE UPDATE ON polls
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE polls IS 'Decision-making polls with multiple voting modes and optional anonymity.';

-- ==========================================================================
-- TABLE: poll_options
-- ==========================================================================
-- Selectable options within a poll. Can include images and are ordered
-- by display_order.
-- ==========================================================================
CREATE TABLE poll_options (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    poll_id         UUID         NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    label           VARCHAR(500) NOT NULL,
    image_url       TEXT,
    display_order   INT          NOT NULL DEFAULT 0,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT po_label_not_empty CHECK (length(trim(label)) > 0)
);

-- List options for a poll in order
CREATE INDEX idx_po_poll_order
    ON poll_options (poll_id, display_order);

COMMENT ON TABLE poll_options IS 'Selectable options within a poll.';

-- ==========================================================================
-- TABLE: poll_votes
-- ==========================================================================
-- User votes on poll options. For ranked-choice, the rank column indicates
-- preference order (1 = top choice). For single/multiple choice, rank is
-- NULL.
-- ==========================================================================
CREATE TABLE poll_votes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    poll_option_id  UUID NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id)        ON DELETE CASCADE,
    rank            INT,    -- used for ranked_choice only

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT pv_rank_positive CHECK (rank IS NULL OR rank >= 1)
);

-- One vote per user per option
CREATE UNIQUE INDEX idx_pv_option_user
    ON poll_votes (poll_option_id, user_id);

-- Find all votes by a user (for validation in single_choice)
CREATE INDEX idx_pv_user
    ON poll_votes (user_id);

COMMENT ON TABLE poll_votes IS 'User votes on poll options with optional ranking for ranked-choice.';
