-- ============================================================================
-- Migration 006: Activities and Activity Votes
-- Studio Pair - Shared Life Management Platform
-- ============================================================================
-- Shared activity bucket-list with voting. Supports linking activities
-- to calendar events and tasks, external media references, and privacy
-- controls.
-- ============================================================================

-- ==========================================================================
-- ENUM: activity_category
-- ==========================================================================
CREATE TYPE activity_category AS ENUM (
    'movies',
    'series_tv',
    'video_games',
    'music_concerts',
    'events_festivals',
    'sports',
    'arts_exhibitions',
    'travel_trips',
    'restaurants_dining',
    'museums',
    'theater_shows',
    'books_reading',
    'board_games',
    'outdoor_activities',
    'wellness_spa',
    'cooking_recipes',
    'diy_crafts',
    'photography',
    'night_out_bars',
    'shopping',
    'escape_rooms',
    'amusement_parks',
    'hiking_nature',
    'beach_water',
    'winter_sports',
    'cultural_events',
    'volunteering',
    'classes_workshops',
    'sexual_fantasies',
    'other'
);

-- ==========================================================================
-- ENUM: activity_privacy
-- ==========================================================================
CREATE TYPE activity_privacy AS ENUM (
    'public',
    'private'
);

-- ==========================================================================
-- ENUM: activity_status
-- ==========================================================================
CREATE TYPE activity_status AS ENUM (
    'active',
    'completed',
    'deleted'
);

-- ==========================================================================
-- ENUM: activity_mode
-- ==========================================================================
CREATE TYPE activity_mode AS ENUM (
    'unlinked',
    'date_linked_personal',
    'date_linked_space'
);

-- ==========================================================================
-- TABLE: activities
-- ==========================================================================
-- Shared activities (things to do together). Each activity can be voted on
-- by space members, linked to external media, and optionally linked to a
-- calendar event or task for scheduling.
-- ==========================================================================
CREATE TABLE activities (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id                UUID              NOT NULL REFERENCES spaces(id)  ON DELETE CASCADE,
    created_by              UUID              NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
    title                   VARCHAR(255)      NOT NULL,
    description             TEXT,
    category                activity_category NOT NULL,
    thumbnail_url           TEXT,
    trailer_url             TEXT,
    external_id             VARCHAR(255),       -- e.g., TMDB ID, IGDB ID
    external_source         VARCHAR(100),       -- e.g., 'tmdb', 'igdb', 'google_places'
    privacy                 activity_privacy  NOT NULL DEFAULT 'public',
    status                  activity_status   NOT NULL DEFAULT 'active',
    mode                    activity_mode     NOT NULL DEFAULT 'unlinked',

    -- Cross-module links
    linked_calendar_event_id UUID,
    linked_task_id           UUID,

    -- Completion tracking
    completed_at            TIMESTAMPTZ,
    completed_notes         TEXT,

    -- Flexible metadata (ratings, runtime, platform availability, etc.)
    metadata                JSONB,

    -- Timestamps
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT activities_title_not_empty CHECK (length(trim(title)) > 0)
);

-- List activities for a space (active only)
CREATE INDEX idx_activities_space_active
    ON activities (space_id, created_at DESC)
    WHERE deleted_at IS NULL AND status != 'deleted';

-- Filter by category within a space
CREATE INDEX idx_activities_space_category
    ON activities (space_id, category)
    WHERE deleted_at IS NULL;

-- Look up by external source + id
CREATE INDEX idx_activities_external
    ON activities (external_source, external_id)
    WHERE external_source IS NOT NULL AND external_id IS NOT NULL;

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_activities_updated_at
    BEFORE UPDATE ON activities
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE activities IS 'Shared activity bucket-list items with categories, voting, and cross-module linking.';

-- ==========================================================================
-- TABLE: activity_votes
-- ==========================================================================
-- Each user can vote once per activity with a score from 1 to 5.
-- ==========================================================================
CREATE TABLE activity_votes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id)      ON DELETE CASCADE,
    score       INT  NOT NULL,

    -- Timestamps
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT av_score_range CHECK (score >= 1 AND score <= 5)
);

-- One vote per user per activity
CREATE UNIQUE INDEX idx_av_activity_user
    ON activity_votes (activity_id, user_id);

-- Trigger: auto-update updated_at
CREATE TRIGGER trg_activity_votes_updated_at
    BEFORE UPDATE ON activity_votes
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE activity_votes IS 'Per-user vote (1-5 score) on shared activities.';
