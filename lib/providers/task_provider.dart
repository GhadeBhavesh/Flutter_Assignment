import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _allTasks = [];
  String _searchQuery = '';
  TaskPriority? _priorityFilter;
  bool? _statusFilter;
  DateTime? _dateFilter;
  String? _categoryFilter;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  StreamSubscription<User?>? _authSubscription;

  TaskPriority? get priorityFilter => _priorityFilter;
  bool? get statusFilter => _statusFilter;
  DateTime? get dateFilter => _dateFilter;
  String? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;

  TaskNotifier() : super(const []) {
    _init();
  }

  void _init() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToTasks(user.uid);
      } else {
        _subscription?.cancel();
        _allTasks = [];
        state = const [];
      }
    });
  }

  void _subscribeToTasks(String uid) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('tasks')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
      (snapshot) {
        _allTasks = snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList();
        _applyFilters();
      },
      onError: (_) {
        // Fallback gracefully on query error
      },
    );
  }

  void _applyFilters() {
    var filtered = List<Task>.from(_allTasks);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((task) {
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch = task.description.toLowerCase().contains(query);
        final tagMatch = task.categories.any(
          (cat) => cat.toLowerCase().contains(query),
        );
        return titleMatch || descMatch || tagMatch;
      }).toList();
    }

    if (_priorityFilter != null) {
      filtered = filtered
          .where((task) => task.priority == _priorityFilter)
          .toList();
    }

    if (_statusFilter != null) {
      filtered = filtered
          .where((task) => task.isCompleted == _statusFilter)
          .toList();
    }

    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filtered = filtered
          .where((task) => task.categories.contains(_categoryFilter))
          .toList();
    }

    if (_dateFilter != null) {
      filtered = filtered
          .where(
            (task) =>
                task.dueDate.year == _dateFilter!.year &&
                task.dueDate.month == _dateFilter!.month &&
                task.dueDate.day == _dateFilter!.day,
          )
          .toList();
    }

    state = filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    List<String> categories = const ['Personal'],
    String? recurringNote,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final task = Task(
      id: '',
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      priority: priority,
      userId: user.uid,
      categories: categories.isEmpty ? const ['Personal'] : categories,
      recurringNote: recurringNote?.trim(),
    );

    await _firestore.collection('tasks').add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedStatus = !task.isCompleted;
    await _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': updatedStatus,
    });
  }

  void setFilters({
    TaskPriority? priority,
    bool? status,
    DateTime? date,
    String? category,
  }) {
    _priorityFilter = priority;
    _statusFilter = status;
    _dateFilter = date;
    _categoryFilter = category;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _priorityFilter = null;
    _statusFilter = null;
    _dateFilter = null;
    _categoryFilter = null;
    state = _allTasks;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
