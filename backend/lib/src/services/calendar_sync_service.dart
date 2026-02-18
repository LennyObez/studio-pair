import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../config/database.dart';

// =============================================================================
// Abstract Calendar Provider
// =============================================================================

/// Abstract interface for external calendar providers.
///
/// Each provider (Google, Apple, Outlook) implements this contract to exchange
/// auth codes for tokens, refresh tokens, and perform CRUD on remote events.
abstract class CalendarProvider {
  /// Exchanges an authorization code for access and refresh tokens.
  Future<Map<String, dynamic>> authenticate(String code, String redirectUri);

  /// Refreshes an expired access token using a refresh token.
  Future<Map<String, dynamic>> refreshToken(String refreshToken);

  /// Fetches events from the external calendar within a time range.
  Future<List<Map<String, dynamic>>> fetchEvents(
    String accessToken,
    String calendarId,
    DateTime timeMin,
    DateTime timeMax,
  );

  /// Creates an event in the external calendar.
  Future<Map<String, dynamic>> createEvent(
    String accessToken,
    String calendarId,
    Map<String, dynamic> event,
  );

  /// Updates an existing event in the external calendar.
  Future<Map<String, dynamic>> updateEvent(
    String accessToken,
    String calendarId,
    String eventId,
    Map<String, dynamic> event,
  );

  /// Deletes an event from the external calendar.
  Future<void> deleteEvent(
    String accessToken,
    String calendarId,
    String eventId,
  );
}

// =============================================================================
// Google Calendar Provider
// =============================================================================

/// Google Calendar API v3 implementation of [CalendarProvider].
///
/// Uses OAuth 2.0 for authentication and the Google Calendar REST API
/// for event CRUD operations.
class GoogleCalendarProvider implements CalendarProvider {
  final http.Client _httpClient;
  final Logger _log = Logger('GoogleCalendarProvider');

  /// Google OAuth 2.0 token endpoint.
  static const _tokenUrl = 'https://oauth2.googleapis.com/token';

  /// Google Calendar API v3 base URL.
  static const _calendarApiBase = 'https://www.googleapis.com/calendar/v3';

  /// OAuth client ID for Google Calendar integration.
  final String clientId;

  /// OAuth client secret for Google Calendar integration.
  final String clientSecret;

