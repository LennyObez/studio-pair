import 'package:studio_pair_shared/src/enums/event_type.dart';
import 'package:studio_pair_shared/src/enums/member_role.dart';
import 'package:studio_pair_shared/src/enums/notification_channel.dart';
import 'package:studio_pair_shared/src/enums/space_type.dart';
import 'package:studio_pair_shared/src/enums/task_priority.dart';
import 'package:studio_pair_shared/src/enums/task_status.dart';
import 'package:test/test.dart';

void main() {
  group('TaskStatus enum', () {
    test('has correct string values', () {
      expect(TaskStatus.todo.value, equals('todo'));
      expect(TaskStatus.inProgress.value, equals('in_progress'));
      expect(TaskStatus.done.value, equals('done'));
    });

    test('has correct labels', () {
      expect(TaskStatus.todo.label, equals('To Do'));
      expect(TaskStatus.inProgress.label, equals('In Progress'));
      expect(TaskStatus.done.label, equals('Done'));
    });

    test('contains exactly 3 values', () {
      expect(TaskStatus.values.length, equals(3));
    });
  });

  group('TaskPriority enum', () {
    test('has correct string values', () {
      expect(TaskPriority.low.value, equals('low'));
      expect(TaskPriority.medium.value, equals('medium'));
      expect(TaskPriority.high.value, equals('high'));
      expect(TaskPriority.urgent.value, equals('urgent'));
    });

    test('has correct labels', () {
      expect(TaskPriority.low.label, equals('Low'));
      expect(TaskPriority.medium.label, equals('Medium'));
      expect(TaskPriority.high.label, equals('High'));
      expect(TaskPriority.urgent.label, equals('Urgent'));
    });

    test('contains exactly 4 values', () {
      expect(TaskPriority.values.length, equals(4));
    });
  });

  group('MemberRole enum', () {
    test('has correct string values', () {
      expect(MemberRole.owner.value, equals('owner'));
      expect(MemberRole.admin.value, equals('admin'));
      expect(MemberRole.member.value, equals('member'));
    });

    test('has correct labels', () {
      expect(MemberRole.owner.label, equals('Owner'));
      expect(MemberRole.admin.label, equals('Admin'));
      expect(MemberRole.member.label, equals('Member'));
    });

    test('contains exactly 3 values', () {
      expect(MemberRole.values.length, equals(3));
    });
  });

  group('EventType enum', () {
    test('has correct string values', () {
      expect(EventType.personal.value, equals('personal'));
      expect(EventType.space.value, equals('space'));
      expect(EventType.holiday.value, equals('holiday'));
      expect(EventType.finance.value, equals('finance'));
      expect(EventType.task.value, equals('task'));
      expect(EventType.activity.value, equals('activity'));
    });

    test('has correct labels', () {
      expect(EventType.personal.label, equals('Personal'));
      expect(EventType.space.label, equals('Space'));
      expect(EventType.holiday.label, equals('Holiday'));
      expect(EventType.finance.label, equals('Finance'));
      expect(EventType.task.label, equals('Task'));
      expect(EventType.activity.label, equals('Activity'));
    });

    test('contains exactly 6 values', () {
      expect(EventType.values.length, equals(6));
    });
  });

  group('SpaceType enum', () {
    test('has correct string values', () {
      expect(SpaceType.couple.value, equals('couple'));
      expect(SpaceType.family.value, equals('family'));
      expect(SpaceType.polyamorous.value, equals('polyamorous'));
      expect(SpaceType.friends.value, equals('friends'));
      expect(SpaceType.roommates.value, equals('roommates'));
      expect(SpaceType.colleagues.value, equals('colleagues'));
    });

    test('has correct labels', () {
      expect(SpaceType.couple.label, equals('Couple'));
      expect(SpaceType.family.label, equals('Family'));
      expect(SpaceType.polyamorous.label, equals('Polyamorous'));
      expect(SpaceType.friends.label, equals('Friends'));
      expect(SpaceType.roommates.label, equals('Roommates'));
      expect(SpaceType.colleagues.label, equals('Colleagues'));
    });

    test('contains exactly 6 values', () {
      expect(SpaceType.values.length, equals(6));
    });
  });

  group('NotificationChannel enum', () {
    test('has correct string values', () {
      expect(NotificationChannel.inApp.value, equals('in_app'));
      expect(NotificationChannel.push.value, equals('push'));
      expect(NotificationChannel.email.value, equals('email'));
    });

    test('has correct labels', () {
      expect(NotificationChannel.inApp.label, equals('In-App'));
      expect(NotificationChannel.push.label, equals('Push'));
      expect(NotificationChannel.email.label, equals('Email'));
    });

    test('contains exactly 3 values', () {
      expect(NotificationChannel.values.length, equals(3));
    });
  });

  group('Enum value uniqueness', () {
    test('TaskStatus values are unique', () {
      final values = TaskStatus.values.map((e) => e.value).toSet();
      expect(values.length, equals(TaskStatus.values.length));
    });

    test('TaskPriority values are unique', () {
      final values = TaskPriority.values.map((e) => e.value).toSet();
      expect(values.length, equals(TaskPriority.values.length));
    });

    test('MemberRole values are unique', () {
      final values = MemberRole.values.map((e) => e.value).toSet();
      expect(values.length, equals(MemberRole.values.length));
    });

    test('SpaceType values are unique', () {
      final values = SpaceType.values.map((e) => e.value).toSet();
      expect(values.length, equals(SpaceType.values.length));
    });
  });
}
