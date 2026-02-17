import 'package:json_annotation/json_annotation.dart';

/// Category for activities.
@JsonEnum(valueField: 'value')
enum ActivityCategory {
  @JsonValue('movies')
  movies('movies', 'Movies', 'activity_category_movies'),

  @JsonValue('series_tv')
  seriesTv('series_tv', 'Series / TV', 'activity_category_series_tv'),

  @JsonValue('video_games')
  videoGames('video_games', 'Video Games', 'activity_category_video_games'),

  @JsonValue('music_concerts')
  musicConcerts(
    'music_concerts',
    'Music & Concerts',
    'activity_category_music_concerts',
  ),

  @JsonValue('events_festivals')
  eventsFestivals(
    'events_festivals',
    'Events & Festivals',
    'activity_category_events_festivals',
  ),

  @JsonValue('sports')
  sports('sports', 'Sports', 'activity_category_sports'),

  @JsonValue('arts_exhibitions')
  artsExhibitions(
    'arts_exhibitions',
    'Arts & Exhibitions',
    'activity_category_arts_exhibitions',
  ),

  @JsonValue('travel_trips')
  travelTrips(
    'travel_trips',
    'Travel & Trips',
    'activity_category_travel_trips',
  ),

  @JsonValue('restaurants_dining')
  restaurantsDining(
    'restaurants_dining',
    'Restaurants & Dining',
    'activity_category_restaurants_dining',
  ),

  @JsonValue('museums')
  museums('museums', 'Museums', 'activity_category_museums'),

  @JsonValue('theater_shows')
  theaterShows(
    'theater_shows',
    'Theater & Shows',
    'activity_category_theater_shows',
  ),

  @JsonValue('books_reading')
  booksReading(
    'books_reading',
    'Books & Reading',
    'activity_category_books_reading',
  ),

  @JsonValue('board_games')
  boardGames('board_games', 'Board Games', 'activity_category_board_games'),

  @JsonValue('outdoor_activities')
  outdoorActivities(
    'outdoor_activities',
    'Outdoor Activities',
    'activity_category_outdoor_activities',
  ),

  @JsonValue('wellness_spa')
  wellnessSpa(
    'wellness_spa',
    'Wellness & Spa',
    'activity_category_wellness_spa',
  ),

  @JsonValue('cooking_recipes')
  cookingRecipes(
    'cooking_recipes',
    'Cooking & Recipes',
    'activity_category_cooking_recipes',
  ),

  @JsonValue('diy_crafts')
  diyCrafts('diy_crafts', 'DIY & Crafts', 'activity_category_diy_crafts'),

  @JsonValue('photography')
  photography('photography', 'Photography', 'activity_category_photography'),

  @JsonValue('night_out_bars')
  nightOutBars(
    'night_out_bars',
    'Night Out & Bars',
    'activity_category_night_out_bars',
  ),

  @JsonValue('shopping')
  shopping('shopping', 'Shopping', 'activity_category_shopping'),

  @JsonValue('escape_rooms')
  escapeRooms('escape_rooms', 'Escape Rooms', 'activity_category_escape_rooms'),

  @JsonValue('amusement_parks')
  amusementParks(
    'amusement_parks',
    'Amusement Parks',
    'activity_category_amusement_parks',
  ),

  @JsonValue('hiking_nature')
  hikingNature(
    'hiking_nature',
    'Hiking & Nature',
    'activity_category_hiking_nature',
  ),

  @JsonValue('beach_water')
  beachWater('beach_water', 'Beach & Water', 'activity_category_beach_water'),

  @JsonValue('winter_sports')
  winterSports(
    'winter_sports',
    'Winter Sports',
    'activity_category_winter_sports',
  ),

  @JsonValue('cultural_events')
  culturalEvents(
    'cultural_events',
    'Cultural Events',
    'activity_category_cultural_events',
  ),

  @JsonValue('volunteering')
  volunteering(
    'volunteering',
    'Volunteering',
    'activity_category_volunteering',
  ),

  @JsonValue('classes_workshops')
  classesWorkshops(
    'classes_workshops',
    'Classes & Workshops',
    'activity_category_classes_workshops',
  ),

  @JsonValue('sexual_fantasies')
  sexualFantasies(
    'sexual_fantasies',
    'Sexual Fantasies',
    'activity_category_sexual_fantasies',
  ),

  @JsonValue('other')
  other('other', 'Other', 'activity_category_other');

  const ActivityCategory(this.value, this.label, this.i18nKey);

  final String value;
  final String label;
  final String i18nKey;
}
