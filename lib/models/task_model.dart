enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final String userId;
  final List<String> categories;
  final String? recurringNote;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.userId,
    this.categories = const ['Personal'],
    this.recurringNote,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    String? userId,
    List<String>? categories,
    String? recurringNote,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      categories: categories ?? this.categories,
      recurringNote: recurringNote ?? this.recurringNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'userId': userId,
      'categories': categories,
      if (recurringNote != null) 'recurringNote': recurringNote,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    final rawPriority = map['priority']?.toString() ?? '';
    final priority = TaskPriority.values.firstWhere(
      (e) => e.name == rawPriority || e.toString() == rawPriority,
      orElse: () => TaskPriority.low,
    );

    List<String> parsedCategories;
    if (map['categories'] != null && map['categories'] is List) {
      parsedCategories = (map['categories'] as List)
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    } else {
      parsedCategories = switch (priority) {
        TaskPriority.high => const ['App', 'Work'],
        TaskPriority.medium => const ['Personal'],
        TaskPriority.low => const ['Study'],
      };
    }

    DateTime parsedDueDate;
    try {
      parsedDueDate = DateTime.parse(map['dueDate']?.toString() ?? '');
    } catch (_) {
      parsedDueDate = DateTime.now();
    }

    return Task(
      id: documentId,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dueDate: parsedDueDate,
      priority: priority,
      isCompleted: map['isCompleted'] == true,
      userId: map['userId']?.toString() ?? '',
      categories: parsedCategories.isEmpty ? const ['Personal'] : parsedCategories,
      recurringNote: map['recurringNote']?.toString(),
    );
  }
}
