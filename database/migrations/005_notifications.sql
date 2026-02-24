-- ============================================================================
-- Migration 005: Notifications and Notification Preferences
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Unified notification system supporting in-app, push, and email channels.
-- Per-user preferences with quiet hours and per-module/channel control.
-- ============================================================================

-- ==========================================================================
-- ENUM: notification_channel
-- ==========================================================================
CREATE TYPE notification_channel AS ENUM (
    'in_app',
    'push',
    'email'
);

-- ==========================================================================
-- TABLE: notifications
-- ==========================================================================
-- Individual notification records. source_module and source_entity_id
-- link back to the originating feature (e.g., 'calendar', event UUID).
-- metadata stores channel-specific or module-specific payload data.
-- ==========================================================================
CREATE TABLE notifications (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID                NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    space_id            UUID                REFERENCES spaces(id) ON DELETE CASCADE,
    type                VARCHAR(100)        NOT NULL,
    title               VARCHAR(255)        NOT NULL,
    body                TEXT,
    source_module       VARCHAR(50),
    source_entity_id    UUID,
    channel             notification_channel NOT NULL DEFAULT 'in_app',
    is_read             BOOLEAN             NOT NULL DEFAULT FALSE,
    read_at             TIMESTAMPTZ,
    metadata            JSONB,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT notif_read_consistency CHECK (
        (is_read = FALSE AND read_at IS NULL)
        OR (is_read = TRUE AND read_at IS NOT NULL)
    )
);

-- Primary query pattern: unread notifications for a user, newest first
CREATE INDEX idx_notifications_user_read_created
    ON notifications (user_id, is_read, created_at DESC);

-- Filter notifications by space
CREATE INDEX idx_notifications_space_id
    ON notifications (space_id)
    WHERE space_id IS NOT NULL;

-- Lookup by source entity (e.g., find all notifications for a specific event)
CREATE INDEX idx_notifications_source
    ON notifications (source_module, source_entity_id)
    WHERE source_module IS NOT NULL;

COMMENT ON TABLE notifications IS 'Unified notification records across all channels and modules.';

-- ==========================================================================
-- TABLE: notification_preferences
-- ==========================================================================
-- Per-user (and optionally per-space) notification preferences. Controls
-- which modules and channels are enabled, plus quiet-hours scheduling.
-- ==========================================================================
CREATE TABLE notification_preferences (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    space_id            UUID        REFERENCES spaces(id) ON DELETE CASCADE,
    module              VARCHAR(50) NOT NULL,       -- e.g., 'calendar', 'messaging', 'tasks'
    channel             VARCHAR(20) NOT NULL,       -- e.g., 'in_app', 'push', 'email'
    enabled             BOOLEAN     NOT NULL DEFAULT TRUE,
    quiet_hours_start   TIME,
    quiet_hours_end     TIME,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT np_quiet_hours_both_or_neither CHECK (
        (quiet_hours_start IS NULL AND quiet_hours_end IS NULL)
        OR (quiet_hours_start IS NOT NULL AND quiet_hours_end IS NOT NULL)
    )
);

-- Unique preference per user + space + module + channel
CREATE UNIQUE INDEX idx_np_user_space_module_channel
    ON notification_preferences (user_id, COALESCE(space_id, '00000000-0000-0000-0000-000000000000'), module, channel);

-- Look up all preferences for a user
CREATE INDEX idx_np_user_id
    ON notification_preferences (user_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_notification_preferences_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE notification_preferences IS 'Per-user, per-module notification channel preferences with quiet hours.';
