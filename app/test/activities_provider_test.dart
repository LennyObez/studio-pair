import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studio_pair/src/providers/activities_provider.dart';
import 'package:studio_pair/src/providers/service_providers.dart';
import 'package:studio_pair/src/providers/space_provider.dart';
import 'package:studio_pair/src/repositories/activities_repository.dart';
import 'package:studio_pair/src/services/database/app_database.dart';

@GenerateNiceMocks([MockSpec<ActivitiesRepository>()])
import 'activities_provider_test.mocks.dart';

void main() {
  late MockActivitiesRepository mockRepo;
  late ProviderContainer container;

  const testSpaceId = 'space-001';
  final now = DateTime(2026);

  const testSpace = Space(id: testSpaceId, name: 'Test space', type: 'couple');

  CachedActivity makeActivity({
    required String id,
    required String title,
    String category = 'movie',
    String description = '',
    String status = 'active',
    String mode = 'date_space',
    String privacy = 'shared',
    String createdBy = 'user-1',
  }) {
    return CachedActivity(
      id: id,
      spaceId: testSpaceId,
      createdBy: createdBy,
      title: title,
      description: description.isNotEmpty ? description : null,
      category: category,
      privacy: privacy,
      status: status,
      mode: mode,
      createdAt: now,
      updatedAt: now,
      syncedAt: now,
    );
  }

  final activity1 = makeActivity(
    id: 'act-1',
    title: 'Movie Night',
    description: 'Watch a classic movie',
  );

  final activity2 = makeActivity(
    id: 'act-2',
    title: 'Board Game Evening',
    category: 'game',
    description: 'Play Catan',
    mode: 'unlinked',
    createdBy: 'user-2',
  );

  final activity3 = makeActivity(
    id: 'act-3',
    title: 'Movie Marathon',
    description: 'All the Lord of the Rings',
    mode: 'unlinked',
  );

  /// Creates a [ProviderContainer] with the mock repository and test space
  /// injected via overrides. The [repoActivities] list is what
  /// `getActivities` will return by default.
  ProviderContainer createContainer({
    List<CachedActivity> repoActivities = const [],
    Space? space,
  }) {
    when(
      mockRepo.getActivities(testSpaceId),
    ).thenAnswer((_) async => repoActivities);

    return ProviderContainer(
      overrides: [
        activitiesRepositoryProvider.overrideWithValue(mockRepo),
        currentSpaceProvider.overrideWithValue(space ?? testSpace),
      ],
    );
  }

  setUp(() {
    mockRepo = MockActivitiesRepository();
  });

  tearDown(() {
    container.dispose();
  });

  // ── Loading ─────────────────────────────────────────────────────────────

  group('build / initial load', () {
    test('fetches activities from the repository on build', () async {
      container = createContainer(repoActivities: [activity1, activity2]);

      // Reading the provider triggers build().
      final future = container.read(activitiesProvider.future);
      final activities = await future;

      expect(activities, hasLength(2));
      expect(activities[0].title, equals('Movie Night'));
      expect(activities[1].title, equals('Board Game Evening'));
      verify(mockRepo.getActivities(testSpaceId)).called(1);
    });

    test('returns an empty list when there is no current space', () async {
      container = ProviderContainer(
        overrides: [
          activitiesRepositoryProvider.overrideWithValue(mockRepo),
          currentSpaceProvider.overrideWithValue(null),
        ],
      );

      final activities = await container.read(activitiesProvider.future);

      expect(activities, isEmpty);
      verifyNever(mockRepo.getActivities(any));
    });

    test('exposes AsyncError when the repository throws', () async {
      when(
        mockRepo.getActivities(testSpaceId),
      ).thenThrow(Exception('Network error'));

      container = ProviderContainer(
        overrides: [
          activitiesRepositoryProvider.overrideWithValue(mockRepo),
          currentSpaceProvider.overrideWithValue(testSpace),
        ],
      );

      final state = await container
          .read(activitiesProvider.future)
          .then(
            (_) => container.read(activitiesProvider),
            onError: (_) => container.read(activitiesProvider),
          );

      expect(state, isA<AsyncError<List<CachedActivity>>>());
      expect(state.error.toString(), contains('Network error'));
    });
  });

  // ── createActivity ─────────────────────────────────────────────────────

  group('createActivity', () {
    test('creates an activity and refreshes the list', () async {
      container = createContainer(repoActivities: []);

      // Wait for initial load to complete.
      await container.read(activitiesProvider.future);

      // After creation, getActivities returns the new list.
      when(
        mockRepo.createActivity(
          testSpaceId,
          title: 'Movie Night',
          description: 'Watch a classic movie',
          category: 'movie',
          privacy: 'shared',
          mode: 'date_space',
        ),
      ).thenAnswer((_) async => {});
      when(
        mockRepo.getActivities(testSpaceId),
      ).thenAnswer((_) async => [activity1]);

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.createActivity(
        testSpaceId,
        title: 'Movie Night',
        description: 'Watch a classic movie',
        category: 'movie',
        privacy: 'shared',
        mode: 'date_space',
      );

      expect(result, isTrue);
      final activities = container.read(activitiesProvider).valueOrNull;
      expect(activities, isNotNull);
      expect(activities, hasLength(1));
      expect(activities![0].title, equals('Movie Night'));
    });

    test('returns false when the repository throws', () async {
      container = createContainer(repoActivities: []);
      await container.read(activitiesProvider.future);

      when(
        mockRepo.createActivity(
          testSpaceId,
          title: anyNamed('title'),
          description: anyNamed('description'),
          category: anyNamed('category'),
          privacy: anyNamed('privacy'),
          mode: anyNamed('mode'),
        ),
      ).thenThrow(Exception('Validation error'));

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.createActivity(
        testSpaceId,
        title: '',
        privacy: 'shared',
        mode: 'unlinked',
      );

      expect(result, isFalse);
      expect(container.read(activitiesProvider).hasError, isTrue);
    });
  });

  // ── updateActivity ─────────────────────────────────────────────────────

  group('updateActivity', () {
    test('updates the activity and refreshes the list', () async {
      container = createContainer(repoActivities: [activity1, activity2]);
      await container.read(activitiesProvider.future);

      final updatedActivity = makeActivity(
        id: 'act-1',
        title: 'Updated Movie Night',
        description: 'Watch a classic movie',
      );

      when(
        mockRepo.updateActivity(testSpaceId, 'act-1', any),
      ).thenAnswer((_) async => {'id': 'act-1'});
      when(
        mockRepo.getActivities(testSpaceId),
      ).thenAnswer((_) async => [updatedActivity, activity2]);

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.updateActivity(testSpaceId, 'act-1', {
        'title': 'Updated Movie Night',
      });

      expect(result, isTrue);
      final activities = container.read(activitiesProvider).valueOrNull!;
      expect(activities, hasLength(2));
      expect(activities[0].title, equals('Updated Movie Night'));
      expect(activities[1].title, equals('Board Game Evening'));
    });

    test('returns false when the repository throws', () async {
      container = createContainer(repoActivities: [activity1]);
      await container.read(activitiesProvider.future);

      when(
        mockRepo.updateActivity(testSpaceId, 'act-1', any),
      ).thenThrow(Exception('Not found'));

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.updateActivity(testSpaceId, 'act-1', {
        'title': 'Updated',
      });

      expect(result, isFalse);
      expect(container.read(activitiesProvider).hasError, isTrue);
    });
  });

  // ── deleteActivity ─────────────────────────────────────────────────────

  group('deleteActivity', () {
    test('removes the activity and refreshes the list', () async {
      container = createContainer(repoActivities: [activity1, activity2]);
      await container.read(activitiesProvider.future);

      when(
        mockRepo.deleteActivity(testSpaceId, 'act-1'),
      ).thenAnswer((_) async {});
      when(
        mockRepo.getActivities(testSpaceId),
      ).thenAnswer((_) async => [activity2]);

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.deleteActivity(testSpaceId, 'act-1');

      expect(result, isTrue);
      final activities = container.read(activitiesProvider).valueOrNull!;
      expect(activities, hasLength(1));
      expect(activities[0].id, equals('act-2'));
    });

    test('returns false when the repository throws', () async {
      container = createContainer(repoActivities: [activity1]);
      await container.read(activitiesProvider.future);

      when(
        mockRepo.deleteActivity(testSpaceId, 'act-1'),
      ).thenThrow(Exception('Permission denied'));

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.deleteActivity(testSpaceId, 'act-1');

      expect(result, isFalse);
      expect(container.read(activitiesProvider).hasError, isTrue);
    });
  });

  // ── vote ────────────────────────────────────────────────────────────────

  group('vote', () {
    test('votes on an activity and refreshes the list', () async {
      container = createContainer(repoActivities: [activity2]);
      await container.read(activitiesProvider.future);

      when(mockRepo.vote(testSpaceId, 'act-2', 5)).thenAnswer((_) async => {});
      // After voting the repo returns the updated cached list.
      when(
        mockRepo.getActivities(testSpaceId),
      ).thenAnswer((_) async => [activity2]);

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.vote(testSpaceId, 'act-2', 5);

      expect(result, isTrue);
      verify(mockRepo.vote(testSpaceId, 'act-2', 5)).called(1);
      verify(mockRepo.getActivities(testSpaceId)).called(greaterThan(0));
    });

    test('returns false when the repository throws', () async {
      container = createContainer(repoActivities: [activity2]);
      await container.read(activitiesProvider.future);

      when(
        mockRepo.vote(testSpaceId, 'act-2', 5),
      ).thenThrow(Exception('Vote failed'));

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.vote(testSpaceId, 'act-2', 5);

      expect(result, isFalse);
      expect(container.read(activitiesProvider).hasError, isTrue);
    });
  });

  // ── completeActivity ───────────────────────────────────────────────────

  group('completeActivity', () {
    test('marks an activity as completed and refreshes the list', () async {
      container = createContainer(repoActivities: [activity1]);
      await container.read(activitiesProvider.future);

      final completedActivity = CachedActivity(
        id: 'act-1',
        spaceId: testSpaceId,
        createdBy: 'user-1',
        title: 'Movie Night',
        description: 'Watch a classic movie',
        category: 'movie',
        privacy: 'shared',
        status: 'completed',
        mode: 'date_space',
        completedAt: now,
        completedNotes: 'Great movie!',
        createdAt: now,
        updatedAt: now,
        syncedAt: now,
      );

      when(
        mockRepo.completeActivity(testSpaceId, 'act-1', notes: 'Great movie!'),
      ).thenAnswer((_) async => {});
      when(
        mockRepo.getActivities(testSpaceId),
      ).thenAnswer((_) async => [completedActivity]);

      final notifier = container.read(activitiesProvider.notifier);
      final result = await notifier.completeActivity(
        testSpaceId,
        'act-1',
        notes: 'Great movie!',
      );

      expect(result, isTrue);
      final activities = container.read(activitiesProvider).valueOrNull!;
      expect(activities[0].status, equals('completed'));
      expect(activities[0].completedNotes, equals('Great movie!'));
    });
  });

  // ── searchActivities ──────────────────────────────────────────────────

  group('searchActivities', () {
    test('replaces the list with search results from the repository', () async {
      container = createContainer(
        repoActivities: [activity1, activity2, activity3],
      );
      await container.read(activitiesProvider.future);

      when(
        mockRepo.searchActivities(testSpaceId, 'Movie'),
      ).thenAnswer((_) async => [activity1, activity3]);

      final notifier = container.read(activitiesProvider.notifier);
      await notifier.searchActivities(testSpaceId, 'Movie');

      final activities = container.read(activitiesProvider).valueOrNull!;
      expect(activities, hasLength(2));
      expect(activities.every((a) => a.title.contains('Movie')), isTrue);
    });

    test('sets error state when searchActivities throws', () async {
      container = createContainer(repoActivities: [activity1]);
      await container.read(activitiesProvider.future);

      when(
        mockRepo.searchActivities(testSpaceId, 'xyz'),
      ).thenThrow(Exception('Search failed'));

      final notifier = container.read(activitiesProvider.notifier);
      await notifier.searchActivities(testSpaceId, 'xyz');

      expect(container.read(activitiesProvider).hasError, isTrue);
    });
  });

  // ── Filter providers ──────────────────────────────────────────────────

  group('activityCategoryFilter', () {
    test('defaults to "all"', () {
      container = createContainer();
      expect(container.read(activityCategoryFilter), equals('all'));
    });

    test('can be updated', () {
      container = createContainer();
      container.read(activityCategoryFilter.notifier).state = 'movie';
      expect(container.read(activityCategoryFilter), equals('movie'));
    });
  });

  group('activitySearchQuery', () {
    test('defaults to an empty string', () {
      container = createContainer();
      expect(container.read(activitySearchQuery), equals(''));
    });

    test('can be updated', () {
      container = createContainer();
      container.read(activitySearchQuery.notifier).state = 'board';
      expect(container.read(activitySearchQuery), equals('board'));
    });
  });

  // ── activityListProvider (filtered & searched) ────────────────────────

  group('activityListProvider', () {
    test('returns all activities when no filters are applied', () async {
      container = createContainer(
        repoActivities: [activity1, activity2, activity3],
      );
      await container.read(activitiesProvider.future);

      final list = container.read(activityListProvider);
      expect(list, hasLength(3));
    });

    test('filters by category', () async {
      container = createContainer(
        repoActivities: [activity1, activity2, activity3],
      );
      await container.read(activitiesProvider.future);

      container.read(activityCategoryFilter.notifier).state = 'movie';
      final list = container.read(activityListProvider);
      expect(list, hasLength(2));
      expect(list.every((a) => a.category == 'movie'), isTrue);
    });

    test('filters by search query (case-insensitive)', () async {
      container = createContainer(
        repoActivities: [activity1, activity2, activity3],
      );
      await container.read(activitiesProvider.future);

      container.read(activitySearchQuery.notifier).state = 'board';
      final list = container.read(activityListProvider);
      expect(list, hasLength(1));
      expect(list[0].title, equals('Board Game Evening'));
    });

    test('applies both category and search filters', () async {
      container = createContainer(
        repoActivities: [activity1, activity2, activity3],
      );
      await container.read(activitiesProvider.future);

      container.read(activityCategoryFilter.notifier).state = 'movie';
      container.read(activitySearchQuery.notifier).state = 'marathon';
      final list = container.read(activityListProvider);
      expect(list, hasLength(1));
      expect(list[0].id, equals('act-3'));
    });

    test('returns empty when no activities match filters', () async {
      container = createContainer(repoActivities: [activity1, activity2]);
      await container.read(activitiesProvider.future);

      container.read(activitySearchQuery.notifier).state = 'nonexistent';
      final list = container.read(activityListProvider);
      expect(list, isEmpty);
    });
  });

  // ── activityCategoriesProvider ─────────────────────────────────────────

  group('activityCategoriesProvider', () {
    test('returns sorted distinct categories', () async {
      container = createContainer(
        repoActivities: [activity1, activity2, activity3],
      );
      await container.read(activitiesProvider.future);

      final categories = container.read(activityCategoriesProvider);
      expect(categories, equals(['game', 'movie']));
    });

    test('returns empty list when there are no activities', () async {
      container = createContainer(repoActivities: []);
      await container.read(activitiesProvider.future);

      final categories = container.read(activityCategoriesProvider);
      expect(categories, isEmpty);
    });
  });
}
