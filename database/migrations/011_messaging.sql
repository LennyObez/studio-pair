-- ============================================================================
-- Migration 011: Messaging (Chat, Mail, Private Capsules)
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Unified messaging system supporting real-time chat, internal mail, and
-- private capsules (time-locked messages). Messages are E2E encrypted.
-- Supports replies, edit windows, and read receipts.
-- ============================================================================

-- ==========================================================================
-- ENUM: conversation_type
-- ==========================================================================
CREATE TYPE conversation_type AS ENUM (
    'chat',
    'mail',
    'private_capsule'
);

-- ==========================================================================
-- ENUM: message_content_type
-- ==========================================================================
CREATE TYPE message_content_type AS ENUM (
    'text',
    'image',
    'file',
    'system'
);

-- ==========================================================================
-- TABLE: conversations
-- ==========================================================================
-- A conversation container. Type determines behavior:
--   - chat: real-time group/1:1 chat
--   - mail: asynchronous internal messages
--   - private_capsule: time-locked messages revealed at a future date
-- ==========================================================================
CREATE TABLE conversations (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id    UUID              NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    type        conversation_type NOT NULL,
    title       VARCHAR(255),
    created_by  UUID              NOT NULL REFERENCES users(id)  ON DELETE CASCADE,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- List conversations for a space
CREATE INDEX idx_conversations_space
    ON conversations (space_id, updated_at DESC);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE conversations IS 'Conversation containers for chat, mail, and private capsules.';

-- ==========================================================================
-- TABLE: conversation_participants
-- ==========================================================================
-- Tracks which users are part of a conversation. left_at is set when
-- a user leaves (but the record is preserved for history).
-- ==========================================================================
CREATE TABLE conversation_participants (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID        NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id         UUID        NOT NULL REFERENCES users(id)         ON DELETE CASCADE,
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    left_at         TIMESTAMPTZ
);

-- One participation record per user per conversation
CREATE UNIQUE INDEX idx_cp_conversation_user
    ON conversation_participants (conversation_id, user_id);

-- Find conversations for a user
CREATE INDEX idx_cp_user_id
    ON conversation_participants (user_id);

COMMENT ON TABLE conversation_participants IS 'Tracks user participation in conversations.';

-- ==========================================================================
-- TABLE: messages
-- ==========================================================================
-- Individual messages within a conversation. Content is E2E encrypted.
-- Supports replies (reply_to_message_id), editing within a deadline
-- window, and soft deletion.
-- ==========================================================================
CREATE TABLE messages (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id     UUID                 NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id           UUID                 NOT NULL REFERENCES users(id)         ON DELETE CASCADE,
    content_encrypted   TEXT                 NOT NULL,
    content_type        message_content_type NOT NULL DEFAULT 'text',
    reply_to_message_id UUID                 REFERENCES messages(id) ON DELETE SET NULL,
    is_edited           BOOLEAN              NOT NULL DEFAULT FALSE,
    edit_deadline       TIMESTAMPTZ,

    -- Flexible metadata (file references, link previews, etc.)
    metadata            JSONB,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);

-- List messages in a conversation, newest first
CREATE INDEX idx_messages_conversation_created
    ON messages (conversation_id, created_at DESC)
    WHERE deleted_at IS NULL;

-- Find messages by sender
CREATE INDEX idx_messages_sender
    ON messages (sender_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_messages_updated_at
    BEFORE UPDATE ON messages
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE messages IS 'E2E encrypted messages with reply support and edit deadlines.';

-- ==========================================================================
-- TABLE: message_read_receipts
-- ==========================================================================
-- Tracks when each user reads a message. Used for read indicators
-- and unread count calculations.
-- ==========================================================================
CREATE TABLE message_read_receipts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id  UUID        NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id     UUID        NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    read_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One receipt per message per user
CREATE UNIQUE INDEX idx_mrr_message_user
    ON message_read_receipts (message_id, user_id);

-- Count unread messages for a user
CREATE INDEX idx_mrr_user_id
    ON message_read_receipts (user_id);

COMMENT ON TABLE message_read_receipts IS 'Read receipts for messages.';
