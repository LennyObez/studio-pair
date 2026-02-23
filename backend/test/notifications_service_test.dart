import 'package:mockito/mockito.dart';
import 'package:studio_pair_backend/src/modules/notifications/notifications_repository.dart';
import 'package:studio_pair_backend/src/modules/notifications/notifications_service.dart';
import 'package:test/test.dart';

// --- Manual mocks ---

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  group('NotificationsModuleService', () {
    late MockNotificationsRepository mockRepo;
    late NotificationsModuleService service;

    setUp(() {
      mockRepo = MockNotificationsRepository();
      service = NotificationsModuleService(mockRepo);
    });

    group('listNotifications', () {
      test('returns paginated notifications', () async {
        final notifications = List.generate(
          5,
          (i) => {
            'id': 'notif-$i',
            'user_id': 'user-1',
            'type': 'task.assigned',
            'title': 'Notification $i',
            'body': 'Body $i',
            'created_at': DateTime.now()
                .subtract(Duration(minutes: i))
                .toIso8601String(),
          },
        );

        when(
          mockRepo.listNotifications(
            userId: 'user-1',
            cursor: null,
            limit: 26, // limit + 1
            unreadOnly: false,
          ),
        ).thenAnswer((_) async => notifications);

        final result = await service.listNotifications(
          userId: 'user-1',
          limit: 25,
        );

        expect(result['data'], isA<List<dynamic>>());
        expect((result['data'] as List<dynamic>).length, equals(5));
        expect(result['pagination']['has_more'], isFalse);
        expect(result['pagination']['cursor'], isNull);
      });

      test('indicates has_more when there are more results', () async {
        // Generate 26 items (limit + 1)
        final notifications = List.generate(
          26,
          (i) => {
            'id': 'notif-$i',
            'user_id': 'user-1',
            'type': 'task.assigned',
            'title': 'Notification $i',
            'body': 'Body $i',
            'created_at': DateTime.now()
                .subtract(Duration(minutes: i))
                .toIso8601String(),
          },
        );

        when(
          mockRepo.listNotifications(
            userId: 'user-1',
            cursor: null,
            limit: 26,
            unreadOnly: false,
          ),
        ).thenAnswer((_) async => notifications);

        final result = await service.listNotifications(
          userId: 'user-1',
          limit: 25,
        );

        expect((result['data'] as List<dynamic>).length, equals(25));
        expect(result['pagination']['has_more'], isTrue);
        expect(result['pagination']['cursor'], isNotNull);
      });

      test('returns empty list when no notifications exist', () async {
        when(
          mockRepo.listNotifications(
            userId: 'user-1',
            cursor: null,
            limit: 26,
            unreadOnly: false,
          ),
        ).thenAnswer((_) async => []);

        final result = await service.listNotifications(
          userId: 'user-1',
          limit: 25,
        );

        expect(result['data'] as List<dynamic>, isEmpty);
        expect(result['pagination']['has_more'], isFalse);
      });

      test('supports cursor-based pagination', () async {
        final cursor = DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String();

        when(
          mockRepo.listNotifications(
            userId: 'user-1',
            cursor: cursor,
            limit: 11,
            unreadOnly: false,
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 'notif-older',
              'user_id': 'user-1',
              'type': 'system',
              'title': 'Older notification',
              'body': 'Body',
              'created_at': DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
            },
          ],
        );

        final result = await service.listNotifications(
          userId: 'user-1',
          cursor: cursor,
          limit: 10,
        );

        expect((result['data'] as List<dynamic>).length, equals(1));
        expect(result['pagination']['has_more'], isFalse);
      });

      test('supports unread-only filter', () async {
        when(
          mockRepo.listNotifications(
            userId: 'user-1',
            cursor: null,
            limit: 26,
            unreadOnly: true,
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 'notif-unread',
              'user_id': 'user-1',
              'type': 'task.assigned',
              'title': 'Unread notification',
              'body': 'Body',
              'read_at': null,
              'created_at': DateTime.now().toIso8601String(),
            },
          ],
        );

        final result = await service.listNotifications(
          userId: 'user-1',
          limit: 25,
          unreadOnly: true,
        );

        expect((result['data'] as List<dynamic>).length, equals(1));
      });
    });

    group('markRead', () {
      test('returns true when notification is marked as read', () async {
        when(
          mockRepo.markRead('notif-1', 'user-1'),
        ).thenAnswer((_) async => true);

        final result = await service.markRead('notif-1', 'user-1');

        expect(result, isTrue);
        verify(mockRepo.markRead('notif-1', 'user-1')).called(1);
      });

      test(
        'returns false when notification is not found or already read',
        () async {
          when(
            mockRepo.markRead('nonexistent', 'user-1'),
          ).thenAnswer((_) async => false);

          final result = await service.markRead('nonexistent', 'user-1');

          expect(result, isFalse);
        },
      );
    });

    group('markAllRead', () {
      test('returns count of marked notifications', () async {
        when(mockRepo.markAllRead('user-1')).thenAnswer((_) async => 5);

        final result = await service.markAllRead('user-1');

        expect(result, equals(5));
        verify(mockRepo.markAllRead('user-1')).called(1);
      });

      test('returns 0 when no unread notifications', () async {
        when(mockRepo.markAllRead('user-1')).thenAnswer((_) async => 0);

        final result = await service.markAllRead('user-1');

        expect(result, equals(0));
      });

      test('supports space-scoped marking', () async {
        when(
          mockRepo.markAllRead('user-1', spaceId: 'space-1'),
        ).thenAnswer((_) async => 3);

        final result = await service.markAllRead('user-1', spaceId: 'space-1');

        expect(result, equals(3));
        verify(mockRepo.markAllRead('user-1', spaceId: 'space-1')).called(1);
      });
    });

    group('getPreferences', () {
      test('returns stored preferences when they exist', () async {
        final prefs = {
          'user_id': 'user-1',
          'push_enabled': true,
          'email_enabled': false,
          'quiet_hours_enabled': true,
          'quiet_hours_start': '23:00',
          'quiet_hours_end': '07:00',
          'channel_preferences': null,
        };

        when(mockRepo.getPreferences('user-1')).thenAnswer((_) async => prefs);

        final result = await service.getPreferences('user-1');

        expect(result['push_enabled'], isTrue);
        expect(result['email_enabled'], isFalse);
        expect(result['quiet_hours_enabled'], isTrue);
        expect(result['quiet_hours_start'], equals('23:00'));
      });

      test('returns default preferences when none exist', () async {
        when(mockRepo.getPreferences('user-1')).thenAnswer((_) async => null);

        final result = await service.getPreferences('user-1');

        expect(result['user_id'], equals('user-1'));
        expect(result['push_enabled'], isTrue);
        expect(result['email_enabled'], isTrue);
        expect(result['quiet_hours_enabled'], isFalse);
        expect(result['quiet_hours_start'], equals('22:00'));
        expect(result['quiet_hours_end'], equals('08:00'));
      });
    });

    group('updatePreferences', () {
      test('upserts preferences and returns result', () async {
        final input = {
          'push_enabled': false,
          'email_enabled': true,
          'quiet_hours_enabled': true,
          'quiet_hours_start': '21:00',
          'quiet_hours_end': '09:00',
        };

        final expectedResult = {
          'user_id': 'user-1',
          ...input,
          'channel_preferences': null,
        };

        when(
          mockRepo.upsertPreferences(
            userId: 'user-1',
            pushEnabled: false,
            emailEnabled: true,
            quietHoursEnabled: true,
            quietHoursStart: '21:00',
            quietHoursEnd: '09:00',
            channelPreferences: null,
          ),
        ).thenAnswer((_) async => expectedResult);

        final result = await service.updatePreferences('user-1', input);

        expect(result['push_enabled'], isFalse);
        expect(result['quiet_hours_start'], equals('21:00'));
      });
    });
  });
}
