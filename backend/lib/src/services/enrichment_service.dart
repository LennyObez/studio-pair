import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../config/app_config.dart';

/// Normalized metadata format for activity enrichment results.
///
/// All external API responses are transformed into this common shape
/// for consistent handling across the app.
class ActivityMetadata {
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? trailerUrl;
  final int? year;
  final double? rating;
  final List<String> genres;
  final String? externalId;
  final String externalSource;

  const ActivityMetadata({
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.trailerUrl,
    this.year,
    this.rating,
    this.genres = const [],
    this.externalId,
    required this.externalSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'trailer_url': trailerUrl,
      'year': year,
      'rating': rating,
      'genres': genres,
      'external_id': externalId,
      'external_source': externalSource,
    };
  }
}

/// Service for enriching activities with external metadata.
///
/// Integrates with TMDb (movies/TV), RAWG (games), and YouTube (trailers)
/// to provide rich metadata for activity suggestions.
class EnrichmentService {
  final AppConfig _config;
  final http.Client _httpClient;
  final Logger _log = Logger('EnrichmentService');

  /// TMDb API base URL.
  static const _tmdbBaseUrl = 'https://api.themoviedb.org/3';

  /// TMDb image base URL for poster/backdrop images.
  static const _tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// RAWG API base URL.
  static const _rawgBaseUrl = 'https://api.rawg.io/api';

  /// YouTube Data API v3 base URL.
  static const _youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';

