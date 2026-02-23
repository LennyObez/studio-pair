-- ============================================================================
-- Migration 018: Grocery Lists and Items
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Shared grocery list management. Multiple lists per space with
-- categorized, orderable items. Items track who checked them off
-- and optional pricing.
-- ============================================================================

-- ==========================================================================
-- ENUM: grocery_category
-- ==========================================================================
CREATE TYPE grocery_category AS ENUM (
    'produce',
    'dairy',
    'meat',
    'frozen',
    'bakery',
    'beverages',
    'snacks',
    'canned_goods',
    'condiments',
    'household',
    'personal_care',
    'other'
);

-- ==========================================================================
-- TABLE: grocery_lists
-- ==========================================================================
-- A named grocery list belonging to a space. Soft-deletable for
-- list archival.
-- ==========================================================================
CREATE TABLE grocery_lists (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id    UUID         NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    name        VARCHAR(255) NOT NULL,
    created_by  UUID         NOT NULL REFERENCES users(id)  ON DELETE CASCADE,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT gl_name_not_empty CHECK (length(trim(name)) > 0)
);

-- List grocery lists for a space
CREATE INDEX idx_gl_space
    ON grocery_lists (space_id, updated_at DESC)
    WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_grocery_lists_updated_at
    BEFORE UPDATE ON grocery_lists
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE grocery_lists IS 'Named grocery lists within a space.';

-- ==========================================================================
-- TABLE: grocery_items
-- ==========================================================================
-- Individual items on a grocery list. Supports quantities with units,
-- categorization, ordering, notes, pricing, and check-off tracking.
-- ==========================================================================
CREATE TABLE grocery_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id         UUID             NOT NULL REFERENCES grocery_lists(id) ON DELETE CASCADE,
    name            VARCHAR(255)     NOT NULL,
    quantity        DECIMAL,
    unit            VARCHAR(50),         -- e.g., 'kg', 'pieces', 'liters'
    category        grocery_category NOT NULL DEFAULT 'other',
    note            TEXT,
    is_checked      BOOLEAN          NOT NULL DEFAULT FALSE,
    checked_by      UUID             REFERENCES users(id) ON DELETE SET NULL,
    checked_at      TIMESTAMPTZ,
    price_cents     INT,
    display_order   INT              NOT NULL DEFAULT 0,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT gi_name_not_empty    CHECK (length(trim(name)) > 0),
    CONSTRAINT gi_quantity_positive CHECK (quantity IS NULL OR quantity > 0),
    CONSTRAINT gi_price_non_negative CHECK (price_cents IS NULL OR price_cents >= 0),
    CONSTRAINT gi_checked_consistency CHECK (
        (is_checked = FALSE AND checked_by IS NULL AND checked_at IS NULL)
        OR (is_checked = TRUE AND checked_at IS NOT NULL)
    )
);

-- List items for a grocery list in display order
CREATE INDEX idx_gi_list_order
    ON grocery_items (list_id, display_order);

-- Unchecked items (shopping mode)
CREATE INDEX idx_gi_list_unchecked
    ON grocery_items (list_id, display_order)
    WHERE is_checked = FALSE;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_grocery_items_updated_at
    BEFORE UPDATE ON grocery_items
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE grocery_items IS 'Individual grocery items with categorization, ordering, and check-off tracking.';
