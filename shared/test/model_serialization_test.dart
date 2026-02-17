import 'package:studio_pair_shared/src/enums/event_type.dart';
import 'package:studio_pair_shared/src/enums/notification_channel.dart';
import 'package:studio_pair_shared/src/enums/space_type.dart';
import 'package:studio_pair_shared/src/enums/task_priority.dart';
import 'package:studio_pair_shared/src/enums/task_status.dart';
import 'package:studio_pair_shared/src/models/calendar_event.dart';
import 'package:studio_pair_shared/src/models/notification_model.dart';
import 'package:studio_pair_shared/src/models/space.dart';
import 'package:studio_pair_shared/src/models/task_model.dart';
import 'package:studio_pair_shared/src/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('User model serialization', () {
    final now = DateTime.utc(2024, 6, 15, 10, 30, 0);

    final userJson = <String, dynamic>{
      'id': 'user-123',
      'email': 'alice@example.com',
      'display_name': 'Alice',
      'avatar_url': 'https://example.com/avatar.png',
      'totp_enabled': false,
      'preferred_language': 'en',
      'timezone': 'America/New_York',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson creates a valid User', () {
      final user = User.fromJson(userJson);
      expect(user.id, equals('user-123'));
      expect(user.email, equals('alice@example.com'));
      expect(user.displayName, equals('Alice'));
      expect(user.avatarUrl, equals('https://example.com/avatar.png'));
      expect(user.totpEnabled, isFalse);
      expect(user.preferredLanguage, equals('en'));
      expect(user.timezone, equals('America/New_York'));
    });

    test('toJson produces expected map', () {
      final user = User.fromJson(userJson);
      final json = user.toJson();
      expect(json['id'], equals('user-123'));
      expect(json['email'], equals('alice@example.com'));
      expect(json['display_name'], equals('Alice'));
      expect(json['totp_enabled'], isFalse);
    });

    test('fromJson handles null optional fields', () {
      final minimalJson = <String, dynamic>{
        'id': 'user-456',
        'email': 'bob@example.com',
        'display_name': null,
        'avatar_url': null,
        'totp_enabled': true,
        'preferred_language': 'fr',
        'timezone': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final user = User.fromJson(minimalJson);
      expect(user.displayName, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.timezone, isNull);
      expect(user.totpEnabled, isTrue);
    });

    test('round-trip preserves data', () {
      final user = User.fromJson(userJson);
      final roundTripped = User.fromJson(user.toJson());
      expect(roundTripped, equals(user));
    });

    test('Equatable compares correctly', () {
      final user1 = User.fromJson(userJson);
      final user2 = User.fromJson(userJson);
      expect(user1, equals(user2));
    });
  });

  group('Space model serialization', () {
    final now = DateTime.utc(2024, 6, 15, 10, 30, 0);

    final spaceJson = <String, dynamic>{
      'id': 'space-abc',
      'name': 'Our Home',
      'type': 'couple',
      'avatar_url': 'https://example.com/space.png',
      'invite_code': 'ABCD1234',
      'max_members': 2,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson creates a valid Space', () {
      final space = Space.fromJson(spaceJson);
      expect(space.id, equals('space-abc'));
      expect(space.name, equals('Our Home'));
      expect(space.type, equals(SpaceType.couple));
      expect(space.inviteCode, equals('ABCD1234'));
      expect(space.maxMembers, equals(2));
    });

    test('toJson produces expected map', () {
      final space = Space.fromJson(spaceJson);
      final json = space.toJson();
      expect(json['id'], equals('space-abc'));
      expect(json['name'], equals('Our Home'));
      expect(json['max_members'], equals(2));
    });

    test('round-trip preserves data', () {
      final space = Space.fromJson(spaceJson);
      final roundTripped = Space.fromJson(space.toJson());
      expect(roundTripped, equals(space));
    });

    test('handles null optional fields', () {
      final minimalJson = <String, dynamic>{
        'id': 'space-xyz',
        'name': 'Family Space',
        'type': 'family',
        'avatar_url': null,
        'invite_code': null,
        'max_members': 5,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final space = Space.fromJson(minimalJson);
      expect(space.type, equals(SpaceType.family));
      expect(space.avatarUrl, isNull);
      expect(space.inviteCode, isNull);
    });
  });

  group('TaskModel serialization', () {
    final now = DateTime.utc(2024, 6, 15, 10, 30, 0);

    final taskJson = <String, dynamic>{
      'id': 'task-001',
      'space_id': 'space-abc',
      'created_by': 'user-123',
      'title': 'Buy groceries',
      'description': 'Milk, eggs, bread',
      'status': 'todo',
      'priority': 'medium',
      'due_date': now.toIso8601String(),
      'parent_task_id': null,
      'is_recurring': false,
      'recurrence_rule': null,
      'completed_at': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson creates a valid TaskModel', () {
      final task = TaskModel.fromJson(taskJson);
      expect(task.id, equals('task-001'));
      expect(task.spaceId, equals('space-abc'));
      expect(task.title, equals('Buy groceries'));
      expect(task.status, equals(TaskStatus.todo));
      expect(task.priority, equals(TaskPriority.medium));
      expect(task.isRecurring, isFalse);
    });

    test('toJson produces expected map', () {
      final task = TaskModel.fromJson(taskJson);
      final json = task.toJson();
      expect(json['id'], equals('task-001'));
      expect(json['title'], equals('Buy groceries'));
      expect(json['is_recurring'], isFalse);
    });

    test('round-trip preserves data', () {
      final task = TaskModel.fromJson(taskJson);
      final roundTripped = TaskModel.fromJson(task.toJson());
      expect(roundTripped, equals(task));
    });

    test('handles different status values', () {
      final inProgressJson = Map<String, dynamic>.from(taskJson)
        ..['status'] = 'in_progress';
      final task = TaskModel.fromJson(inProgressJson);
      expect(task.status, equals(TaskStatus.inProgress));

      final doneJson = Map<String, dynamic>.from(taskJson)..['status'] = 'done';
      final doneTask = TaskModel.fromJson(doneJson);
      expect(doneTask.status, equals(TaskStatus.done));
    });

    test('handles different priority values', () {
      for (final priority in TaskPriority.values) {
        final json = Map<String, dynamic>.from(taskJson)
          ..['priority'] = priority.value;
        final task = TaskModel.fromJson(json);
        expect(task.priority, equals(priority));
      }
    });
  });

  group('CalendarEvent model serialization', () {
    final now = DateTime.utc(2024, 6, 15, 10, 30, 0);
    final endTime = DateTime.utc(2024, 6, 15, 12, 0, 0);

    final eventJson = <String, dynamic>{
      'id': 'event-001',
      'space_id': 'space-abc',
      'created_by': 'user-123',
      'title': 'Team Meeting',
      'location': 'Conference Room A',
      'event_type': 'space',
      'all_day': false,
      'start_at': now.toIso8601String(),
      'end_at': endTime.toIso8601String(),
      'recurrence_rule': null,
      'source_module': null,
      'source_entity_id': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson creates a valid CalendarEvent', () {
      final event = CalendarEvent.fromJson(eventJson);
      expect(event.id, equals('event-001'));
      expect(event.title, equals('Team Meeting'));
      expect(event.location, equals('Conference Room A'));
      expect(event.eventType, equals(EventType.space));
      expect(event.allDay, isFalse);
    });

    test('toJson produces expected map', () {
      final event = CalendarEvent.fromJson(eventJson);
      final json = event.toJson();
      expect(json['id'], equals('event-001'));
      expect(json['title'], equals('Team Meeting'));
      expect(json['all_day'], isFalse);
    });

    test('round-trip preserves data', () {
      final event = CalendarEvent.fromJson(eventJson);
      final roundTripped = CalendarEvent.fromJson(event.toJson());
      expect(roundTripped, equals(event));
    });

    test('handles all-day events', () {
      final allDayJson = Map<String, dynamic>.from(eventJson)
        ..['all_day'] = true;
      final event = CalendarEvent.fromJson(allDayJson);
      expect(event.allDay, isTrue);
    });
  });

  group('NotificationModel serialization', () {
    final now = DateTime.utc(2024, 6, 15, 10, 30, 0);

    final notificationJson = <String, dynamic>{
      'id': 'notif-001',
      'user_id': 'user-123',
      'space_id': 'space-abc',
      'type': 'task.assigned',
      'title': 'New task assigned',
      'body': 'You have been assigned to: Buy groceries',
      'source_module': 'tasks',
      'source_entity_id': 'task-001',
      'channel': 'in_app',
      'is_read': false,
      'read_at': null,
      'metadata': {'task_id': 'task-001'},
      'created_at': now.toIso8601String(),
    };

    test('fromJson creates a valid NotificationModel', () {
      final notification = NotificationModel.fromJson(notificationJson);
      expect(notification.id, equals('notif-001'));
      expect(notification.userId, equals('user-123'));
      expect(notification.type, equals('task.assigned'));
      expect(notification.title, equals('New task assigned'));
      expect(notification.channel, equals(NotificationChannel.inApp));
      expect(notification.isRead, isFalse);
      expect(notification.readAt, isNull);
    });

    test('toJson produces expected map', () {
      final notification = NotificationModel.fromJson(notificationJson);
      final json = notification.toJson();
      expect(json['id'], equals('notif-001'));
      expect(json['type'], equals('task.assigned'));
      expect(json['is_read'], isFalse);
    });

    test('round-trip preserves data', () {
      final notification = NotificationModel.fromJson(notificationJson);
      final roundTripped = NotificationModel.fromJson(notification.toJson());
      expect(roundTripped, equals(notification));
    });

    test('handles null optional fields', () {
      final minimalJson = <String, dynamic>{
        'id': 'notif-002',
        'user_id': 'user-456',
        'space_id': null,
        'type': 'system.announcement',
        'title': 'Welcome',
        'body': 'Welcome to Studio Pair',
        'source_module': null,
        'source_entity_id': null,
        'channel': 'push',
        'is_read': true,
        'read_at': now.toIso8601String(),
        'metadata': null,
        'created_at': now.toIso8601String(),
      };

      final notification = NotificationModel.fromJson(minimalJson);
      expect(notification.spaceId, isNull);
      expect(notification.sourceModule, isNull);
      expect(notification.metadata, isNull);
      expect(notification.isRead, isTrue);
      expect(notification.channel, equals(NotificationChannel.push));
    });
  });
}
