/// Simple i18n class for Studio Pair using static translation maps.
///
/// Supports English (en) and French (fr).
abstract final class AppLocalizations {
  /// All translations indexed by locale, then by key.
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // General
      'app_name': 'Studio Pair',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'create_space': 'Create Space',
      'join_space': 'Join Space',

      // Module names
      'activities': 'Activities',
      'calendar': 'Calendar',
      'messages': 'Messages',
      'finances': 'Finances',
      'health': 'Health',
      'tasks': 'Tasks',
      'reminders': 'Reminders',
      'files': 'Files',
      'memories': 'Memories',
      'charter': 'Charter',
      'grocery_list': 'Grocery List',
      'polls': 'Polls',
      'location': 'Location',
      'settings': 'Settings',
      'profile': 'Profile',
      'logout': 'Logout',

      // Actions
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',

      // States
      'loading': 'Loading...',
      'error': 'An error occurred',
      'success': 'Success',
      'no_data': 'No data available',
      'retry': 'Retry',

      // Activity categories
      'activity_category_movies': 'Movies',
      'activity_category_series_tv': 'Series / TV',
      'activity_category_video_games': 'Video Games',
      'activity_category_music_concerts': 'Music & Concerts',
      'activity_category_events_festivals': 'Events & Festivals',
      'activity_category_sports': 'Sports',
      'activity_category_arts_exhibitions': 'Arts & Exhibitions',
      'activity_category_travel_trips': 'Travel & Trips',
      'activity_category_restaurants_dining': 'Restaurants & Dining',
      'activity_category_museums': 'Museums',
      'activity_category_theater_shows': 'Theater & Shows',
      'activity_category_books_reading': 'Books & Reading',
      'activity_category_board_games': 'Board Games',
      'activity_category_outdoor_activities': 'Outdoor Activities',
      'activity_category_wellness_spa': 'Wellness & Spa',
      'activity_category_cooking_recipes': 'Cooking & Recipes',
      'activity_category_diy_crafts': 'DIY & Crafts',
      'activity_category_photography': 'Photography',
      'activity_category_night_out_bars': 'Night Out & Bars',
      'activity_category_shopping': 'Shopping',
      'activity_category_escape_rooms': 'Escape Rooms',
      'activity_category_amusement_parks': 'Amusement Parks',
      'activity_category_hiking_nature': 'Hiking & Nature',
      'activity_category_beach_water': 'Beach & Water',
      'activity_category_winter_sports': 'Winter Sports',
      'activity_category_cultural_events': 'Cultural Events',
      'activity_category_volunteering': 'Volunteering',
      'activity_category_classes_workshops': 'Classes & Workshops',
      'activity_category_sexual_fantasies': 'Sexual Fantasies',
      'activity_category_other': 'Other',
    },
    'fr': {
      // General
      'app_name': 'Studio Pair',
      'login': 'Connexion',
      'register': 'Inscription',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'forgot_password': 'Mot de passe oublie ?',
      'create_space': 'Creer un espace',
      'join_space': 'Rejoindre un espace',

      // Module names
      'activities': 'Activites',
      'calendar': 'Calendrier',
      'messages': 'Messages',
      'finances': 'Finances',
      'health': 'Sante',
      'tasks': 'Taches',
      'reminders': 'Rappels',
      'files': 'Fichiers',
      'memories': 'Souvenirs',
      'charter': 'Charte',
      'grocery_list': 'Liste de courses',
      'polls': 'Sondages',
      'location': 'Localisation',
      'settings': 'Parametres',
      'profile': 'Profil',
      'logout': 'Deconnexion',

      // Actions
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'search': 'Rechercher',

      // States
      'loading': 'Chargement...',
      'error': 'Une erreur est survenue',
      'success': 'Succes',
      'no_data': 'Aucune donnee disponible',
      'retry': 'Reessayer',

      // Activity categories
      'activity_category_movies': 'Films',
      'activity_category_series_tv': 'Series / TV',
      'activity_category_video_games': 'Jeux video',
      'activity_category_music_concerts': 'Musique & Concerts',
      'activity_category_events_festivals': 'Evenements & Festivals',
      'activity_category_sports': 'Sports',
      'activity_category_arts_exhibitions': 'Arts & Expositions',
      'activity_category_travel_trips': 'Voyages & Excursions',
      'activity_category_restaurants_dining': 'Restaurants & Gastronomie',
      'activity_category_museums': 'Musees',
      'activity_category_theater_shows': 'Theatre & Spectacles',
      'activity_category_books_reading': 'Livres & Lecture',
      'activity_category_board_games': 'Jeux de societe',
      'activity_category_outdoor_activities': 'Activites en plein air',
      'activity_category_wellness_spa': 'Bien-etre & Spa',
      'activity_category_cooking_recipes': 'Cuisine & Recettes',
      'activity_category_diy_crafts': 'Bricolage & Loisirs creatifs',
      'activity_category_photography': 'Photographie',
      'activity_category_night_out_bars': 'Sorties & Bars',
      'activity_category_shopping': 'Shopping',
      'activity_category_escape_rooms': 'Escape Games',
      'activity_category_amusement_parks': 'Parcs d\'attractions',
      'activity_category_hiking_nature': 'Randonnee & Nature',
      'activity_category_beach_water': 'Plage & Nautisme',
      'activity_category_winter_sports': 'Sports d\'hiver',
      'activity_category_cultural_events': 'Evenements culturels',
      'activity_category_volunteering': 'Benevolat',
      'activity_category_classes_workshops': 'Cours & Ateliers',
      'activity_category_sexual_fantasies': 'Fantasmes sexuels',
      'activity_category_other': 'Autre',
    },
  };

  /// Translates a key for the given locale.
  ///
  /// Falls back to English if the key is not found in the given locale.
  /// Returns the key itself if no translation is found in any locale.
  static String translate(String key, [String locale = 'en']) {
    final localeTranslations = _translations[locale];
    if (localeTranslations != null && localeTranslations.containsKey(key)) {
      return localeTranslations[key]!;
    }

    // Fallback to English
    final enTranslations = _translations['en'];
    if (enTranslations != null && enTranslations.containsKey(key)) {
      return enTranslations[key]!;
    }

    // Return the key if no translation found
    return key;
  }

  /// Returns all available translation keys.
  static Set<String> get keys {
    final allKeys = <String>{};
    for (final locale in _translations.values) {
      allKeys.addAll(locale.keys);
    }
    return allKeys;
  }

  /// Returns all supported locale codes.
  static List<String> get supportedLocales => _translations.keys.toList();
}
