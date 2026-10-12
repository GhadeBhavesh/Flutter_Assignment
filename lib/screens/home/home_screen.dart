import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../auth/login_screen.dart';
import 'widgets/add_task_dialog.dart';
import 'widgets/filter_dialog.dart';
import 'widgets/task_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
                title: const Text('Filter Tasks', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  FilterDialog.show(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                title: const Text('Clear Filters', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  _searchController.clear();
                  ref.read(taskProvider.notifier).clearFilters();
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.tagRed),
                title: const Text('Log Out', style: TextStyle(color: AppColors.tagRed, fontWeight: FontWeight.w600)),
                onTap: () async {
                  final nav = Navigator.of(context);
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).signOut();
                  if (!mounted) return;
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<Task>> _groupTasks(List<Task> tasks) {
    final sorted = List<Task>.from(tasks)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final Map<String, List<Task>> groups = {};

    for (final task in sorted) {
      final key = TaskDateUtils.getGroupingKey(task.dueDate);
      groups.putIfAbsent(key, () => []).add(task);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final groupedTasks = _groupTasks(tasks);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Order priority for group headers
    final groupKeys = groupedTasks.keys.toList()
      ..sort((a, b) {
        int getWeight(String k) {
          if (k == 'Today') return 0;
          if (k == 'Tomorrow') return 1;
          if (k == 'This week') return 2;
          if (k == 'Overdue') return -1;
          return 3;
        }

        final wA = getWeight(a);
        final wB = getWeight(b);
        if (wA != wB) return wA.compareTo(wB);
        return a.compareTo(b);
      });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // Curved Top Banner Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7578F8),
                    Color(0xFF6366F1),
                  ],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Translucent Decorative Curves
                    Positioned(
                      left: -35,
                      top: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -40,
                      bottom: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Header Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Nav: Grid icon, Search pill, Options circle
                          Row(
                            children: [
                              // Grid Icon
                              const Icon(
                                Icons.grid_view_rounded,
                                color: Colors.white,
                                size: 24,
                              ),

                              const SizedBox(width: 14),

                              // Search Pill
                              Expanded(
                                child: Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(19),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search_rounded,
                                        color: Color(0xFF9E9E9E),
                                        size: 19,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          onChanged: (val) {
                                            ref
                                                .read(taskProvider.notifier)
                                                .setSearchQuery(val);
                                          },
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: AppColors.textPrimary,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Search tasks...',
                                            hintStyle: TextStyle(
                                              color: Color(0xFFB0B7C3),
                                              fontSize: 13,
                                            ),
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      if (_searchController.text.isNotEmpty)
                                        GestureDetector(
                                          onTap: () {
                                            _searchController.clear();
                                            ref
                                                .read(taskProvider.notifier)
                                                .setSearchQuery('');
                                            _searchFocusNode.unfocus();
                                          },
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Options Button
                              GestureDetector(
                                onTap: _showOptionsMenu,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Date Subtitle
                          Text(
                            TaskDateUtils.formatHeaderDate(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Main Title
                          const Text(
                            'My tasks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Body: Task list or empty state (Overflow-proof)
            Expanded(
              child: tasks.isEmpty
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBgLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.task_alt_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap the + button below to create your first task.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      itemCount: groupKeys.length,
                      itemBuilder: (context, index) {
                        final groupKey = groupKeys[index];
                        final groupItems = groupedTasks[groupKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 8),
                              child: Text(
                                groupKey,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            ...groupItems.map((task) => TaskCard(task: task)),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
            ),

            // Clean Bottom Navigation Bar (Hidden when typing to prevent keyboard overflow)
            if (!isKeyboardVisible)
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // List icon (Active)
                      IconButton(
                        icon: const Icon(
                          Icons.format_list_bulleted_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        onPressed: () {},
                      ),

                      // Center Floating Add Button
                      GestureDetector(
                        onTap: () => AddTaskDialog.show(context),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF7A79FB),
                                AppColors.primary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.38),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      // Calendar icon
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFFBAC0CD),
                          size: 22,
                        ),
                        onPressed: () {
                          FilterDialog.show(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
