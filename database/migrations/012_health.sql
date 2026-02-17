-- ============================================================================
-- Migration 012: Health Profiles, Measurements, and Sexual Health
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Personal health tracking within the context of a space. Includes body
-- measurements, clothing sizes, wearable device data, and consensual
-- sexual health logging. Sexual health data uses hard-delete only
-- (no soft delete) for enhanced privacy.
-- ============================================================================

-- ==========================================================================
-- ENUM: size_system
-- ==========================================================================
CREATE TYPE size_system AS ENUM (
    'eu',
    'us',
    'uk'
);

-- ==========================================================================
-- ENUM: health_source
-- ==========================================================================
CREATE TYPE health_source AS ENUM (
    'manual',
    'healthkit',
    'google_fit',
    'samsung_health'
);

-- ==========================================================================
-- TABLE: health_profiles
-- ==========================================================================
-- Per-user-per-space health and sizing profile. Requires explicit consent
-- (consent_given_at). Consent can be withdrawn to restrict data access.
-- ==========================================================================
CREATE TABLE health_profiles (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    space_id                UUID        NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    height_cm               DECIMAL(5,1),
    weight_kg               DECIMAL(5,1),

    -- Clothing sizes
    top_size                VARCHAR(20),
    bottom_size             VARCHAR(20),
    underwear_size          VARCHAR(20),
    shoe_size               VARCHAR(20),
    size_system             size_system,

    -- Ring sizes
    ring_size               VARCHAR(20),
    ring_size_system        VARCHAR(20),

    -- Consent tracking
    consent_given_at        TIMESTAMPTZ,
    consent_withdrawn_at    TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT hp_height_positive CHECK (height_cm IS NULL OR height_cm > 0),
    CONSTRAINT hp_weight_positive CHECK (weight_kg IS NULL OR weight_kg > 0),
    CONSTRAINT hp_consent_order   CHECK (
        consent_withdrawn_at IS NULL
        OR (consent_given_at IS NOT NULL AND consent_withdrawn_at >= consent_given_at)
    )
);

-- One profile per user per space
CREATE UNIQUE INDEX idx_hp_user_space
    ON health_profiles (user_id, space_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_health_profiles_updated_at
    BEFORE UPDATE ON health_profiles
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE health_profiles IS 'Per-user health profiles with body measurements, sizing, and consent tracking.';

-- ==========================================================================
-- TABLE: health_measurements
-- ==========================================================================
-- Time-series health data from manual entry or wearable devices.
-- Supports various measurement types (steps, heart_rate, sleep_hours,
-- weight, blood_pressure, etc.).
-- ==========================================================================
CREATE TABLE health_measurements (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    measurement_type    VARCHAR(50)   NOT NULL,  -- 'steps', 'heart_rate', 'sleep_hours', 'weight', etc.
    value               DECIMAL       NOT NULL,
    unit                VARCHAR(20)   NOT NULL,  -- 'count', 'bpm', 'hours', 'kg', etc.
    source              health_source NOT NULL DEFAULT 'manual',
    measured_at         TIMESTAMPTZ   NOT NULL,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT hm_type_not_empty CHECK (length(trim(measurement_type)) > 0),
    CONSTRAINT hm_unit_not_empty CHECK (length(trim(unit)) > 0)
);

-- Query measurements for a user by type and time range
CREATE INDEX idx_hm_user_type_time
    ON health_measurements (user_id, measurement_type, measured_at DESC);

COMMENT ON TABLE health_measurements IS 'Time-series health measurements from manual entry or wearable integrations.';

-- ==========================================================================
-- TABLE: sexual_health_entries
-- ==========================================================================
-- Consensual sexual health logging for the space. NO soft delete (deleted_at
-- column intentionally omitted) - entries are hard-deleted for privacy.
-- Feedback is encrypted client-side.
-- ==========================================================================
CREATE TABLE sexual_health_entries (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id                    UUID    NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    date                        DATE    NOT NULL,
    is_protected                BOOLEAN NOT NULL,
    feedback_encrypted          TEXT,   -- client-side encrypted

    -- Optional link to a sexual_fantasies activity
    linked_fantasy_activity_id  UUID    REFERENCES activities(id) ON DELETE SET NULL,

    -- Timestamps (NO deleted_at - hard delete only for privacy)
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- List entries for a space by date
CREATE INDEX idx_she_space_date
    ON sexual_health_entries (space_id, date DESC);

COMMENT ON TABLE sexual_health_entries IS
    'Sexual health logging (hard-delete only, no soft delete for privacy).';

-- ==========================================================================
-- TABLE: sexual_health_participants
-- ==========================================================================
-- Tracks which space members participated in a sexual health entry.
-- Composite primary key (no separate id column needed).
-- ==========================================================================
CREATE TABLE sexual_health_participants (
    entry_id    UUID NOT NULL REFERENCES sexual_health_entries(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id)                 ON DELETE CASCADE,

    PRIMARY KEY (entry_id, user_id)
);

COMMENT ON TABLE sexual_health_participants IS 'Participants in a sexual health entry.';
