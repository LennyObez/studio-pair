-- ============================================================================
-- Migration 010: Finances (Income, Expenses, Splits)
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Shared financial tracking with income/expense entries, recurring
-- transactions, and flexible expense splitting (equal, percentage,
-- or custom amounts).
-- ============================================================================

-- ==========================================================================
-- ENUM: finance_entry_type
-- ==========================================================================
CREATE TYPE finance_entry_type AS ENUM (
    'income',
    'expense'
);

-- ==========================================================================
-- ENUM: split_type
-- ==========================================================================
CREATE TYPE split_type AS ENUM (
    'equal',
    'percentage',
    'custom'
);

-- ==========================================================================
-- TABLE: finance_entries
-- ==========================================================================
-- Individual income or expense records. Supports categorization, recurring
-- entries via RRULE, and cross-module linking to calendar events.
-- Amounts are stored in cents to avoid floating-point issues.
-- ==========================================================================
CREATE TABLE finance_entries (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id                UUID              NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by              UUID              NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    entry_type              finance_entry_type NOT NULL,
    category                VARCHAR(100)      NOT NULL,
    subcategory             VARCHAR(100),
    description             TEXT,
    amount_cents            BIGINT            NOT NULL,
    currency                CHAR(3)           NOT NULL DEFAULT 'EUR',
    is_recurring            BOOLEAN           NOT NULL DEFAULT FALSE,
    recurrence_rule         TEXT,             -- RFC 5545 RRULE for recurring entries

    -- Cross-module link
    linked_calendar_event_id UUID,

    -- Entry date
    date                    DATE              NOT NULL,

    -- Flexible metadata (receipts, tags, etc.)
    metadata                JSONB,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fe_amount_positive   CHECK (amount_cents > 0),
    CONSTRAINT fe_currency_valid    CHECK (currency ~ '^[A-Z]{3}$'),
    CONSTRAINT fe_category_not_empty CHECK (length(trim(category)) > 0),
    CONSTRAINT fe_recurrence_consistency CHECK (
        (is_recurring = FALSE AND recurrence_rule IS NULL)
        OR (is_recurring = TRUE AND recurrence_rule IS NOT NULL)
    )
);

-- List entries for a space by date
CREATE INDEX idx_fe_space_date
    ON finance_entries (space_id, date DESC)
    WHERE deleted_at IS NULL;

-- Filter by entry type
CREATE INDEX idx_fe_space_type
    ON finance_entries (space_id, entry_type)
    WHERE deleted_at IS NULL;

-- Filter by category
CREATE INDEX idx_fe_space_category
    ON finance_entries (space_id, category)
    WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_finance_entries_updated_at
    BEFORE UPDATE ON finance_entries
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE finance_entries IS 'Income and expense records with categorization, recurrence, and calendar linking.';

-- ==========================================================================
-- TABLE: expense_splits
-- ==========================================================================
-- Defines how an expense is split among space members. Each finance entry
-- can have at most one split configuration.
-- ==========================================================================
CREATE TABLE expense_splits (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    finance_entry_id    UUID       NOT NULL REFERENCES finance_entries(id) ON DELETE CASCADE,
    payer_user_id       UUID       NOT NULL REFERENCES users(id)          ON DELETE CASCADE,
    split_type          split_type NOT NULL DEFAULT 'equal',

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One split per finance entry
CREATE UNIQUE INDEX idx_es_finance_entry
    ON expense_splits (finance_entry_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_expense_splits_updated_at
    BEFORE UPDATE ON expense_splits
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE expense_splits IS 'Split configuration for an expense (equal, percentage, or custom).';

-- ==========================================================================
-- TABLE: expense_split_shares
-- ==========================================================================
-- Individual shares within a split. For 'equal' splits, share_amount_cents
-- is computed. For 'percentage', share_percentage is set. For 'custom',
-- share_amount_cents is explicitly provided.
-- ==========================================================================
CREATE TABLE expense_split_shares (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_split_id    UUID          NOT NULL REFERENCES expense_splits(id) ON DELETE CASCADE,
    user_id             UUID          NOT NULL REFERENCES users(id)          ON DELETE CASCADE,
    share_amount_cents  BIGINT,
    share_percentage    DECIMAL(5,2),
    is_settled          BOOLEAN       NOT NULL DEFAULT FALSE,
    settled_at          TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT ess_percentage_range CHECK (
        share_percentage IS NULL OR (share_percentage >= 0 AND share_percentage <= 100)
    ),
    CONSTRAINT ess_amount_non_negative CHECK (
        share_amount_cents IS NULL OR share_amount_cents >= 0
    ),
    CONSTRAINT ess_settled_consistency CHECK (
        (is_settled = FALSE AND settled_at IS NULL)
        OR (is_settled = TRUE AND settled_at IS NOT NULL)
    )
);

-- One share per user per split
CREATE UNIQUE INDEX idx_ess_split_user
    ON expense_split_shares (expense_split_id, user_id);

-- Find unsettled shares for a user
CREATE INDEX idx_ess_user_unsettled
    ON expense_split_shares (user_id)
    WHERE is_settled = FALSE;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_expense_split_shares_updated_at
    BEFORE UPDATE ON expense_split_shares
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE expense_split_shares IS 'Individual user shares within an expense split.';
