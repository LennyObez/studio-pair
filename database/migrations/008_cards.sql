-- ============================================================================
-- Migration 008: Cards (Debit, Credit, Loyalty)
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Shared card management for debit/credit cards and loyalty programs.
-- Sensitive data (barcodes, customer numbers) is stored encrypted.
-- Cards can be shared with specific space members and given private
-- nicknames per user.
-- ============================================================================

-- ==========================================================================
-- ENUM: card_type
-- ==========================================================================
CREATE TYPE card_type AS ENUM (
    'debit',
    'credit',
    'loyalty'
);

-- ==========================================================================
-- TABLE: cards
-- ==========================================================================
-- Stores card metadata. Sensitive loyalty data is encrypted at rest.
-- Only the last four digits are stored for debit/credit cards (no full
-- card numbers are ever stored).
-- ==========================================================================
CREATE TABLE cards (
    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id                        UUID      NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by                      UUID      NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    card_type                       card_type NOT NULL,
    display_name                    VARCHAR(100) NOT NULL,
    provider                        VARCHAR(50),     -- e.g., 'visa', 'mastercard', 'amex', etc.
    last_four                       CHAR(4),
    expiry_month                    SMALLINT,
    expiry_year                     SMALLINT,
    card_color                      VARCHAR(20),     -- hex color or named color

    -- Loyalty-specific fields (encrypted)
    loyalty_barcode_data_encrypted  TEXT,
    loyalty_customer_number_encrypted TEXT,
    loyalty_customer_name           VARCHAR(255),
    loyalty_store_name              VARCHAR(255),
    loyalty_store_logo_url          TEXT,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT cards_last_four_digits   CHECK (last_four IS NULL OR last_four ~ '^\d{4}$'),
    CONSTRAINT cards_expiry_month_range CHECK (expiry_month IS NULL OR (expiry_month >= 1 AND expiry_month <= 12)),
    CONSTRAINT cards_expiry_year_range  CHECK (expiry_year IS NULL OR expiry_year >= 2020),
    CONSTRAINT cards_display_name_not_empty CHECK (length(trim(display_name)) > 0)
);

-- List cards for a space
CREATE INDEX idx_cards_space
    ON cards (space_id)
    WHERE deleted_at IS NULL;

-- Filter by card type
CREATE INDEX idx_cards_space_type
    ON cards (space_id, card_type)
    WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_cards_updated_at
    BEFORE UPDATE ON cards
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE cards IS 'Debit, credit, and loyalty cards with encrypted sensitive data.';

-- ==========================================================================
-- TABLE: card_shares
-- ==========================================================================
-- Tracks which users a card has been shared with within the space.
-- ==========================================================================
CREATE TABLE card_shares (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    card_id             UUID NOT NULL REFERENCES cards(id)  ON DELETE CASCADE,
    shared_with_user_id UUID NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    shared_by_user_id   UUID NOT NULL REFERENCES users(id)  ON DELETE CASCADE,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One share per card per user
CREATE UNIQUE INDEX idx_card_shares_card_user
    ON card_shares (card_id, shared_with_user_id);

COMMENT ON TABLE card_shares IS 'Tracks card sharing permissions between space members.';

-- ==========================================================================
-- TABLE: card_private_names
-- ==========================================================================
-- Allows each user to assign a personal nickname to a shared card
-- (visible only to them).
-- ==========================================================================
CREATE TABLE card_private_names (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    card_id     UUID         NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    user_id     UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    private_name VARCHAR(100) NOT NULL,

    -- Constraints
    CONSTRAINT cpn_name_not_empty CHECK (length(trim(private_name)) > 0)
);

-- One private name per card per user
CREATE UNIQUE INDEX idx_cpn_card_user
    ON card_private_names (card_id, user_id);

COMMENT ON TABLE card_private_names IS 'Per-user private nicknames for shared cards.';
