-- ============================================================================
-- Migration 002: Users, Sessions, and Password Reset Tokens
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Core identity tables for authentication, session management, and
-- password recovery. Supports TOTP-based 2FA and end-to-end encryption
-- key storage.
-- ============================================================================

-- ==========================================================================
-- TABLE: users
-- ==========================================================================
-- Core user identity. Email is stored lowercase and must be unique.
-- Soft-deletable via deleted_at for GDPR-compliant account deactivation.
-- ==========================================================================
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) NOT NULL,
    password_hash   TEXT         NOT NULL,
    display_name    VARCHAR(100) NOT NULL,
    avatar_url      TEXT,

    -- Two-Factor Authentication (TOTP)
    totp_secret_encrypted   TEXT,
    totp_enabled            BOOLEAN NOT NULL DEFAULT FALSE,
    backup_codes_encrypted  TEXT,

    -- End-to-End Encryption key pair (for vault, messages, etc.)
    encryption_public_key   TEXT,
    encrypted_private_key   TEXT,

    -- Preferences
    preferred_language  VARCHAR(10) NOT NULL DEFAULT 'en',
    timezone            VARCHAR(50),

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,            -- soft delete

    -- Constraints
    CONSTRAINT users_email_lowercase CHECK (email = LOWER(email)),
    CONSTRAINT users_email_format    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Email must be unique among non-deleted users
CREATE UNIQUE INDEX idx_users_email_unique
    ON users (email)
    WHERE deleted_at IS NULL;

-- Index for looking up active (non-deleted) users
CREATE INDEX idx_users_active
    ON users (created_at)
    WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE users IS 'Core user identity table with authentication, 2FA, and E2E encryption keys.';

-- ==========================================================================
-- TABLE: user_sessions
-- ==========================================================================
-- Tracks active refresh-token sessions per device. Each row represents one
-- authenticated device. The refresh_token_hash stores a hashed version of
-- the refresh token (never store raw tokens).
-- ==========================================================================
CREATE TABLE user_sessions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash  TEXT         NOT NULL,
    device_name         VARCHAR(255),
    device_type         VARCHAR(50),    -- e.g. 'ios', 'android', 'web'
    ip_address          INET,
    last_active_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    expires_at          TIMESTAMPTZ  NOT NULL,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT user_sessions_expires_future CHECK (expires_at > created_at)
);

-- Look up sessions by user
CREATE INDEX idx_user_sessions_user_id
    ON user_sessions (user_id);

-- Efficiently find expired sessions for cleanup
CREATE INDEX idx_user_sessions_expires_at
    ON user_sessions (expires_at);

COMMENT ON TABLE user_sessions IS 'Active refresh-token sessions per user/device.';

-- ==========================================================================
-- TABLE: password_reset_tokens
-- ==========================================================================
-- One-time-use password reset tokens. token_hash stores a hashed version
-- of the token sent to the user via email. Tokens expire and can only be
-- used once (used_at records consumption).
-- ==========================================================================
CREATE TABLE password_reset_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  TEXT        NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    used_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT prt_expires_future CHECK (expires_at > created_at)
);

-- Look up tokens by user
CREATE INDEX idx_prt_user_id
    ON password_reset_tokens (user_id);

-- Quickly find valid (unused, non-expired) tokens
CREATE INDEX idx_prt_token_hash
    ON password_reset_tokens (token_hash)
    WHERE used_at IS NULL;

COMMENT ON TABLE password_reset_tokens IS 'One-time-use password reset tokens with expiry.';
