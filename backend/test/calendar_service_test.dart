import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studio_pair_backend/src/modules/calendar/calendar_repository.dart';
import 'package:studio_pair_backend/src/modules/calendar/calendar_service.dart';
import 'package:studio_pair_backend/src/modules/spaces/spaces_repository.dart';
import 'package:studio_pair_backend/src/services/notification_service.dart';
import 'package:test/test.dart';

import 'calendar_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CalendarRepository>(),
  MockSpec<SpacesRepository>(),
  MockSpec<NotificationService>(),
])
void main() {
  group('CalendarService', () {
    late MockCalendarRepository mockCalendarRepo;
    late MockSpacesRepository mockSpacesRepo;
    late MockNotificationService mockNotification;
    late CalendarService calendarService;

    setUp(() {
      mockCalendarRepo = MockCalendarRepository();
      mockSpacesRepo = MockSpacesRepository();
      mockNotification = MockNotificationService();
      calendarService = CalendarService(
        mockCalendarRepo,
        mockSpacesRepo,
        mockNotification,
      );
    });

    /// Helper to set up space membership verification.
    void stubActiveMember(String spaceId, String userId) {
      when(mockSpacesRepo.getMember(spaceId, userId)).thenAnswer(
        (_) async => {
          'space_id': spaceId,
          'user_id': userId,
          'role': 'member',
          'status': 'active',
        },
      );
    }

    group('createEvent', () {
      test('throws CalendarException for empty title', () async {
        stubActiveMember('space-1', 'user-1');

        expect(
          () => calendarService.createEvent(
            spaceId: 'space-1',
            userId: 'user-1',
            title: '',
            startAt: DateTime.now(),
            endAt: DateTime.now().add(const Duration(hours: 1)),
          ),
          throwsA(
            isA<CalendarException>().having(
              (e) => e.code,
              'code',
              'INVALID_TITLE',
            ),
          ),
        );
      });

      test(
        'throws CalendarException for title exceeding 200 characters',
        () async {
          stubActiveMember('space-1', 'user-1');

          expect(
            () => calendarService.createEvent(
              spaceId: 'space-1',
              userId: 'user-1',
              title: 'A' * 201,
              startAt: DateTime.now(),
              endAt: DateTime.now().add(const Duration(hours: 1)),
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'INVALID_TITLE',
              ),
            ),
          );
        },
      );

      test('throws CalendarException for invalid event type', () async {
        stubActiveMember('space-1', 'user-1');

        expect(
          () => calendarService.createEvent(
            spaceId: 'space-1',
            userId: 'user-1',
            title: 'Test Event',
            eventType: 'invalid_type',
            startAt: DateTime.now(),
            endAt: DateTime.now().add(const Duration(hours: 1)),
          ),
          throwsA(
            isA<CalendarException>().having(
              (e) => e.code,
              'code',
              'INVALID_EVENT_TYPE',
            ),
          ),
        );
      });

      test(
        'throws CalendarException when end date is before start date',
        () async {
          stubActiveMember('space-1', 'user-1');

          final now = DateTime.now();
          expect(
            () => calendarService.createEvent(
              spaceId: 'space-1',
              userId: 'user-1',
              title: 'Test Event',
              startAt: now.add(const Duration(hours: 2)),
              endAt: now,
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'INVALID_DATE_RANGE',
              ),
            ),
          );
        },
      );

      test(
        'throws CalendarException when user is not a space member',
        () async {
          when(
            mockSpacesRepo.getMember('space-1', 'non-member'),
          ).thenAnswer((_) async => null);

          expect(
            () => calendarService.createEvent(
              spaceId: 'space-1',
              userId: 'non-member',
              title: 'Test Event',
              startAt: DateTime.now(),
              endAt: DateTime.now().add(const Duration(hours: 1)),
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'SPACE_ACCESS_DENIED',
              ),
            ),
          );
        },
      );

      test('creates event successfully with valid input', () async {
        stubActiveMember('space-1', 'user-1');

        final now = DateTime.now();
        final end = now.add(const Duration(hours: 1));
        final eventData = {
          'id': 'event-1',
          'space_id': 'space-1',
          'created_by': 'user-1',
          'title': 'Team Standup',
          'event_type': 'custom',
          'all_day': false,
          'start_at': now.toIso8601String(),
          'end_at': end.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        when(
          mockCalendarRepo.createEvent(
            id: anyNamed('id'),
            spaceId: anyNamed('spaceId'),
            createdBy: anyNamed('createdBy'),
            title: anyNamed('title'),
            location: anyNamed('location'),
            eventType: anyNamed('eventType'),
            allDay: anyNamed('allDay'),
            startAt: anyNamed('startAt'),
            endAt: anyNamed('endAt'),
            recurrenceRule: anyNamed('recurrenceRule'),
            sourceModule: anyNamed('sourceModule'),
            sourceEntityId: anyNamed('sourceEntityId'),
          ),
        ).thenAnswer((_) async => eventData);

        final result = await calendarService.createEvent(
          spaceId: 'space-1',
          userId: 'user-1',
          title: 'Team Standup',
          startAt: now,
          endAt: end,
        );

        expect(result['title'], equals('Team Standup'));
        expect(result['alerts'], isA<List<dynamic>>());
        expect(result['invitations'], isA<List<dynamic>>());
      });

      test('validates source module when specified', () async {
        stubActiveMember('space-1', 'user-1');

        expect(
          () => calendarService.createEvent(
            spaceId: 'space-1',
            userId: 'user-1',
            title: 'Test',
            startAt: DateTime.now(),
            endAt: DateTime.now().add(const Duration(hours: 1)),
            sourceModule: 'invalid_module',
          ),
          throwsA(
            isA<CalendarException>().having(
              (e) => e.code,
              'code',
              'INVALID_SOURCE_MODULE',
            ),
          ),
        );
      });

      test(
        'requires source entity ID when source module is specified',
        () async {
          stubActiveMember('space-1', 'user-1');

          expect(
            () => calendarService.createEvent(
              spaceId: 'space-1',
              userId: 'user-1',
              title: 'Test',
              startAt: DateTime.now(),
              endAt: DateTime.now().add(const Duration(hours: 1)),
              sourceModule: 'activity',
              sourceEntityId: null,
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'MISSING_SOURCE_ENTITY_ID',
              ),
            ),
          );
        },
      );
    });

    group('updateEvent', () {
      test('throws CalendarException when event is not found', () async {
        when(
          mockCalendarRepo.getEventById('nonexistent'),
        ).thenAnswer((_) async => null);

        expect(
          () => calendarService.updateEvent(
            eventId: 'nonexistent',
            spaceId: 'space-1',
            userId: 'user-1',
            userRole: 'member',
          ),
          throwsA(
            isA<CalendarException>().having(
              (e) => e.code,
              'code',
              'EVENT_NOT_FOUND',
            ),
          ),
        );
      });

      test(
        'throws FORBIDDEN when non-creator non-admin tries to update',
        () async {
          when(mockCalendarRepo.getEventById('event-1')).thenAnswer(
            (_) async => {
              'id': 'event-1',
              'space_id': 'space-1',
              'created_by': 'user-creator',
              'title': 'Original',
              'start_at': DateTime.now().toIso8601String(),
              'end_at': DateTime.now()
                  .add(const Duration(hours: 1))
                  .toIso8601String(),
            },
          );

          expect(
            () => calendarService.updateEvent(
              eventId: 'event-1',
              spaceId: 'space-1',
              userId: 'user-other',
              userRole: 'member',
              updates: {'title': 'Changed'},
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'FORBIDDEN',
              ),
            ),
          );
        },
      );

      test('allows admin to update any event', () async {
        final now = DateTime.now();
        when(mockCalendarRepo.getEventById('event-1')).thenAnswer(
          (_) async => {
            'id': 'event-1',
            'space_id': 'space-1',
            'created_by': 'user-creator',
            'title': 'Original',
            'start_at': now.toIso8601String(),
            'end_at': now.add(const Duration(hours: 1)).toIso8601String(),
          },
        );
        when(mockCalendarRepo.updateEvent(any, any)).thenAnswer(
          (_) async => {
            'id': 'event-1',
            'space_id': 'space-1',
            'title': 'Admin Updated',
          },
        );

        final result = await calendarService.updateEvent(
          eventId: 'event-1',
          spaceId: 'space-1',
          userId: 'admin-user',
          userRole: 'admin',
          updates: {'title': 'Admin Updated'},
        );

        expect(result['title'], equals('Admin Updated'));
      });
    });

    group('deleteEvent', () {
      test('throws CalendarException when event is not found', () async {
        when(
          mockCalendarRepo.getEventById('nonexistent'),
        ).thenAnswer((_) async => null);

        expect(
          () => calendarService.deleteEvent(
            eventId: 'nonexistent',
            spaceId: 'space-1',
            userId: 'user-1',
            userRole: 'member',
          ),
          throwsA(
            isA<CalendarException>().having(
              (e) => e.code,
              'code',
              'EVENT_NOT_FOUND',
            ),
          ),
        );
      });

      test(
        'throws FORBIDDEN when regular member tries to delete others event',
        () async {
          when(mockCalendarRepo.getEventById('event-1')).thenAnswer(
            (_) async => {
              'id': 'event-1',
              'space_id': 'space-1',
              'created_by': 'user-creator',
            },
          );

          expect(
            () => calendarService.deleteEvent(
              eventId: 'event-1',
              spaceId: 'space-1',
              userId: 'user-other',
              userRole: 'member',
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'FORBIDDEN',
              ),
            ),
          );
        },
      );

      test('allows creator to delete their event', () async {
        when(mockCalendarRepo.getEventById('event-1')).thenAnswer(
          (_) async => {
            'id': 'event-1',
            'space_id': 'space-1',
            'created_by': 'user-1',
          },
        );
        when(
          mockCalendarRepo.softDeleteEvent('event-1'),
        ).thenAnswer((_) async {});

        await calendarService.deleteEvent(
          eventId: 'event-1',
          spaceId: 'space-1',
          userId: 'user-1',
          userRole: 'member',
        );

        verify(mockCalendarRepo.softDeleteEvent('event-1')).called(1);
      });
    });

    group('getEventsByRange', () {
      test(
        'throws CalendarException when end date is before start date',
        () async {
          final now = DateTime.now();
          expect(
            () => calendarService.getEventsByRange(
              spaceId: 'space-1',
              userId: 'user-1',
              startDate: now.add(const Duration(days: 10)),
              endDate: now,
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'INVALID_DATE_RANGE',
              ),
            ),
          );
        },
      );

      test('throws CalendarException when range exceeds one year', () async {
        stubActiveMember('space-1', 'user-1');

        final now = DateTime.now();
        expect(
          () => calendarService.getEventsByRange(
            spaceId: 'space-1',
            userId: 'user-1',
            startDate: now,
            endDate: now.add(const Duration(days: 400)),
          ),
          throwsA(
            isA<CalendarException>().having(
              (e) => e.code,
              'code',
              'DATE_RANGE_TOO_LARGE',
            ),
          ),
        );
      });
    });

    group('respondToInvitation', () {
      test('throws CalendarException for invalid RSVP status', () async {
        expect(
          () => calendarService.respondToInvitation(
            eventId: 'event-1',
            spaceId: 'space-1',
            userId: 'user-1',
            status: 'maybe',
          ),
          throwsA(
            isA<CalendarException>().having(
              (e) => e.code,
              'code',
              'INVALID_RSVP_STATUS',
            ),
          ),
        );
      });

      test('accepts valid RSVP statuses', () {
        // Just verify the valid statuses don't throw validation errors
        // (they may throw other errors due to mock setup)
        for (final status in ['accepted', 'declined', 'tentative']) {
          // These will fail on event lookup, but not on RSVP validation
          when(
            mockCalendarRepo.getEventById('event-1'),
          ).thenAnswer((_) async => null);
          expect(
            () => calendarService.respondToInvitation(
              eventId: 'event-1',
              spaceId: 'space-1',
              userId: 'user-1',
              status: status,
            ),
            throwsA(
              isA<CalendarException>().having(
                (e) => e.code,
                'code',
                'EVENT_NOT_FOUND',
              ),
            ),
          );
        }
      });
    });

    group('CalendarException', () {
      test('has correct default values', () {
        const exception = CalendarException('test');
        expect(exception.code, equals('CALENDAR_ERROR'));
        expect(exception.statusCode, equals(400));
      });

      test('toString contains code and message', () {
        const exception = CalendarException('event error', code: 'BAD_EVENT');
        expect(exception.toString(), contains('BAD_EVENT'));
        expect(exception.toString(), contains('event error'));
      });
    });
  });
}
