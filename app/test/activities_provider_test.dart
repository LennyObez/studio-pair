import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studio_pair/src/providers/activities_provider.dart';
import 'package:studio_pair/src/services/api/activities_api.dart';
import 'package:studio_pair/src/services/database/daos/activities_dao.dart';

@GenerateNiceMocks([MockSpec<ActivitiesApi>(), MockSpec<ActivitiesDao>()])
import 'activities_provider_test.mocks.dart';

void main() {
  late MockActivitiesApi mockApi;
  late MockActivitiesDao mockDao;
  late ActivitiesNotifier notifier;

  const testSpaceId = 'space-001';

  setUp(() {
    mockApi = MockActivitiesApi();
    mockDao = MockActivitiesDao();
    notifier = ActivitiesNotifier(mockApi, mockDao);
  });

  tearDown(() {
    notifier.dispose();
  });

  Response makeResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(),
    );
  }

  final activityJson1 = {
    'id': 'act-1',
    'title': 'Movie Night',
    'description': 'Watch a classic movie',
    'category': 'movie',
    'thumbnail_url': null,
    'trailer_url': null,
    'privacy': 'shared',
    'status': 'active',
    'mode': 'date_space',
    'created_by': 'user-1',
    'average_rating': 4.5,
    'vote_count': 2,
  };

  final activityJson2 = {
    'id': 'act-2',
    'title': 'Board Game Evening',
    'description': 'Play Catan',
    'category': 'game',
    'thumbnail_url': null,
    'trailer_url': null,
    'privacy': 'shared',
    'status': 'active',
    'mode': 'unlinked',
    'created_by': 'user-2',
    'average_rating': null,
    'vote_count': null,
  };

  group('loadActivities', () {
    test('loads activities from API and updates state', () async {
      when(
        mockApi.listActivities(
          testSpaceId,
          category: anyNamed('category'),
          status: anyNamed('status'),
        ),
      ).thenAnswer((_) async => makeResponse([activityJson1, activityJson2]));

      await notifier.loadActivities(testSpaceId);

      expect(notifier.state.activities.length, equals(2));
      expect(notifier.state.activities[0].title, equals('Movie Night'));
      expect(notifier.state.activities[1].title, equals('Board Game Evening'));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('handles API response wrapped in data key', () async {
      when(
        mockApi.listActivities(
          testSpaceId,
          category: anyNamed('category'),
          status: anyNamed('status'),
        ),
      ).thenAnswer(
        (_) async => makeResponse({
          'data': [activityJson1],
        }),
      );

      await notifier.loadActivities(testSpaceId);

      expect(notifier.state.activities.length, equals(1));
      expect(notifier.state.activities[0].id, equals('act-1'));
    });

    test('sets error state on API failure', () async {
      when(
        mockApi.listActivities(
          testSpaceId,
          category: anyNamed('category'),
          status: anyNamed('status'),
        ),
      ).thenThrow(Exception('Network error'));

      await notifier.loadActivities(testSpaceId);

      expect(notifier.state.activities, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('Network error'));
    });

    test('passes category and status filters to the API', () async {
      when(
        mockApi.listActivities(
          testSpaceId,
          category: 'movie',
          status: 'active',
        ),
      ).thenAnswer((_) async => makeResponse([activityJson1]));

      await notifier.loadActivities(
        testSpaceId,
        category: 'movie',
        status: 'active',
      );

      verify(
        mockApi.listActivities(
          testSpaceId,
          category: 'movie',
          status: 'active',
        ),
      ).called(1);
      expect(notifier.state.activities.length, equals(1));
    });
  });

  group('createActivity', () {
    test('creates activity and appends it to the list', () async {
      when(
        mockApi.createActivity(
          testSpaceId,
          title: anyNamed('title'),
          description: anyNamed('description'),
          category: anyNamed('category'),
          thumbnailUrl: anyNamed('thumbnailUrl'),
          trailerUrl: anyNamed('trailerUrl'),
          privacy: anyNamed('privacy'),
          mode: anyNamed('mode'),
        ),
      ).thenAnswer((_) async => makeResponse(activityJson1));

      final result = await notifier.createActivity(
        testSpaceId,
        title: 'Movie Night',
        description: 'Watch a classic movie',
        category: 'movie',
        privacy: 'shared',
        mode: 'date_space',
      );

      expect(result, isTrue);
      expect(notifier.state.activities.length, equals(1));
      expect(notifier.state.activities[0].title, equals('Movie Night'));
      expect(notifier.state.isLoading, isFalse);
    });

    test('returns false and sets error on creation failure', () async {
      when(
        mockApi.createActivity(
          testSpaceId,
          title: anyNamed('title'),
          description: anyNamed('description'),
          category: anyNamed('category'),
          thumbnailUrl: anyNamed('thumbnailUrl'),
          trailerUrl: anyNamed('trailerUrl'),
          privacy: anyNamed('privacy'),
          mode: anyNamed('mode'),
        ),
      ).thenThrow(Exception('Validation error'));

      final result = await notifier.createActivity(
        testSpaceId,
        title: '',
        privacy: 'shared',
        mode: 'unlinked',
      );

      expect(result, isFalse);
      expect(notifier.state.activities, isEmpty);
      expect(notifier.state.error, contains('Validation error'));
    });
  });

  group('updateActivity', () {
    test('updates the matching activity in the list', () async {
      // Pre-populate with activities
      when(
        mockApi.listActivities(
          testSpaceId,
          category: anyNamed('category'),
          status: anyNamed('status'),
        ),
      ).thenAnswer((_) async => makeResponse([activityJson1, activityJson2]));
      await notifier.loadActivities(testSpaceId);

      final updatedJson = Map<String, dynamic>.from(activityJson1);
      updatedJson['title'] = 'Updated Movie Night';

      when(
        mockApi.updateActivity(testSpaceId, 'act-1', any),
      ).thenAnswer((_) async => makeResponse(updatedJson));

      final result = await notifier.updateActivity(testSpaceId, 'act-1', {
        'title': 'Updated Movie Night',
      });

      expect(result, isTrue);
      expect(notifier.state.activities.length, equals(2));
      expect(notifier.state.activities[0].title, equals('Updated Movie Night'));
      expect(notifier.state.activities[1].title, equals('Board Game Evening'));
    });

    test('returns false on update failure', () async {
      when(
        mockApi.updateActivity(testSpaceId, 'act-1', any),
      ).thenThrow(Exception('Not found'));

      final result = await notifier.updateActivity(testSpaceId, 'act-1', {
        'title': 'Updated',
      });

      expect(result, isFalse);
      expect(notifier.state.error, contains('Not found'));
    });
  });

  group('deleteActivity', () {
    test('removes the activity from the list on success', () async {
      // Pre-populate with activities
      when(
        mockApi.listActivities(
          testSpaceId,
          category: anyNamed('category'),
          status: anyNamed('status'),
        ),
      ).thenAnswer((_) async => makeResponse([activityJson1, activityJson2]));
      await notifier.loadActivities(testSpaceId);
      expect(notifier.state.activities.length, equals(2));

      when(
        mockApi.deleteActivity(testSpaceId, 'act-1'),
      ).thenAnswer((_) async => makeResponse({}));

      final result = await notifier.deleteActivity(testSpaceId, 'act-1');

      expect(result, isTrue);
      expect(notifier.state.activities.length, equals(1));
      expect(notifier.state.activities[0].id, equals('act-2'));
    });

    test('returns false and sets error on delete failure', () async {
      when(
        mockApi.deleteActivity(testSpaceId, 'act-1'),
      ).thenThrow(Exception('Permission denied'));

      final result = await notifier.deleteActivity(testSpaceId, 'act-1');

      expect(result, isFalse);
      expect(notifier.state.error, contains('Permission denied'));
    });
  });

  group('vote', () {
    test('updates vote count and average rating for the activity', () async {
      // Pre-populate
      when(
        mockApi.listActivities(
          testSpaceId,
          category: anyNamed('category'),
          status: anyNamed('status'),
        ),
      ).thenAnswer((_) async => makeResponse([activityJson2]));
      await notifier.loadActivities(testSpaceId);

      when(
        mockApi.vote(testSpaceId, 'act-2', 5),
      ).thenAnswer((_) async => makeResponse({}));

      final result = await notifier.vote(testSpaceId, 'act-2', 5);

      expect(result, isTrue);
      final votedActivity = notifier.state.activities.firstWhere(
        (a) => a.id == 'act-2',
      );
      expect(votedActivity.averageRating, equals(5.0));
      expect(votedActivity.voteCount, equals(1));
    });
  });

  group('setCategory and setSearchQuery', () {
    test('setCategory updates the selectedCategory in state', () {
      expect(notifier.state.selectedCategory, equals('all'));

      notifier.setCategory('movie');

      expect(notifier.state.selectedCategory, equals('movie'));
    });

    test('setSearchQuery updates the searchQuery in state', () {
      expect(notifier.state.searchQuery, equals(''));

      notifier.setSearchQuery('board');

      expect(notifier.state.searchQuery, equals('board'));
    });
  });
}
