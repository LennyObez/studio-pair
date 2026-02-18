import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studio_pair_backend/src/modules/calendar/calendar_service.dart';
import 'package:studio_pair_backend/src/modules/spaces/spaces_repository.dart';
import 'package:studio_pair_backend/src/modules/tasks/tasks_repository.dart';
import 'package:studio_pair_backend/src/modules/tasks/tasks_service.dart';
import 'package:studio_pair_backend/src/services/notification_service.dart';
import 'package:test/test.dart';

import 'tasks_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TasksRepository>(),
  MockSpec<SpacesRepository>(),
  MockSpec<NotificationService>(),
  MockSpec<CalendarService>(),
])
void main() {
  group('TasksService', () {
    late MockTasksRepository mockTasksRepo;
    late MockSpacesRepository mockSpacesRepo;
    late MockNotificationService mockNotification;
    late MockCalendarService mockCalendar;
    late TasksService tasksService;

    setUp(() {
      mockTasksRepo = MockTasksRepository();
      mockSpacesRepo = MockSpacesRepository();
      mockNotification = MockNotificationService();
      mockCalendar = MockCalendarService();
      tasksService = TasksService(
        mockTasksRepo,
        mockSpacesRepo,
        mockNotification,
        mockCalendar,
      );
    });

    group('createTask', () {
      test('throws TaskException for empty title', () async {
        expect(
          () => tasksService.createTask(
            spaceId: 'space-1',
            userId: 'user-1',
            title: '',
          ),
          throwsA(
            isA<TaskException>().having((e) => e.code, 'code', 'INVALID_TITLE'),
          ),
        );
      });

      test('throws TaskException for whitespace-only title', () async {
        expect(
          () => tasksService.createTask(
            spaceId: 'space-1',
            userId: 'user-1',
            title: '   ',
          ),
          throwsA(
            isA<TaskException>().having((e) => e.code, 'code', 'INVALID_TITLE'),
          ),
        );
      });

      test('throws TaskException for title exceeding 500 characters', () async {
        final longTitle = 'A' * 501;
        expect(
          () => tasksService.createTask(
            spaceId: 'space-1',
            userId: 'user-1',
            title: longTitle,
          ),
          throwsA(
            isA<TaskException>().having((e) => e.code, 'code', 'INVALID_TITLE'),
          ),
        );
      });

      test('throws TaskException for invalid status', () async {
        expect(
          () => tasksService.createTask(
            spaceId: 'space-1',
            userId: 'user-1',
            title: 'Valid Title',
            status: 'invalid_status',
          ),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'INVALID_STATUS',
            ),
          ),
        );
      });

      test('throws TaskException for invalid priority', () async {
        expect(
          () => tasksService.createTask(
            spaceId: 'space-1',
            userId: 'user-1',
            title: 'Valid Title',
            priority: 'critical',
          ),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'INVALID_PRIORITY',
            ),
          ),
        );
      });

      test('creates task successfully with valid input', () async {
        final taskData = {
          'id': 'task-1',
          'space_id': 'space-1',
          'created_by': 'user-1',
          'title': 'Buy groceries',
          'status': 'todo',
          'priority': 'medium',
          'created_at': DateTime.now().toIso8601String(),
        };

        when(
          mockTasksRepo.createTask(
            id: anyNamed('id'),
            spaceId: anyNamed('spaceId'),
            createdBy: anyNamed('createdBy'),
            title: anyNamed('title'),
            description: anyNamed('description'),
            status: anyNamed('status'),
            priority: anyNamed('priority'),
            dueDate: anyNamed('dueDate'),
            parentTaskId: anyNamed('parentTaskId'),
            isRecurring: anyNamed('isRecurring'),
            recurrenceRule: anyNamed('recurrenceRule'),
            sourceModule: anyNamed('sourceModule'),
            sourceEntityId: anyNamed('sourceEntityId'),
          ),
        ).thenAnswer((_) async => taskData);

        when(mockTasksRepo.getTaskById(any)).thenAnswer((_) async => taskData);

        final result = await tasksService.createTask(
          spaceId: 'space-1',
          userId: 'user-1',
          title: 'Buy groceries',
        );

        expect(result['title'], equals('Buy groceries'));
        verify(
          mockTasksRepo.createTask(
            id: anyNamed('id'),
            spaceId: captureAnyNamed('spaceId'),
            createdBy: captureAnyNamed('createdBy'),
            title: captureAnyNamed('title'),
            description: anyNamed('description'),
            status: anyNamed('status'),
            priority: anyNamed('priority'),
            dueDate: anyNamed('dueDate'),
            parentTaskId: anyNamed('parentTaskId'),
            isRecurring: anyNamed('isRecurring'),
            recurrenceRule: anyNamed('recurrenceRule'),
            sourceModule: anyNamed('sourceModule'),
            sourceEntityId: anyNamed('sourceEntityId'),
          ),
        ).called(1);
      });

      test('validates parent task existence', () async {
        when(
          mockTasksRepo.getTaskById('nonexistent-parent'),
        ).thenAnswer((_) async => null);

        expect(
          () => tasksService.createTask(
            spaceId: 'space-1',
            userId: 'user-1',
            title: 'Subtask',
            parentTaskId: 'nonexistent-parent',
          ),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'PARENT_TASK_NOT_FOUND',
            ),
          ),
        );
      });

      test('validates parent task belongs to same space', () async {
        when(mockTasksRepo.getTaskById('parent-in-other-space')).thenAnswer(
          (_) async => {
            'id': 'parent-in-other-space',
            'space_id': 'different-space',
            'title': 'Parent Task',
          },
        );

        expect(
          () => tasksService.createTask(
            spaceId: 'space-1',
            userId: 'user-1',
            title: 'Subtask',
            parentTaskId: 'parent-in-other-space',
          ),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'INVALID_PARENT_TASK',
            ),
          ),
        );
      });
    });

    group('getTask', () {
      test('throws TaskException when task is not found', () async {
        when(
          mockTasksRepo.getTaskById('nonexistent'),
        ).thenAnswer((_) async => null);

        expect(
          () => tasksService.getTask(taskId: 'nonexistent', spaceId: 'space-1'),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'TASK_NOT_FOUND',
            ),
          ),
        );
      });

      test(
        'throws TaskException when task belongs to different space',
        () async {
          when(mockTasksRepo.getTaskById('task-1')).thenAnswer(
            (_) async => {
              'id': 'task-1',
              'space_id': 'other-space',
              'title': 'Task',
            },
          );

          expect(
            () => tasksService.getTask(taskId: 'task-1', spaceId: 'space-1'),
            throwsA(
              isA<TaskException>().having(
                (e) => e.code,
                'code',
                'TASK_NOT_FOUND',
              ),
            ),
          );
        },
      );

      test('returns task when found in correct space', () async {
        final taskData = {
          'id': 'task-1',
          'space_id': 'space-1',
          'title': 'My Task',
        };
        when(
          mockTasksRepo.getTaskById('task-1'),
        ).thenAnswer((_) async => taskData);

        final result = await tasksService.getTask(
          taskId: 'task-1',
          spaceId: 'space-1',
        );

        expect(result['title'], equals('My Task'));
      });
    });

    group('updateTask', () {
      test('throws TaskException when task is not found', () async {
        when(
          mockTasksRepo.getTaskById('nonexistent'),
        ).thenAnswer((_) async => null);

        expect(
          () => tasksService.updateTask(
            taskId: 'nonexistent',
            spaceId: 'space-1',
            userId: 'user-1',
            userRole: 'member',
            updates: {'title': 'New Title'},
          ),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'TASK_NOT_FOUND',
            ),
          ),
        );
      });

      test(
        'throws FORBIDDEN when non-creator non-admin tries to update',
        () async {
          when(mockTasksRepo.getTaskById('task-1')).thenAnswer(
            (_) async => {
              'id': 'task-1',
              'space_id': 'space-1',
              'created_by': 'user-creator',
              'title': 'Original Title',
            },
          );

          expect(
            () => tasksService.updateTask(
              taskId: 'task-1',
              spaceId: 'space-1',
              userId: 'user-other',
              userRole: 'member',
              updates: {'title': 'Updated Title'},
            ),
            throwsA(
              isA<TaskException>().having((e) => e.code, 'code', 'FORBIDDEN'),
            ),
          );
        },
      );

      test('allows creator to update their own task', () async {
        final taskData = {
          'id': 'task-1',
          'space_id': 'space-1',
          'created_by': 'user-1',
          'title': 'Original',
        };
        final updatedData = {...taskData, 'title': 'Updated'};
        // First call returns original (for ownership check),
        // second call returns updated (after update).
        var callCount = 0;
        when(
          mockTasksRepo.getTaskById('task-1'),
        ).thenAnswer((_) async => callCount++ == 0 ? taskData : updatedData);
        when(
          mockTasksRepo.updateTask(any, any),
        ).thenAnswer((_) async => updatedData);

        final result = await tasksService.updateTask(
          taskId: 'task-1',
          spaceId: 'space-1',
          userId: 'user-1',
          userRole: 'member',
          updates: {'title': 'Updated'},
        );

        expect(result['title'], equals('Updated'));
      });

      test('allows admin to update any task', () async {
        final taskData = {
          'id': 'task-1',
          'space_id': 'space-1',
          'created_by': 'user-creator',
          'title': 'Original',
        };
        final updatedData = {...taskData, 'title': 'Admin Updated'};
        // First call returns original (for ownership check),
        // second call returns updated (after update).
        var callCount = 0;
        when(
          mockTasksRepo.getTaskById('task-1'),
        ).thenAnswer((_) async => callCount++ == 0 ? taskData : updatedData);
        when(
          mockTasksRepo.updateTask(any, any),
        ).thenAnswer((_) async => updatedData);

        final result = await tasksService.updateTask(
          taskId: 'task-1',
          spaceId: 'space-1',
          userId: 'admin-user',
          userRole: 'admin',
          updates: {'title': 'Admin Updated'},
        );

        expect(result['title'], equals('Admin Updated'));
      });
    });

    group('deleteTask', () {
      test('throws TaskException when task is not found', () async {
        when(
          mockTasksRepo.getTaskById('nonexistent'),
        ).thenAnswer((_) async => null);

        expect(
          () => tasksService.deleteTask(
            taskId: 'nonexistent',
            spaceId: 'space-1',
            userId: 'user-1',
            userRole: 'member',
          ),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'TASK_NOT_FOUND',
            ),
          ),
        );
      });

      test(
        'throws FORBIDDEN when non-creator non-admin tries to delete',
        () async {
          when(mockTasksRepo.getTaskById('task-1')).thenAnswer(
            (_) async => {
              'id': 'task-1',
              'space_id': 'space-1',
              'created_by': 'user-creator',
            },
          );

          expect(
            () => tasksService.deleteTask(
              taskId: 'task-1',
              spaceId: 'space-1',
              userId: 'user-other',
              userRole: 'member',
            ),
            throwsA(
              isA<TaskException>().having((e) => e.code, 'code', 'FORBIDDEN'),
            ),
          );
        },
      );

      test('allows owner to delete task', () async {
        when(mockTasksRepo.getTaskById('task-1')).thenAnswer(
          (_) async => {
            'id': 'task-1',
            'space_id': 'space-1',
            'created_by': 'user-creator',
          },
        );
        when(mockTasksRepo.softDeleteTask('task-1')).thenAnswer((_) async {});

        await tasksService.deleteTask(
          taskId: 'task-1',
          spaceId: 'space-1',
          userId: 'owner-user',
          userRole: 'owner',
        );

        verify(mockTasksRepo.softDeleteTask('task-1')).called(1);
      });
    });

    group('completeTask', () {
      test('throws TaskException when task is already completed', () async {
        when(mockTasksRepo.getTaskById('task-done')).thenAnswer(
          (_) async => {
            'id': 'task-done',
            'space_id': 'space-1',
            'created_by': 'user-1',
            'status': 'done',
          },
        );

        expect(
          () => tasksService.completeTask(
            taskId: 'task-done',
            spaceId: 'space-1',
            userId: 'user-1',
          ),
          throwsA(
            isA<TaskException>().having(
              (e) => e.code,
              'code',
              'ALREADY_COMPLETED',
            ),
          ),
        );
      });
    });

    group('TaskException', () {
      test('has correct default values', () {
        const exception = TaskException('test');
        expect(exception.code, equals('TASK_ERROR'));
        expect(exception.statusCode, equals(400));
      });

      test('toString contains code and message', () {
        const exception = TaskException('something broke', code: 'BROKEN');
        expect(exception.toString(), contains('BROKEN'));
        expect(exception.toString(), contains('something broke'));
      });
    });
  });
}
