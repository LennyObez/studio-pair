-- ============================================================================
-- Migration 009: Vault (Shared Password / Secret Manager)
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Client-side encrypted vault for storing shared credentials (passwords,
-- notes, etc.). The server never sees plaintext secrets. Sharing is done
-- by re-encrypting the symmetric key with each recipient's public key.
-- ============================================================================

-- ==========================================================================
-- TABLE: vault_entries
-- ==========================================================================
-- Each entry stores a client-side encrypted blob containing the actual
-- credentials. The domain and label are metadata stored in plaintext
-- for listing/search. favicon_url provides visual identification.
-- ==========================================================================
CREATE TABLE vault_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id        UUID         NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by      UUID         NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    domain          VARCHAR(255),           -- e.g., 'netflix.com'
    favicon_url     TEXT,
    label           VARCHAR(255) NOT NULL,  -- user-visible label
    encrypted_blob  TEXT         NOT NULL,  -- client-side encrypted payload

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT ve_label_not_empty CHECK (length(trim(label)) > 0)
);

-- List entries for a space
CREATE INDEX idx_ve_space
    ON vault_entries (space_id)
    WHERE deleted_at IS NULL;

-- Search by domain
CREATE INDEX idx_ve_domain
    ON vault_entries (domain)
    WHERE domain IS NOT NULL AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_vault_entries_updated_at
    BEFORE UPDATE ON vault_entries
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE vault_entries IS 'Client-side encrypted vault entries (credentials, secrets, notes).';

-- ==========================================================================
-- TABLE: vault_shares
-- ==========================================================================
-- When a vault entry is shared with another user, the symmetric encryption
-- key is re-encrypted with the recipient's public key and stored here.
-- This enables E2E encrypted sharing without the server seeing plaintext.
-- ==========================================================================
CREATE TABLE vault_shares (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vault_entry_id          UUID NOT NULL REFERENCES vault_entries(id) ON DELETE CASCADE,
    shared_with_user_id     UUID NOT NULL REFERENCES users(id)         ON DELETE CASCADE,
    encrypted_symmetric_key TEXT NOT NULL,   -- symmetric key encrypted with recipient's public key
    shared_by               UUID NOT NULL REFERENCES users(id)         ON DELETE CASCADE,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One share per entry per user
CREATE UNIQUE INDEX idx_vs_entry_user
    ON vault_shares (vault_entry_id, shared_with_user_id);

-- Look up all vault entries shared with a user
CREATE INDEX idx_vs_shared_with
    ON vault_shares (shared_with_user_id);

COMMENT ON TABLE vault_shares IS 'E2E encrypted vault sharing via re-encrypted symmetric keys.';
