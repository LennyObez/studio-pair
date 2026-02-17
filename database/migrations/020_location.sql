-- ============================================================================
-- Migration 020: Location Sharing
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Ephemeral location sharing with three modes: temporary (live sharing),
-- safe_ping (one-time "I'm here" signal), and eta (estimated arrival).
-- Data should be cleaned up after expiry via a scheduled job.
-- ============================================================================

-- ==========================================================================
-- ENUM: location_share_type
-- ==========================================================================
CREATE TYPE location_share_type AS ENUM (
    'temporary',
    'safe_ping',
    'eta'
);

-- ==========================================================================
-- TABLE: location_shares
-- ==========================================================================
-- Ephemeral location data. Each record represents a point-in-time location
-- share or an ongoing ETA share. Expired records should be periodically
-- purged by a background cleanup job.
--
-- NOTE: This table intentionally has NO soft delete. Old records should
-- be hard-deleted after expiry for privacy.
-- ==========================================================================
CREATE TABLE location_shares (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID               NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    space_id        UUID               NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    latitude        DECIMAL(10,7)      NOT NULL,
    longitude       DECIMAL(10,7)      NOT NULL,
    type            location_share_type NOT NULL,
    expires_at      TIMESTAMPTZ        NOT NULL,

    -- ETA-specific fields
    eta_destination         VARCHAR(500),
    eta_destination_lat     DECIMAL(10,7),
    eta_destination_lng     DECIMAL(10,7),
    eta_minutes             INT,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT ls_lat_range     CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT ls_lng_range     CHECK (longitude >= -180 AND longitude <= 180),
    CONSTRAINT ls_eta_dest_lat  CHECK (eta_destination_lat IS NULL OR (eta_destination_lat >= -90 AND eta_destination_lat <= 90)),
    CONSTRAINT ls_eta_dest_lng  CHECK (eta_destination_lng IS NULL OR (eta_destination_lng >= -180 AND eta_destination_lng <= 180)),
    CONSTRAINT ls_eta_minutes_positive CHECK (eta_minutes IS NULL OR eta_minutes > 0),
    CONSTRAINT ls_eta_consistency CHECK (
        type != 'eta'
        OR (eta_destination IS NOT NULL AND eta_minutes IS NOT NULL)
    )
);

-- Active (non-expired) shares for a space
CREATE INDEX idx_ls_space_active
    ON location_shares (space_id, expires_at)
    WHERE expires_at > NOW();

-- Active shares by user
CREATE INDEX idx_ls_user_active
    ON location_shares (user_id, expires_at)
    WHERE expires_at > NOW();

-- Cleanup job: find expired records for deletion
CREATE INDEX idx_ls_expired
    ON location_shares (expires_at)
    WHERE expires_at <= NOW();

COMMENT ON TABLE location_shares IS
    'Ephemeral location shares (temporary, safe_ping, ETA). '
    'Expired records should be hard-deleted by a scheduled cleanup job.';
