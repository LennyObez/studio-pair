-- ============================================================================
-- Migration 023: AI Usage Log
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Tracks AI credit consumption per space for entitlement enforcement.
-- ============================================================================

CREATE TABLE IF NOT EXISTS ai_usage_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id        UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    feature         VARCHAR(100) NOT NULL,
    model           VARCHAR(100),
    credits_used    INTEGER NOT NULL DEFAULT 1,
    input_tokens    INTEGER,
    output_tokens   INTEGER,
    metadata        JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_usage_log_space_month
    ON ai_usage_log (space_id, created_at);

CREATE INDEX idx_ai_usage_log_user
    ON ai_usage_log (user_id, created_at);

COMMENT ON TABLE ai_usage_log IS 'Tracks AI credit consumption per space for entitlement enforcement';