  EnrichmentService(this._config, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  // ---------------------------------------------------------------------------
  // Movies (TMDb)
  // ---------------------------------------------------------------------------

  /// Searches for movies using the TMDb API.
  ///
  /// Returns a list of [ActivityMetadata] results normalized from TMDb's
  /// movie search endpoint.
  Future<List<ActivityMetadata>> searchMovies(String query) async {
    if (_config.tmdbApiKey.isEmpty) {
      _log.warning('TMDb API key not configured, skipping movie search');
      return [];
    }

    try {
      final uri = Uri.parse('$_tmdbBaseUrl/search/movie').replace(
        queryParameters: {
          'api_key': _config.tmdbApiKey,
          'query': query,
          'language': 'en-US',
          'page': '1',
          'include_adult': 'false',
        },
      );

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        _log.warning('TMDb movie search failed: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      // Fetch genre map for this request
      final genreMap = await _getTmdbMovieGenres();

      return results.take(10).map((item) {
        final movie = item as Map<String, dynamic>;
        final genreIds =
            (movie['genre_ids'] as List<dynamic>?)
                ?.map((id) => id as int)
                .toList() ??
            [];
        final genres = genreIds
            .map((id) => genreMap[id])
            .where((name) => name != null)
            .cast<String>()
            .toList();

        final releaseDate = movie['release_date'] as String?;
        int? year;
        if (releaseDate != null && releaseDate.length >= 4) {
          year = int.tryParse(releaseDate.substring(0, 4));
        }

        final posterPath = movie['poster_path'] as String?;

        return ActivityMetadata(
          title: movie['title'] as String? ?? 'Unknown',
          description: movie['overview'] as String?,
          thumbnailUrl: posterPath != null
              ? '$_tmdbImageBaseUrl$posterPath'
              : null,
          year: year,
          rating: (movie['vote_average'] as num?)?.toDouble(),
          genres: genres,
          externalId: movie['id']?.toString(),
          externalSource: 'tmdb_movie',
        );
      }).toList();
    } catch (e, stackTrace) {
      _log.severe('TMDb movie search error', e, stackTrace);
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // TV Shows (TMDb)
  // ---------------------------------------------------------------------------

  /// Searches for TV shows using the TMDb API.
  ///
  /// Returns a list of [ActivityMetadata] results normalized from TMDb's
  /// TV search endpoint.
  Future<List<ActivityMetadata>> searchTvShows(String query) async {
    if (_config.tmdbApiKey.isEmpty) {
      _log.warning('TMDb API key not configured, skipping TV search');
      return [];
    }

    try {
      final uri = Uri.parse('$_tmdbBaseUrl/search/tv').replace(
        queryParameters: {
          'api_key': _config.tmdbApiKey,
          'query': query,
          'language': 'en-US',
          'page': '1',
        },
      );

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        _log.warning('TMDb TV search failed: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      final genreMap = await _getTmdbTvGenres();

      return results.take(10).map((item) {
        final show = item as Map<String, dynamic>;
        final genreIds =
            (show['genre_ids'] as List<dynamic>?)
                ?.map((id) => id as int)
                .toList() ??
            [];
        final genres = genreIds
            .map((id) => genreMap[id])
            .where((name) => name != null)
            .cast<String>()
            .toList();

        final firstAirDate = show['first_air_date'] as String?;
        int? year;
        if (firstAirDate != null && firstAirDate.length >= 4) {
          year = int.tryParse(firstAirDate.substring(0, 4));
        }

        final posterPath = show['poster_path'] as String?;

        return ActivityMetadata(
          title: show['name'] as String? ?? 'Unknown',
          description: show['overview'] as String?,
          thumbnailUrl: posterPath != null
              ? '$_tmdbImageBaseUrl$posterPath'
              : null,
          year: year,
          rating: (show['vote_average'] as num?)?.toDouble(),
          genres: genres,
          externalId: show['id']?.toString(),
          externalSource: 'tmdb_tv',
        );
      }).toList();
    } catch (e, stackTrace) {
      _log.severe('TMDb TV search error', e, stackTrace);
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Video Games (RAWG)
  // ---------------------------------------------------------------------------

  /// Searches for video games using the RAWG API.
  ///
  /// Returns a list of [ActivityMetadata] results normalized from RAWG's
  /// games search endpoint.
  Future<List<ActivityMetadata>> searchGames(String query) async {
    if (_config.rawgApiKey.isEmpty) {
      _log.warning('RAWG API key not configured, skipping game search');
      return [];
    }

    try {
      final uri = Uri.parse('$_rawgBaseUrl/games').replace(
        queryParameters: {
          'key': _config.rawgApiKey,
          'search': query,
          'page_size': '10',
          'search_precise': 'true',
        },
      );

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        _log.warning('RAWG game search failed: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results.take(10).map((item) {
        final game = item as Map<String, dynamic>;

        final genres =
            (game['genres'] as List<dynamic>?)
                ?.map((g) => (g as Map<String, dynamic>)['name'] as String)
                .toList() ??
            [];

        final released = game['released'] as String?;
        int? year;
        if (released != null && released.length >= 4) {
          year = int.tryParse(released.substring(0, 4));
        }

        return ActivityMetadata(
          title: game['name'] as String? ?? 'Unknown',
          description: game['description_raw'] as String?,
          thumbnailUrl: game['background_image'] as String?,
          year: year,
          rating: (game['rating'] as num?)?.toDouble(),
          genres: genres,
          externalId: game['id']?.toString(),
          externalSource: 'rawg',
        );
      }).toList();
    } catch (e, stackTrace) {
      _log.severe('RAWG game search error', e, stackTrace);
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Trailers (YouTube)
  // ---------------------------------------------------------------------------

  /// Searches for trailers on YouTube.
  ///
  /// Appends "official trailer" to the query for better results.
  /// Returns a list of [ActivityMetadata] with trailer URLs.
  Future<List<ActivityMetadata>> searchTrailers(String query) async {
    if (_config.youtubeApiKey.isEmpty) {
      _log.warning('YouTube API key not configured, skipping trailer search');
      return [];
    }

    try {
      final searchQuery = '$query official trailer';
      final uri = Uri.parse('$_youtubeBaseUrl/search').replace(
        queryParameters: {
          'key': _config.youtubeApiKey,
          'q': searchQuery,
          'part': 'snippet',
          'type': 'video',
          'maxResults': '5',
          'videoCategoryId': '24', // Entertainment
        },
      );

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        _log.warning('YouTube search failed: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      return items.map((item) {
        final video = item as Map<String, dynamic>;
        final snippet = video['snippet'] as Map<String, dynamic>? ?? {};
        final videoId =
            (video['id'] as Map<String, dynamic>?)?['videoId'] as String?;

        final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
        final thumbnailUrl =
            (thumbnails?['high'] as Map<String, dynamic>?)?['url'] as String? ??
            (thumbnails?['medium'] as Map<String, dynamic>?)?['url']
                as String? ??
            (thumbnails?['default'] as Map<String, dynamic>?)?['url']
                as String?;

        final publishedAt = snippet['publishedAt'] as String?;
        int? year;
        if (publishedAt != null && publishedAt.length >= 4) {
          year = int.tryParse(publishedAt.substring(0, 4));
        }

        return ActivityMetadata(
          title: snippet['title'] as String? ?? 'Unknown',
          description: snippet['description'] as String?,
          thumbnailUrl: thumbnailUrl,
          trailerUrl: videoId != null
              ? 'https://www.youtube.com/watch?v=$videoId'
              : null,
          year: year,
          externalId: videoId,
          externalSource: 'youtube',
        );
      }).toList();
    } catch (e, stackTrace) {
      _log.severe('YouTube search error', e, stackTrace);
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // TMDb Genre Helpers
  // ---------------------------------------------------------------------------

  /// Cache for TMDb movie genre map.
  Map<int, String>? _movieGenreCache;

  /// Cache for TMDb TV genre map.
  Map<int, String>? _tvGenreCache;

  /// Fetches and caches the TMDb movie genre ID-to-name mapping.
  Future<Map<int, String>> _getTmdbMovieGenres() async {
    if (_movieGenreCache != null) return _movieGenreCache!;

    try {
      final uri = Uri.parse('$_tmdbBaseUrl/genre/movie/list').replace(
        queryParameters: {'api_key': _config.tmdbApiKey, 'language': 'en-US'},
      );

      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final genres = data['genres'] as List<dynamic>? ?? [];
        _movieGenreCache = {
          for (final g in genres)
            (g as Map<String, dynamic>)['id'] as int: g['name'] as String,
        };
        return _movieGenreCache!;
      }
    } catch (e) {
      _log.warning('Failed to fetch TMDb movie genres', e);
    }

    return {};
  }

  /// Fetches and caches the TMDb TV genre ID-to-name mapping.
  Future<Map<int, String>> _getTmdbTvGenres() async {
    if (_tvGenreCache != null) return _tvGenreCache!;

    try {
      final uri = Uri.parse('$_tmdbBaseUrl/genre/tv/list').replace(
        queryParameters: {'api_key': _config.tmdbApiKey, 'language': 'en-US'},
      );

      final response = await _httpClient.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final genres = data['genres'] as List<dynamic>? ?? [];
        _tvGenreCache = {
          for (final g in genres)
            (g as Map<String, dynamic>)['id'] as int: g['name'] as String,
        };
        return _tvGenreCache!;
      }
    } catch (e) {
      _log.warning('Failed to fetch TMDb TV genres', e);
    }

    return {};
  }
}
