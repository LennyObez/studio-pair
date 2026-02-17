-- ============================================================================
-- Migration 004: Entitlements and Subscriptions
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Tracks per-space feature limits (storage, AI credits, calendar connections)
-- and subscription state across platforms (iOS, Android, Web).
-- ============================================================================

-- ==========================================================================
-- ENUM: tier
-- ==========================================================================
CREATE TYPE tier AS ENUM (
    'free',
    'premium'
);

-- ==========================================================================
-- ENUM: subscription_platform
-- ==========================================================================
CREATE TYPE subscription_platform AS ENUM (
    'ios',
    'android',
    'web'
);

-- ==========================================================================
-- ENUM: subscription_status
-- ==========================================================================
CREATE TYPE subscription_status AS ENUM (
    'active',
    'past_due',
    'canceled',
    'expired',
    'trialing'
);

-- ==========================================================================
-- TABLE: entitlements
-- ==========================================================================
-- One-to-one with spaces. Defines the feature limits and current usage
-- for a given billing period. Updated as the space consumes resources
-- or the subscription tier changes.
-- ==========================================================================
CREATE TABLE entitlements (
    space_id                    UUID PRIMARY KEY REFERENCES spaces(id) ON DELETE CASCADE,
    tier                        tier    NOT NULL DEFAULT 'free',

    -- Storage
    storage_bytes_used          BIGINT  NOT NULL DEFAULT 0,
    storage_bytes_limit         BIGINT  NOT NULL,

    -- Members
    max_members                 INT     NOT NULL,

    -- Calendar connections
    calendar_connections_count  INT     NOT NULL DEFAULT 0,
    calendar_connections_limit  INT     NOT NULL,

    -- AI credits (per billing period)
    ai_credits_used_this_period INT     NOT NULL DEFAULT 0,
    ai_credits_limit            INT     NOT NULL,

    -- History retention
    history_retention_days      INT     NOT NULL,

    -- Current billing period
    current_period_start        TIMESTAMPTZ,
    current_period_end          TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT ent_storage_non_negative      CHECK (storage_bytes_used >= 0),
    CONSTRAINT ent_storage_limit_positive    CHECK (storage_bytes_limit > 0),
    CONSTRAINT ent_max_members_positive      CHECK (max_members >= 2),
    CONSTRAINT ent_cal_conn_non_negative     CHECK (calendar_connections_count >= 0),
    CONSTRAINT ent_cal_conn_limit_positive   CHECK (calendar_connections_limit >= 0),
    CONSTRAINT ent_ai_credits_non_negative   CHECK (ai_credits_used_this_period >= 0),
    CONSTRAINT ent_ai_credits_limit_positive CHECK (ai_credits_limit >= 0),
    CONSTRAINT ent_retention_positive        CHECK (history_retention_days > 0),
    CONSTRAINT ent_period_valid              CHECK (
        (current_period_start IS NULL AND current_period_end IS NULL)
        OR current_period_end > current_period_start
    )
);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_entitlements_updated_at
    BEFORE UPDATE ON entitlements
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE entitlements IS 'Per-space feature limits and usage counters (one-to-one with spaces).';

-- ==========================================================================
-- TABLE: subscriptions
-- ==========================================================================
-- Tracks external subscription records from app stores and web payment
-- providers. A space may have multiple subscription records over time
-- (e.g., platform changes, renewals).
-- ==========================================================================
CREATE TABLE subscriptions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id                UUID                NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    platform                subscription_platform NOT NULL,
    external_subscription_id VARCHAR(255),
    status                  subscription_status NOT NULL DEFAULT 'active',
    plan_id                 VARCHAR(100),
    amount_cents            INT,
    currency                CHAR(3)             NOT NULL DEFAULT 'EUR',

    -- Lifecycle dates
    started_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    expires_at              TIMESTAMPTZ,
    canceled_at             TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT sub_amount_non_negative CHECK (amount_cents IS NULL OR amount_cents >= 0),
    CONSTRAINT sub_currency_valid      CHECK (currency ~ '^[A-Z]{3}$')
);

-- Look up subscriptions for a space
CREATE INDEX idx_subscriptions_space_id
    ON subscriptions (space_id);

-- Find subscription by external ID (for webhook reconciliation)
CREATE INDEX idx_subscriptions_external_id
    ON subscriptions (external_subscription_id)
    WHERE external_subscription_id IS NOT NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE subscriptions IS 'External subscription records from app stores and web payment providers.';
