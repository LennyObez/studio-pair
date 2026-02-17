-- ============================================================================
-- Migration 024: Charter Amendments
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Adds formal amendment process for charters. Space members can propose
-- amendments that go through a voting process before being approved or
-- rejected. Each amendment has a voting window, and members cast a single
-- approve/reject vote per amendment.
-- ============================================================================

-- ==========================================================================
-- TABLE: charter_amendments
-- ==========================================================================
-- Represents a proposed change to the space charter. Amendments follow a
-- lifecycle: proposed -> voting -> approved/rejected.
-- ==========================================================================
CREATE TABLE charter_amendments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    charter_id      UUID        NOT NULL REFERENCES charters(id) ON DELETE CASCADE,
    space_id        UUID        NOT NULL REFERENCES spaces(id)   ON DELETE CASCADE,
    proposed_by     UUID        NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    title           TEXT        NOT NULL,
    content         TEXT        NOT NULL,
    status          TEXT        NOT NULL DEFAULT 'proposed',

    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    voting_ends_at  TIMESTAMPTZ,
    resolved_at     TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT ca_title_not_empty   CHECK (length(trim(title)) > 0),
    CONSTRAINT ca_content_not_empty CHECK (length(trim(content)) > 0),
    CONSTRAINT ca_status_valid      CHECK (status IN ('proposed', 'voting', 'approved', 'rejected'))
);

-- Index: amendments by charter
CREATE INDEX idx_charter_amendments_charter
    ON charter_amendments (charter_id, created_at DESC);

-- Index: amendments by space
CREATE INDEX idx_charter_amendments_space
    ON charter_amendments (space_id, status, created_at DESC);

-- Index: amendments by proposer
CREATE INDEX idx_charter_amendments_proposer
    ON charter_amendments (proposed_by, created_at DESC);

COMMENT ON TABLE charter_amendments IS 'Proposed amendments to the space charter with voting lifecycle.';

-- ==========================================================================
-- TABLE: charter_amendment_votes
-- ==========================================================================
-- Records each member''s vote on a charter amendment. One vote per user
-- per amendment (enforced by unique constraint).
-- ==========================================================================
CREATE TABLE charter_amendment_votes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amendment_id    UUID        NOT NULL REFERENCES charter_amendments(id) ON DELETE CASCADE,
    user_id         UUID        NOT NULL REFERENCES users(id)             ON DELETE CASCADE,
    vote            TEXT        NOT NULL,

    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT cav_vote_valid CHECK (vote IN ('approve', 'reject')),
    CONSTRAINT cav_unique_vote UNIQUE (amendment_id, user_id)
);

-- Index: votes by amendment
CREATE INDEX idx_cav_amendment
    ON charter_amendment_votes (amendment_id, created_at ASC);

-- Index: votes by user
CREATE INDEX idx_cav_user
    ON charter_amendment_votes (user_id, created_at DESC);

COMMENT ON TABLE charter_amendment_votes IS 'Individual votes on charter amendments (one per user per amendment).';
