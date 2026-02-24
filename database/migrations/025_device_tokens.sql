-- Migration 025: Device tokens for push notifications
-- Stores FCM/APNs device tokens for each user so push notifications
-- can be delivered to their registered devices.

CREATE TABLE IF NOT EXISTS device_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       TEXT NOT NULL,
    platform    VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    device_name VARCHAR(200),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Each token should be unique per user
    CONSTRAINT uq_device_tokens_user_token UNIQUE (user_id, token)
);

-- Index for looking up tokens by user
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);

-- Index for finding a specific token (for deregistration)
CREATE INDEX IF NOT EXISTS idx_device_tokens_token ON device_tokens(token);
