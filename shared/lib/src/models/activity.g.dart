// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Activity _$ActivityFromJson(Map<String, dynamic> json) => _Activity(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  createdBy: json['created_by'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  category: $enumDecode(_$ActivityCategoryEnumMap, json['category']),
  thumbnailUrl: json['thumbnail_url'] as String?,
  trailerUrl: json['trailer_url'] as String?,
  externalId: json['external_id'] as String?,
  externalSource: json['external_source'] as String?,
  privacy: $enumDecode(_$ActivityPrivacyEnumMap, json['privacy']),
  status: $enumDecode(_$ActivityStatusEnumMap, json['status']),
  mode: $enumDecode(_$ActivityModeEnumMap, json['mode']),
  linkedCalendarEventId: json['linked_calendar_event_id'] as String?,
  linkedTaskId: json['linked_task_id'] as String?,
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  completedNotes: json['completed_notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ActivityToJson(_Activity instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'created_by': instance.createdBy,
  'title': instance.title,
  'description': instance.description,
  'category': _$ActivityCategoryEnumMap[instance.category]!,
  'thumbnail_url': instance.thumbnailUrl,
  'trailer_url': instance.trailerUrl,
  'external_id': instance.externalId,
  'external_source': instance.externalSource,
  'privacy': _$ActivityPrivacyEnumMap[instance.privacy]!,
  'status': _$ActivityStatusEnumMap[instance.status]!,
  'mode': _$ActivityModeEnumMap[instance.mode]!,
  'linked_calendar_event_id': instance.linkedCalendarEventId,
  'linked_task_id': instance.linkedTaskId,
  'completed_at': instance.completedAt?.toIso8601String(),
  'completed_notes': instance.completedNotes,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$ActivityCategoryEnumMap = {
  ActivityCategory.movies: 'movies',
  ActivityCategory.seriesTv: 'series_tv',
  ActivityCategory.videoGames: 'video_games',
  ActivityCategory.musicConcerts: 'music_concerts',
  ActivityCategory.eventsFestivals: 'events_festivals',
  ActivityCategory.sports: 'sports',
  ActivityCategory.artsExhibitions: 'arts_exhibitions',
  ActivityCategory.travelTrips: 'travel_trips',
  ActivityCategory.restaurantsDining: 'restaurants_dining',
  ActivityCategory.museums: 'museums',
  ActivityCategory.theaterShows: 'theater_shows',
  ActivityCategory.booksReading: 'books_reading',
  ActivityCategory.boardGames: 'board_games',
  ActivityCategory.outdoorActivities: 'outdoor_activities',
  ActivityCategory.wellnessSpa: 'wellness_spa',
  ActivityCategory.cookingRecipes: 'cooking_recipes',
  ActivityCategory.diyCrafts: 'diy_crafts',
  ActivityCategory.photography: 'photography',
  ActivityCategory.nightOutBars: 'night_out_bars',
  ActivityCategory.shopping: 'shopping',
  ActivityCategory.escapeRooms: 'escape_rooms',
  ActivityCategory.amusementParks: 'amusement_parks',
  ActivityCategory.hikingNature: 'hiking_nature',
  ActivityCategory.beachWater: 'beach_water',
  ActivityCategory.winterSports: 'winter_sports',
  ActivityCategory.culturalEvents: 'cultural_events',
  ActivityCategory.volunteering: 'volunteering',
  ActivityCategory.classesWorkshops: 'classes_workshops',
  ActivityCategory.sexualFantasies: 'sexual_fantasies',
  ActivityCategory.other: 'other',
};

const _$ActivityPrivacyEnumMap = {
  ActivityPrivacy.public_: 'public',
  ActivityPrivacy.private_: 'private',
};

const _$ActivityStatusEnumMap = {
  ActivityStatus.active: 'active',
  ActivityStatus.completed: 'completed',
  ActivityStatus.deleted: 'deleted',
};

const _$ActivityModeEnumMap = {
  ActivityMode.unlinked: 'unlinked',
  ActivityMode.dateLinkedPersonal: 'date_linked_personal',
  ActivityMode.dateLinkedSpace: 'date_linked_space',
};
