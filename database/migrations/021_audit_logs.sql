-- ============================================================================
-- Migration 021: Audit Logs (Partitioned)
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Immutable audit trail for all significant actions across all modules.
-- Partitioned by month on created_at for efficient querying and
-- retention management. Old partitions can be dropped for data lifecycle.
-- ============================================================================

-- ==========================================================================
-- TABLE: audit_logs (partitioned by RANGE on created_at)
-- ==========================================================================
-- Immutable, append-only log of user actions. Each entry records who did
-- what, to which entity, in which module, from which IP. The metadata
-- JSONB column stores action-specific details (old values, new values, etc.).
--
-- Partitioned monthly to enable:
--   - Fast time-range queries
--   - Efficient partition pruning
--   - Easy data retention (DROP old partitions)
-- ==========================================================================
CREATE TABLE audit_logs (
    id          UUID         NOT NULL DEFAULT gen_random_uuid(),
    space_id    UUID         NOT NULL,
    user_id     UUID         NOT NULL,
    module      VARCHAR(50)  NOT NULL,   -- e.g., 'calendar', 'tasks', 'vault'
    action      VARCHAR(50)  NOT NULL,   -- e.g., 'create', 'update', 'delete', 'share'
    entity_type VARCHAR(50)  NOT NULL,   -- e.g., 'calendar_event', 'task', 'vault_entry'
    entity_id   UUID,
    metadata    JSONB,
    ip_address  INET,
    user_agent  TEXT,

    -- Timestamps
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    -- Primary key includes partition key for partition pruning
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- --------------------------------------------------------------------------
-- Indexes (created on the parent; automatically applied to partitions)
-- --------------------------------------------------------------------------

-- Query audit logs for a space within a date range
CREATE INDEX idx_al_space_created
    ON audit_logs (space_id, created_at DESC);

-- Query audit logs for a user within a date range
CREATE INDEX idx_al_user_created
    ON audit_logs (user_id, created_at DESC);

-- Query audit logs for a specific entity
CREATE INDEX idx_al_entity
    ON audit_logs (entity_type, entity_id);

-- Filter by module
CREATE INDEX idx_al_module
    ON audit_logs (module, created_at DESC);

COMMENT ON TABLE audit_logs IS
    'Immutable audit trail partitioned monthly by created_at. '
    'Old partitions can be dropped for data retention.';

-- --------------------------------------------------------------------------
-- Create initial monthly partitions (2026)
-- Adjust date ranges as needed for your deployment timeline.
-- A scheduled job should create future partitions automatically.
-- --------------------------------------------------------------------------

-- 2026 Monthly Partitions
CREATE TABLE audit_logs_2026_01 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE audit_logs_2026_02 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE TABLE audit_logs_2026_03 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

CREATE TABLE audit_logs_2026_04 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

CREATE TABLE audit_logs_2026_05 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');

CREATE TABLE audit_logs_2026_06 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

CREATE TABLE audit_logs_2026_07 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');

CREATE TABLE audit_logs_2026_08 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-08-01') TO ('2026-09-01');

CREATE TABLE audit_logs_2026_09 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');

CREATE TABLE audit_logs_2026_10 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');

CREATE TABLE audit_logs_2026_11 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');

CREATE TABLE audit_logs_2026_12 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

-- --------------------------------------------------------------------------
-- NOTE: The audit_logs table does NOT have foreign keys to spaces or users
-- intentionally. Audit logs must survive even if the referenced user or
-- space is deleted. Application code should populate space_id and user_id
-- at write time. A scheduled job should create future monthly partitions
-- before they are needed.
-- --------------------------------------------------------------------------