  GoogleCalendarProvider({
    required this.clientId,
    required this.clientSecret,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  Future<Map<String, dynamic>> authenticate(
    String code,
    String redirectUri,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'code': code,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
        },
      );

      if (response.statusCode != 200) {
        _log.warning(
          'Google auth token exchange failed: '
          '${response.statusCode} ${response.body}',
        );
        throw CalendarSyncException(
          'Failed to exchange authorization code: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'access_token': data['access_token'] as String,
        'refresh_token': data['refresh_token'] as String?,
        'expires_in': data['expires_in'] as int?,
        'token_type': data['token_type'] as String?,
      };
    } catch (e) {
      if (e is CalendarSyncException) rethrow;
      _log.severe('Google auth error', e);
      throw CalendarSyncException('Google authentication failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'refresh_token': refreshToken,
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode != 200) {
        _log.warning(
          'Google token refresh failed: '
          '${response.statusCode} ${response.body}',
        );
        throw CalendarSyncException(
          'Failed to refresh access token: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'access_token': data['access_token'] as String,
        'expires_in': data['expires_in'] as int?,
        'token_type': data['token_type'] as String?,
      };
    } catch (e) {
      if (e is CalendarSyncException) rethrow;
      _log.severe('Google token refresh error', e);
      throw CalendarSyncException('Google token refresh failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEvents(
    String accessToken,
    String calendarId,
    DateTime timeMin,
    DateTime timeMax,
  ) async {
    try {
      final uri =
          Uri.parse(
            '$_calendarApiBase/calendars/${Uri.encodeComponent(calendarId)}/events',
          ).replace(
            queryParameters: {
              'timeMin': timeMin.toUtc().toIso8601String(),
              'timeMax': timeMax.toUtc().toIso8601String(),
              'singleEvents': 'true',
              'orderBy': 'startTime',
              'maxResults': '250',
            },
          );

      final response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        _log.warning(
          'Google Calendar fetch events failed: '
          '${response.statusCode} ${response.body}',
        );
        throw CalendarSyncException(
          'Failed to fetch events: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      return items.map((item) {
        final event = item as Map<String, dynamic>;
        return _normalizeGoogleEvent(event);
      }).toList();
    } catch (e) {
      if (e is CalendarSyncException) rethrow;
      _log.severe('Google Calendar fetch events error', e);
      throw CalendarSyncException('Failed to fetch Google Calendar events: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createEvent(
    String accessToken,
    String calendarId,
    Map<String, dynamic> event,
  ) async {
    try {
      final uri = Uri.parse(
        '$_calendarApiBase/calendars/${Uri.encodeComponent(calendarId)}/events',
      );

      final googleEvent = _toGoogleEvent(event);

      final response = await _httpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(googleEvent),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _log.warning(
          'Google Calendar create event failed: '
          '${response.statusCode} ${response.body}',
        );
        throw CalendarSyncException(
          'Failed to create event: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _normalizeGoogleEvent(data);
    } catch (e) {
      if (e is CalendarSyncException) rethrow;
      _log.severe('Google Calendar create event error', e);
      throw CalendarSyncException('Failed to create Google Calendar event: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateEvent(
    String accessToken,
    String calendarId,
    String eventId,
    Map<String, dynamic> event,
  ) async {
    try {
      final uri = Uri.parse(
        '$_calendarApiBase/calendars/${Uri.encodeComponent(calendarId)}'
        '/events/${Uri.encodeComponent(eventId)}',
      );

      final googleEvent = _toGoogleEvent(event);

      final response = await _httpClient.put(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(googleEvent),
      );

      if (response.statusCode != 200) {
        _log.warning(
          'Google Calendar update event failed: '
          '${response.statusCode} ${response.body}',
        );
        throw CalendarSyncException(
          'Failed to update event: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _normalizeGoogleEvent(data);
    } catch (e) {
      if (e is CalendarSyncException) rethrow;
      _log.severe('Google Calendar update event error', e);
      throw CalendarSyncException('Failed to update Google Calendar event: $e');
    }
  }

  @override
  Future<void> deleteEvent(
    String accessToken,
    String calendarId,
    String eventId,
  ) async {
    try {
      final uri = Uri.parse(
        '$_calendarApiBase/calendars/${Uri.encodeComponent(calendarId)}'
        '/events/${Uri.encodeComponent(eventId)}',
      );

      final response = await _httpClient.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        _log.warning(
          'Google Calendar delete event failed: '
          '${response.statusCode} ${response.body}',
        );
        throw CalendarSyncException(
          'Failed to delete event: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is CalendarSyncException) rethrow;
      _log.severe('Google Calendar delete event error', e);
      throw CalendarSyncException('Failed to delete Google Calendar event: $e');
    }
  }

  /// Normalizes a Google Calendar event into a common internal format.
  Map<String, dynamic> _normalizeGoogleEvent(Map<String, dynamic> event) {
    final start = event['start'] as Map<String, dynamic>?;
    final end = event['end'] as Map<String, dynamic>?;

    // Google uses dateTime for timed events, date for all-day events
    final allDay = start?['date'] != null;
    final startAt = allDay
        ? (start?['date'] as String?)
        : (start?['dateTime'] as String?);
    final endAt = allDay
        ? (end?['date'] as String?)
        : (end?['dateTime'] as String?);

    return {
      'external_id': event['id'] as String?,
      'title': event['summary'] as String? ?? '',
      'description': event['description'] as String?,
      'location': event['location'] as String?,
      'all_day': allDay,
      'start_at': startAt,
      'end_at': endAt,
      'recurrence_rule': _extractRecurrenceRule(event),
      'status': event['status'] as String?,
      'html_link': event['htmlLink'] as String?,
    };
  }

  /// Converts an internal event map to Google Calendar event format.
  Map<String, dynamic> _toGoogleEvent(Map<String, dynamic> event) {
    final allDay = event['all_day'] as bool? ?? false;
    final result = <String, dynamic>{
      'summary': event['title'] as String? ?? '',
    };

    if (event['description'] != null) {
      result['description'] = event['description'];
    }
    if (event['location'] != null) {
      result['location'] = event['location'];
    }

    if (allDay) {
      result['start'] = {'date': _toDateString(event['start_at'])};
      result['end'] = {'date': _toDateString(event['end_at'])};
    } else {
      result['start'] = {'dateTime': event['start_at']};
      result['end'] = {'dateTime': event['end_at']};
    }

    if (event['recurrence_rule'] != null) {
      result['recurrence'] = ['RRULE:${event['recurrence_rule']}'];
    }

    return result;
  }

  /// Extracts RRULE from a Google Calendar event's recurrence array.
  String? _extractRecurrenceRule(Map<String, dynamic> event) {
    final recurrence = event['recurrence'] as List<dynamic>?;
    if (recurrence == null || recurrence.isEmpty) return null;

    for (final rule in recurrence) {
      final ruleStr = rule as String;
      if (ruleStr.startsWith('RRULE:')) {
        return ruleStr.substring(6);
      }
    }
    return null;
  }

  /// Converts an ISO datetime string to a date-only string (YYYY-MM-DD).
  String _toDateString(dynamic dateTimeStr) {
    if (dateTimeStr is String && dateTimeStr.length >= 10) {
      return dateTimeStr.substring(0, 10);
    }
    return dateTimeStr?.toString() ?? '';
  }
}

// =============================================================================
// Calendar Sync Service
// =============================================================================

/// Service for managing external calendar connections and syncing events.
///
/// Coordinates between external calendar providers and the internal
/// calendar_events table, storing connection metadata in calendar_sync_connections.
class CalendarSyncService {
  final Database _db;
  final Logger _log = Logger('CalendarSyncService');
  final Uuid _uuid = const Uuid();

  CalendarSyncService(this._db);

  // ---------------------------------------------------------------------------
  // Connection Management
  // ---------------------------------------------------------------------------

  /// Adds a new external calendar connection.
  ///
  /// Stores the provider credentials (encrypted as JSON) and connection
  /// metadata. Returns the created connection record.
  Future<Map<String, dynamic>> addConnection({
    required String spaceId,
    required String userId,
    required String provider,
    required String accessToken,
    required String refreshToken,
    DateTime? tokenExpiresAt,
    String syncDirection = 'import_only',
  }) async {
    final id = _uuid.v4();

    // Store tokens as encrypted JSON blob matching the existing schema
    final credentials = jsonEncode({
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_expires_at': tokenExpiresAt?.toUtc().toIso8601String(),
    });

    try {
      final result = await _db.query(
        '''
        INSERT INTO calendar_sync_connections
          (id, space_id, user_id, provider, credentials_encrypted,
           sync_direction, status, created_at, updated_at)
        VALUES
          (@id, @spaceId, @userId, @provider::calendar_provider,
           @credentials, @syncDirection::sync_direction, 'active', NOW(), NOW())
        RETURNING id, space_id, user_id, provider, sync_direction,
                  status, last_synced_at, created_at, updated_at
        ''',
        parameters: {
          'id': id,
          'spaceId': spaceId,
          'userId': userId,
          'provider': provider,
          'credentials': credentials,
          'syncDirection': syncDirection,
        },
      );

      _log.info(
        'Added $provider calendar connection for user $userId '
        'in space $spaceId',
      );
      return result.first.toColumnMap();
    } catch (e) {
      _log.severe('Failed to add calendar connection', e);
      throw CalendarSyncException('Failed to add calendar connection: $e');
    }
  }

  /// Removes an external calendar connection and its synced event mappings.
  Future<void> removeConnection(String connectionId) async {
    try {
      await _db.execute(
        '''
        DELETE FROM calendar_sync_connections
        WHERE id = @connectionId
        ''',
        parameters: {'connectionId': connectionId},
      );

      _log.info('Removed calendar connection $connectionId');
    } catch (e) {
      _log.severe('Failed to remove calendar connection $connectionId', e);
      throw CalendarSyncException('Failed to remove calendar connection: $e');
    }
  }

  /// Retrieves all calendar connections for a space.
  Future<List<Map<String, dynamic>>> getConnections(String spaceId) async {
    final result = await _db.query(
      '''
      SELECT id, space_id, user_id, provider, sync_direction,
             status, last_synced_at, created_at, updated_at
      FROM calendar_sync_connections
      WHERE space_id = @spaceId AND status = 'active'
      ORDER BY created_at DESC
      ''',
      parameters: {'spaceId': spaceId},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Retrieves a single calendar connection with decrypted credentials.
  Future<Map<String, dynamic>?> getConnectionWithCredentials(
    String connectionId,
  ) async {
    final row = await _db.queryOne(
      '''
      SELECT id, space_id, user_id, provider, credentials_encrypted,
             sync_direction, status, last_synced_at, created_at, updated_at
      FROM calendar_sync_connections
      WHERE id = @connectionId
      ''',
      parameters: {'connectionId': connectionId},
    );

    if (row == null) return null;

    final map = row.toColumnMap();

    // Parse credentials JSON to extract tokens
    final credStr = map['credentials_encrypted'] as String?;
    if (credStr != null) {
      try {
        final creds = jsonDecode(credStr) as Map<String, dynamic>;
        map['access_token'] = creds['access_token'];
        map['refresh_token'] = creds['refresh_token'];
        map['token_expires_at'] = creds['token_expires_at'];
      } catch (_) {
        // credentials may already be decrypted or in unexpected format
      }
    }

    return map;
  }

  // ---------------------------------------------------------------------------
  // Sync Operations
  // ---------------------------------------------------------------------------

  /// Syncs events for a single calendar connection.
  ///
  /// Fetches events from the external provider and upserts them into the
  /// internal calendar_events table, using calendar_sync_event_map for
  /// reconciliation.
  Future<int> syncCalendar(
    String connectionId,
    CalendarProvider provider, {
    DateTime? since,
    DateTime? until,
  }) async {
    final connection = await getConnectionWithCredentials(connectionId);
    if (connection == null) {
      throw CalendarSyncException('Connection $connectionId not found');
    }

    if (connection['status'] != 'active') {
      _log.fine('Sync disabled for connection $connectionId, skipping');
      return 0;
    }

    final accessToken = connection['access_token'] as String;
    final calendarId = connection['external_calendar_id'] as String;
    final spaceId = connection['space_id'] as String;
    final userId = connection['user_id'] as String;

    final timeMin = since ?? DateTime.now().subtract(const Duration(days: 30));
    final timeMax = until ?? DateTime.now().add(const Duration(days: 90));

    try {
      final externalEvents = await provider.fetchEvents(
        accessToken,
        calendarId,
        timeMin,
        timeMax,
      );

      var syncedCount = 0;

      for (final externalEvent in externalEvents) {
        await _upsertSyncedEvent(
          spaceId: spaceId,
          userId: userId,
          providerName: connection['provider'] as String,
          calendarId: calendarId,
          externalEvent: externalEvent,
        );
        syncedCount++;
      }

      // Update last_synced_at on the connection
      await _db.execute(
        '''
        UPDATE calendar_sync_connections
        SET last_synced_at = NOW()
        WHERE id = @connectionId
        ''',
        parameters: {'connectionId': connectionId},
      );

      _log.info('Synced $syncedCount events for connection $connectionId');
      return syncedCount;
    } catch (e) {
      _log.severe('Calendar sync failed for connection $connectionId', e);
      throw CalendarSyncException('Calendar sync failed: $e');
    }
  }

  /// Syncs all enabled calendar connections for a space.
  ///
  /// Returns a map of connection IDs to the number of events synced.
  Future<Map<String, int>> syncAllForSpace(
    String spaceId,
    CalendarProvider provider,
  ) async {
    final connections = await getConnections(spaceId);
    final results = <String, int>{};

    for (final connection in connections) {
      if (connection['status'] != 'active') continue;

      final connectionId = connection['id'] as String;
      try {
        final count = await syncCalendar(connectionId, provider);
        results[connectionId] = count;
      } catch (e) {
        _log.warning(
          'Sync failed for connection $connectionId in space $spaceId',
          e,
        );
        results[connectionId] = -1; // Indicates failure
      }
    }

    _log.info('Synced ${results.length} connections for space $spaceId');
    return results;
  }

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  /// Upserts a synced event into calendar_events and updates the sync map.
  Future<void> _upsertSyncedEvent({
    required String spaceId,
    required String userId,
    required String providerName,
    required String calendarId,
    required Map<String, dynamic> externalEvent,
  }) async {
    final externalId = externalEvent['external_id'] as String?;
    if (externalId == null) return;

    // Check if we already have a mapping for this external event
    final existingMap = await _db.queryOne(
      '''
      SELECT internal_event_id
      FROM calendar_sync_event_map
      WHERE provider = @provider AND external_event_id = @externalId
      ''',
      parameters: {'provider': providerName, 'externalId': externalId},
    );

    final title = externalEvent['title'] as String? ?? 'Untitled';
    final allDay = externalEvent['all_day'] as bool? ?? false;
    final startAt = externalEvent['start_at'] as String?;
    final endAt = externalEvent['end_at'] as String?;
    final location = externalEvent['location'] as String?;
    final recurrenceRule = externalEvent['recurrence_rule'] as String?;

    if (startAt == null || endAt == null) return;

    if (existingMap != null) {
      // Update existing internal event
      final internalEventId = existingMap[0] as String;
      await _db.execute(
        '''
        UPDATE calendar_events
        SET title = @title,
            location = @location,
            all_day = @allDay,
            start_at = @startAt,
            end_at = @endAt,
            recurrence_rule = @recurrenceRule,
            source_module = 'calendar_sync'
        WHERE id = @id AND deleted_at IS NULL
        ''',
        parameters: {
          'id': internalEventId,
          'title': title,
          'location': location,
          'allDay': allDay,
          'startAt': startAt,
          'endAt': endAt,
          'recurrenceRule': recurrenceRule,
        },
      );

      // Update sync map timestamp
      await _db.execute(
        '''
        UPDATE calendar_sync_event_map
        SET last_synced_at = NOW()
        WHERE provider = @provider AND external_event_id = @externalId
        ''',
        parameters: {'provider': providerName, 'externalId': externalId},
      );
    } else {
      // Create new internal event
      final internalEventId = _uuid.v4();
      await _db.execute(
        '''
        INSERT INTO calendar_events
          (id, space_id, created_by, title, location, event_type,
           all_day, start_at, end_at, recurrence_rule,
           source_module, created_at, updated_at)
        VALUES
          (@id, @spaceId, @userId, @title, @location, 'space',
           @allDay, @startAt, @endAt, @recurrenceRule,
           'calendar_sync', NOW(), NOW())
        ''',
        parameters: {
          'id': internalEventId,
          'spaceId': spaceId,
          'userId': userId,
          'title': title,
          'location': location,
          'allDay': allDay,
          'startAt': startAt,
          'endAt': endAt,
          'recurrenceRule': recurrenceRule,
        },
      );

      // Create sync event mapping
      await _db.execute(
        '''
        INSERT INTO calendar_sync_event_map
          (id, internal_event_id, external_event_id, provider,
           external_calendar_id, last_synced_at, created_at, updated_at)
        VALUES
          (@id, @internalEventId, @externalId, @provider,
           @calendarId, NOW(), NOW(), NOW())
        ''',
        parameters: {
          'id': _uuid.v4(),
          'internalEventId': internalEventId,
          'externalId': externalId,
          'provider': providerName,
          'calendarId': calendarId,
        },
      );
    }
  }
}

// =============================================================================
// Exceptions
// =============================================================================

/// Exception thrown when a calendar sync operation fails.
class CalendarSyncException implements Exception {
  final String message;

  const CalendarSyncException(this.message);

  @override
  String toString() => 'CalendarSyncException: $message';
}
