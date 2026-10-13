import 'package:flutter_test/flutter_test.dart';
import 'package:task_management/core/utils/date_utils.dart';
import 'package:task_management/models/task_model.dart';

void main() {
  group('Task Model & Serialization Tests', () {
    test('Task model serialize toMap and deserialize fromMap correctly', () {
      final now = DateTime(2026, 10, 13, 14, 30);
      final task = Task(
        id: 'task-101',
        title: 'Morning Delivery Shift',
        description: 'Complete 5 drop-offs in Downtown area',
        dueDate: now,
        priority: TaskPriority.high,
        isCompleted: false,
        userId: 'user-abc',
        categories: const ['Delivery', 'Shift'],
        recurringNote: 'Daily Shift',
      );

      final map = task.toMap();
      expect(map['title'], equals('Morning Delivery Shift'));
      expect(map['description'], equals('Complete 5 drop-offs in Downtown area'));
      expect(map['dueDate'], equals(now.toIso8601String()));
      expect(map['priority'], equals('high'));
      expect(map['isCompleted'], isFalse);
      expect(map['userId'], equals('user-abc'));
      expect(map['categories'], equals(['Delivery', 'Shift']));
      expect(map['recurringNote'], equals('Daily Shift'));

      final parsed = Task.fromMap(map, 'task-101');
      expect(parsed.id, equals('task-101'));
      expect(parsed.title, equals(task.title));
      expect(parsed.description, equals(task.description));
      expect(parsed.dueDate, equals(task.dueDate));
      expect(parsed.priority, equals(TaskPriority.high));
      expect(parsed.isCompleted, isFalse);
      expect(parsed.userId, equals('user-abc'));
      expect(parsed.categories, equals(['Delivery', 'Shift']));
    });

    test('Task copyWith updates selected fields', () {
      final task = Task(
        id: '1',
        title: 'Original Title',
        description: 'Desc',
        dueDate: DateTime(2026, 10, 15),
        priority: TaskPriority.low,
        userId: 'u1',
      );

      final updated = task.copyWith(
        title: 'Updated Title',
        priority: TaskPriority.high,
        isCompleted: true,
      );

      expect(updated.title, equals('Updated Title'));
      expect(updated.priority, equals(TaskPriority.high));
      expect(updated.isCompleted, isTrue);
      expect(updated.id, equals('1'));
      expect(updated.description, equals('Desc'));
    });
  });

  group('Task Sorting & Filtering Logic', () {
    test('Tasks sort chronologically by dueDate (earliest to latest)', () {
      final t1 = Task(
        id: '1',
        title: 'Later Task',
        description: '',
        dueDate: DateTime(2026, 10, 20),
        priority: TaskPriority.medium,
        userId: 'u1',
      );
      final t2 = Task(
        id: '2',
        title: 'Earlier Task',
        description: '',
        dueDate: DateTime(2026, 10, 14),
        priority: TaskPriority.high,
        userId: 'u1',
      );
      final t3 = Task(
        id: '3',
        title: 'Earliest Task',
        description: '',
        dueDate: DateTime(2026, 10, 10),
        priority: TaskPriority.low,
        userId: 'u1',
      );

      final tasks = [t1, t2, t3];
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      expect(tasks[0].id, equals('3')); // Oct 10
      expect(tasks[1].id, equals('2')); // Oct 14
      expect(tasks[2].id, equals('1')); // Oct 20
    });

    test('Tasks filter by priority and status correctly', () {
      final list = [
        Task(
          id: '1',
          title: 'High Pending',
          description: '',
          dueDate: DateTime.now(),
          priority: TaskPriority.high,
          isCompleted: false,
          userId: 'u1',
        ),
        Task(
          id: '2',
          title: 'High Completed',
          description: '',
          dueDate: DateTime.now(),
          priority: TaskPriority.high,
          isCompleted: true,
          userId: 'u1',
        ),
        Task(
          id: '3',
          title: 'Low Pending',
          description: '',
          dueDate: DateTime.now(),
          priority: TaskPriority.low,
          isCompleted: false,
          userId: 'u1',
        ),
      ];

      // Filter by High priority
      final highTasks = list.where((t) => t.priority == TaskPriority.high).toList();
      expect(highTasks.length, equals(2));

      // Filter by completed status
      final completedTasks = list.where((t) => t.isCompleted == true).toList();
      expect(completedTasks.length, equals(1));
      expect(completedTasks.first.id, equals('2'));

      // Filter by pending status
      final pendingTasks = list.where((t) => t.isCompleted == false).toList();
      expect(pendingTasks.length, equals(2));
    });
  });

  group('Date Utility Tests', () {
    test('formatTaskDate formats date correctly', () {
      final date = DateTime(2026, 10, 13);
      final formatted = TaskDateUtils.formatTaskDate(date);
      expect(formatted, equals('13 Oct'));
    });

    test('getGroupingKey groups Today and Tomorrow accurately', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      expect(TaskDateUtils.getGroupingKey(today), equals('Today'));
      expect(TaskDateUtils.getGroupingKey(tomorrow), equals('Tomorrow'));
    });
  });
}
