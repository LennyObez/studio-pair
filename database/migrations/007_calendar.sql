-- ============================================================================
-- Migration 007: Calendar Events, Alerts, Invitations, and Sync
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Unified calendar supporting personal and space events, recurring events
-- via RFC 5545 RRULE, external calendar sync (Google, iCloud, Microsoft),
-- and per-event alerts and invitations.
-- ============================================================================

-- ==========================================================================
-- ENUM: calendar_event_type
-- ==========================================================================
CREATE TYPE calendar_event_type AS ENUM (
    'personal',
    'space',
    'holiday',
    'finance',
    'task',
    'activity'
);

-- ==========================================================================
-- ENUM: invitation_status
-- ==========================================================================
CREATE TYPE invitation_status AS ENUM (
    'pending',
    'accepted',
    'declined',
    'tentative'
);

-- ==========================================================================
-- ENUM: calendar_provider
-- ==========================================================================
CREATE TYPE calendar_provider AS ENUM (
    'google',
    'icloud',
    'microsoft'
);

-- ==========================================================================
-- ENUM: sync_direction
-- ==========================================================================
CREATE TYPE sync_direction AS ENUM (
    'bidirectional',
    'import_only',
    'export_only'
);

-- ==========================================================================
-- ENUM: sync_status
-- ==========================================================================
CREATE TYPE sync_status AS ENUM (
    'active',
    'paused',
    'error'
);

-- ==========================================================================
-- TABLE: calendar_events
-- ==========================================================================
-- Unified calendar event. Supports all-day events, recurrence via RRULE,
-- and cross-module linking (source_module + source_entity_id point back
-- to the originating feature). Soft-deletable.
-- ==========================================================================
CREATE TABLE calendar_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id        UUID                NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by      UUID                NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    title           VARCHAR(255)        NOT NULL,
    location        VARCHAR(500),
    event_type      calendar_event_type NOT NULL DEFAULT 'space',
    all_day         BOOLEAN             NOT NULL DEFAULT FALSE,
    start_at        TIMESTAMPTZ         NOT NULL,
    end_at          TIMESTAMPTZ         NOT NULL,
    recurrence_rule TEXT,               -- RFC 5545 RRULE string

    -- Cross-module linking
    source_module       VARCHAR(50),
    source_entity_id    UUID,

    -- Flexible metadata
    metadata        JSONB,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT ce_end_after_start   CHECK (end_at >= start_at),
    CONSTRAINT ce_title_not_empty   CHECK (length(trim(title)) > 0)
);

-- List events for a space in a date range
CREATE INDEX idx_ce_space_time
    ON calendar_events (space_id, start_at, end_at)
    WHERE deleted_at IS NULL;

-- Events by creator
CREATE INDEX idx_ce_created_by
    ON calendar_events (created_by);

-- Cross-module lookup
CREATE INDEX idx_ce_source
    ON calendar_events (source_module, source_entity_id)
    WHERE source_module IS NOT NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_calendar_events_updated_at
    BEFORE UPDATE ON calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE calendar_events IS 'Unified calendar events with recurrence, cross-module linking, and soft delete.';

-- ==========================================================================
-- TABLE: calendar_event_alerts
-- ==========================================================================
-- Reminder alerts before an event. Multiple alerts can be set per event
-- (e.g., 15 min before and 1 day before).
-- ==========================================================================
CREATE TABLE calendar_event_alerts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id        UUID NOT NULL REFERENCES calendar_events(id) ON DELETE CASCADE,
    minutes_before  INT  NOT NULL,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT cea_minutes_positive CHECK (minutes_before > 0)
);

-- Look up alerts for an event
CREATE INDEX idx_cea_event_id
    ON calendar_event_alerts (event_id);

COMMENT ON TABLE calendar_event_alerts IS 'Per-event reminder alerts (minutes before).';

-- ==========================================================================
-- TABLE: calendar_invitations
-- ==========================================================================
-- Tracks RSVP status for space members invited to a calendar event.
-- ==========================================================================
CREATE TABLE calendar_invitations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id        UUID              NOT NULL REFERENCES calendar_events(id) ON DELETE CASCADE,
    user_id         UUID              NOT NULL REFERENCES users(id)           ON DELETE CASCADE,
    status          invitation_status NOT NULL DEFAULT 'pending',
    responded_at    TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One invitation per user per event
CREATE UNIQUE INDEX idx_ci_event_user
    ON calendar_invitations (event_id, user_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_calendar_invitations_updated_at
    BEFORE UPDATE ON calendar_invitations
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE calendar_invitations IS 'RSVP tracking for calendar event invitations.';

-- ==========================================================================
-- TABLE: calendar_sync_connections
-- ==========================================================================
-- External calendar provider connections (Google, iCloud, Microsoft).
-- Credentials are stored encrypted. Sync can be bidirectional or one-way.
-- ==========================================================================
CREATE TABLE calendar_sync_connections (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id                UUID              NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    user_id                 UUID              NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    provider                calendar_provider NOT NULL,
    credentials_encrypted   TEXT              NOT NULL,
    sync_direction          sync_direction    NOT NULL DEFAULT 'import_only',
    last_synced_at          TIMESTAMPTZ,
    status                  sync_status       NOT NULL DEFAULT 'active',
    error_message           TEXT,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Connections per user per space
CREATE INDEX idx_csc_space_user
    ON calendar_sync_connections (space_id, user_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_calendar_sync_connections_updated_at
    BEFORE UPDATE ON calendar_sync_connections
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE calendar_sync_connections IS 'External calendar provider connections with encrypted credentials.';

-- ==========================================================================
-- TABLE: calendar_sync_event_map
-- ==========================================================================
-- Maps internal calendar events to their external counterparts for
-- bidirectional sync. sync_hash is used for conflict detection.
-- ==========================================================================
CREATE TABLE calendar_sync_event_map (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    internal_event_id   UUID         NOT NULL REFERENCES calendar_events(id) ON DELETE CASCADE,
    external_event_id   VARCHAR(500) NOT NULL,
    provider            VARCHAR(50)  NOT NULL,
    external_calendar_id VARCHAR(500),
    last_synced_at      TIMESTAMPTZ,
    sync_hash           VARCHAR(255),

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- External event must be unique per provider
CREATE UNIQUE INDEX idx_csem_provider_external
    ON calendar_sync_event_map (provider, external_event_id);

-- Look up by internal event
CREATE INDEX idx_csem_internal_event
    ON calendar_sync_event_map (internal_event_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_calendar_sync_event_map_updated_at
    BEFORE UPDATE ON calendar_sync_event_map
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE calendar_sync_event_map IS 'Maps internal events to external calendar events for sync reconciliation.';
