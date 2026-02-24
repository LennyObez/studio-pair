-- ============================================================================
-- Migration 015: Files, Folders, and File Shares
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Hierarchical file storage with folder nesting (max depth 5), malware
-- scanning status, and per-user file/folder sharing within a space.
-- ============================================================================

-- ==========================================================================
-- ENUM: scan_status
-- ==========================================================================
CREATE TYPE scan_status AS ENUM (
    'pending',
    'clean',
    'infected'
);

-- ==========================================================================
-- ENUM: file_access_level
-- ==========================================================================
CREATE TYPE file_access_level AS ENUM (
    'read',
    'read_write'
);

-- ==========================================================================
-- TABLE: folders
-- ==========================================================================
-- Hierarchical folder structure. parent_folder_id enables nesting.
-- depth is enforced to prevent excessively deep hierarchies.
-- System folders (is_system = true) are auto-created and cannot be deleted.
-- ==========================================================================
CREATE TABLE folders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id        UUID         NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    parent_folder_id UUID        REFERENCES folders(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    created_by      UUID         NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    is_system       BOOLEAN      NOT NULL DEFAULT FALSE,
    depth           INT          NOT NULL DEFAULT 0,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT folders_name_not_empty   CHECK (length(trim(name)) > 0),
    CONSTRAINT folders_depth_limit      CHECK (depth <= 5),
    CONSTRAINT folders_depth_non_negative CHECK (depth >= 0),
    CONSTRAINT folders_no_self_parent   CHECK (parent_folder_id != id)
);

-- List folders for a space
CREATE INDEX idx_folders_space
    ON folders (space_id, parent_folder_id)
    WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_folders_updated_at
    BEFORE UPDATE ON folders
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE folders IS 'Hierarchical folder structure with max depth of 5 levels.';

-- ==========================================================================
-- TABLE: files
-- ==========================================================================
-- Individual file records. storage_key references the object storage
-- location (e.g., S3 key). scan_status tracks malware scanning state.
-- ==========================================================================
CREATE TABLE files (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id    UUID         NOT NULL REFERENCES spaces(id)  ON DELETE CASCADE,
    folder_id   UUID         REFERENCES folders(id)          ON DELETE SET NULL,
    uploaded_by UUID         NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
    filename    VARCHAR(255) NOT NULL,
    mime_type   VARCHAR(255) NOT NULL,
    size_bytes  BIGINT       NOT NULL,
    storage_key VARCHAR(500) NOT NULL,
    scan_status scan_status  NOT NULL DEFAULT 'pending',

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT files_filename_not_empty CHECK (length(trim(filename)) > 0),
    CONSTRAINT files_size_non_negative  CHECK (size_bytes >= 0)
);

-- List files in a folder
CREATE INDEX idx_files_folder
    ON files (folder_id)
    WHERE deleted_at IS NULL;

-- List files for a space
CREATE INDEX idx_files_space
    ON files (space_id, created_at DESC)
    WHERE deleted_at IS NULL;

-- Find files pending scan
CREATE INDEX idx_files_scan_pending
    ON files (scan_status)
    WHERE scan_status = 'pending' AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_files_updated_at
    BEFORE UPDATE ON files
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE files IS 'Uploaded files with storage references and malware scan status.';

-- ==========================================================================
-- TABLE: file_shares
-- ==========================================================================
-- Shares a file or folder with a specific user within the space.
-- Either file_id or folder_id must be set (not both).
-- ==========================================================================
CREATE TABLE file_shares (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id             UUID              REFERENCES files(id)   ON DELETE CASCADE,
    folder_id           UUID              REFERENCES folders(id) ON DELETE CASCADE,
    shared_with_user_id UUID NOT NULL     REFERENCES users(id)   ON DELETE CASCADE,
    access_level        file_access_level NOT NULL DEFAULT 'read',
    shared_by           UUID NOT NULL     REFERENCES users(id)   ON DELETE CASCADE,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints: exactly one of file_id or folder_id must be set
    CONSTRAINT fs_file_or_folder CHECK (
        (file_id IS NOT NULL AND folder_id IS NULL)
        OR (file_id IS NULL AND folder_id IS NOT NULL)
    )
);

-- Shares for a specific file
CREATE INDEX idx_fs_file
    ON file_shares (file_id)
    WHERE file_id IS NOT NULL;

-- Shares for a specific folder
CREATE INDEX idx_fs_folder
    ON file_shares (folder_id)
    WHERE folder_id IS NOT NULL;

-- Shares for a specific user
CREATE INDEX idx_fs_shared_with
    ON file_shares (shared_with_user_id);

COMMENT ON TABLE file_shares IS 'Per-user file or folder sharing within a space.';
