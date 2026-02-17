-- ============================================================================
-- Migration 014: Reminders
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Time-based reminders that can be linked to any module entity.
-- Supports recurrence, snoozing, and cross-module linking.
-- ============================================================================

-- ==========================================================================
-- TABLE: reminders
-- ==========================================================================
-- A reminder triggers at a specific time and can be snoozed. Supports
-- recurrence via RRULE and linking to any module entity (e.g., a task,
-- calendar event, finance entry).
-- ==========================================================================
CREATE TABLE reminders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id        UUID        NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by      UUID        NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    message         TEXT        NOT NULL,
    trigger_at      TIMESTAMPTZ NOT NULL,
    recurrence_rule TEXT,       -- RFC 5545 RRULE for recurring reminders

    -- Cross-module linking
    linked_module       VARCHAR(50),
    linked_entity_id    UUID,

    -- Delivery tracking
    is_sent         BOOLEAN     NOT NULL DEFAULT FALSE,
    sent_at         TIMESTAMPTZ,
    snoozed_until   TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT rem_message_not_empty CHECK (length(trim(message)) > 0),
    CONSTRAINT rem_sent_consistency  CHECK (
        (is_sent = FALSE AND sent_at IS NULL)
        OR (is_sent = TRUE AND sent_at IS NOT NULL)
    )
);

-- Find pending reminders that need to fire
CREATE INDEX idx_reminders_pending
    ON reminders (trigger_at)
    WHERE deleted_at IS NULL AND is_sent = FALSE;

-- Snoozed reminders that need to re-fire
CREATE INDEX idx_reminders_snoozed
    ON reminders (snoozed_until)
    WHERE deleted_at IS NULL AND snoozed_until IS NOT NULL AND is_sent = FALSE;

-- List reminders for a space
CREATE INDEX idx_reminders_space
    ON reminders (space_id, trigger_at)
    WHERE deleted_at IS NULL;

-- List reminders by creator
CREATE INDEX idx_reminders_created_by
    ON reminders (created_by)
    WHERE deleted_at IS NULL;

-- Cross-module lookup
CREATE INDEX idx_reminders_linked
    ON reminders (linked_module, linked_entity_id)
    WHERE linked_module IS NOT NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_reminders_updated_at
    BEFORE UPDATE ON reminders
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE reminders IS 'Time-based reminders with recurrence, snooze, and cross-module linking.';
