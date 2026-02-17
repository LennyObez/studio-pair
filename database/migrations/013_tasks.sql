-- ============================================================================
-- Migration 013: Tasks and Task Assignments
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Shared task management with subtask hierarchy, priority levels,
-- recurrence, and multi-user assignment. Supports cross-module linking
-- for tasks generated from other features (e.g., grocery lists, chores).
-- ============================================================================

-- ==========================================================================
-- ENUM: task_status
-- ==========================================================================
CREATE TYPE task_status AS ENUM (
    'todo',
    'in_progress',
    'done'
);

-- ==========================================================================
-- ENUM: task_priority
-- ==========================================================================
CREATE TYPE task_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);

-- ==========================================================================
-- TABLE: tasks
-- ==========================================================================
-- Individual task items. Supports subtask hierarchy via parent_task_id
-- (self-referencing FK), recurrence via RRULE, and cross-module linking.
-- ==========================================================================
CREATE TABLE tasks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id        UUID          NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
    created_by      UUID          NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    title           VARCHAR(255)  NOT NULL,
    description     TEXT,
    status          task_status   NOT NULL DEFAULT 'todo',
    priority        task_priority NOT NULL DEFAULT 'medium',
    due_date        DATE,

    -- Cross-module linking
    source_module       VARCHAR(50),
    source_entity_id    UUID,

    -- Subtask hierarchy (self-referencing)
    parent_task_id  UUID REFERENCES tasks(id) ON DELETE CASCADE,

    -- Recurrence
    is_recurring    BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT,

    -- Completion
    completed_at    TIMESTAMPTZ,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT tasks_title_not_empty CHECK (length(trim(title)) > 0),
    CONSTRAINT tasks_recurrence_consistency CHECK (
        (is_recurring = FALSE AND recurrence_rule IS NULL)
        OR (is_recurring = TRUE AND recurrence_rule IS NOT NULL)
    ),
    CONSTRAINT tasks_completed_consistency CHECK (
        (status != 'done' AND completed_at IS NULL)
        OR (status = 'done' AND completed_at IS NOT NULL)
    ),
    CONSTRAINT tasks_no_self_parent CHECK (parent_task_id != id)
);

-- List tasks for a space (active, ordered by priority and due date)
CREATE INDEX idx_tasks_space_active
    ON tasks (space_id, priority, due_date)
    WHERE deleted_at IS NULL AND status != 'done';

-- All tasks for a space (including completed)
CREATE INDEX idx_tasks_space_all
    ON tasks (space_id, created_at DESC)
    WHERE deleted_at IS NULL;

-- Subtasks of a parent
CREATE INDEX idx_tasks_parent
    ON tasks (parent_task_id)
    WHERE parent_task_id IS NOT NULL;

-- Cross-module lookup
CREATE INDEX idx_tasks_source
    ON tasks (source_module, source_entity_id)
    WHERE source_module IS NOT NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE tasks IS 'Shared tasks with subtask hierarchy, priority, recurrence, and cross-module linking.';

-- ==========================================================================
-- TABLE: task_assignments
-- ==========================================================================
-- Assigns tasks to one or more space members. A task can be assigned to
-- multiple users.
-- ==========================================================================
CREATE TABLE task_assignments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One assignment per user per task
CREATE UNIQUE INDEX idx_ta_task_user
    ON task_assignments (task_id, user_id);

-- Find all tasks assigned to a user
CREATE INDEX idx_ta_user_id
    ON task_assignments (user_id);

COMMENT ON TABLE task_assignments IS 'Task-to-user assignment records.';
