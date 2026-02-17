-- ============================================================================
-- Migration 001: Extensions and Utility Functions
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Enables required PostgreSQL extensions and creates reusable utility
-- functions used across all modules.
-- ============================================================================

-- ==========================================================================
-- EXTENSIONS
-- ==========================================================================

-- uuid-ossp: Provides UUID generation functions (uuid_generate_v4, etc.)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- pgcrypto: Provides cryptographic functions (gen_random_uuid, crypt, gen_salt, etc.)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- pg_trgm: Provides trigram-based text similarity and indexing for fuzzy search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ==========================================================================
-- FUNCTIONS
-- ==========================================================================

-- --------------------------------------------------------------------------
-- Function: set_updated_at()
-- Automatically sets the updated_at column to the current timestamp
-- whenever a row is modified. Attach via trigger to any table with
-- an updated_at column.
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION set_updated_at() IS
    'Trigger function that sets updated_at to NOW() on every UPDATE.';

-- --------------------------------------------------------------------------
-- Function: generate_invite_code(length INTEGER)
-- Generates a human-readable, URL-safe invite code of the specified length.
-- Uses uppercase alphanumerics excluding ambiguous characters (0, O, I, L, 1).
-- Default length is 8 characters.
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_invite_code(code_length INTEGER DEFAULT 8)
RETURNS TEXT AS $$
DECLARE
    -- Alphabet excludes ambiguous characters: 0, O, I, L, 1
    alphabet TEXT := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    alphabet_len INTEGER := length(alphabet);
    result TEXT := '';
    i INTEGER;
    random_bytes BYTEA;
BEGIN
    random_bytes := gen_random_bytes(code_length);
    FOR i IN 0..(code_length - 1) LOOP
        result := result || substr(alphabet, (get_byte(random_bytes, i) % alphabet_len) + 1, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION generate_invite_code(INTEGER) IS
    'Generates a URL-safe, human-readable invite code of the given length. '
    'Excludes ambiguous characters (0, O, I, L, 1).';
