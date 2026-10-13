import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../task/task_detail_screen.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'delivery':
        return AppColors.tagOrange;
      case 'shift':
        return AppColors.tagIndigo;
      case 'ride':
        return AppColors.tagGreen;
      case 'freelance':
        return AppColors.tagPurple;
      case 'personal':
        return AppColors.tagOrange;
      case 'work':
        return AppColors.tagDeepOrange;
      case 'app':
        return const Color(0xFFFB923C);
      case 'study':
        return AppColors.tagPurple;
      case 'cf':
        return AppColors.primaryLight;
      case 'habit':
        return AppColors.tagGreen;
      default:
        // Hash tag to consistent palette
        final colors = [
          AppColors.tagOrange,
          AppColors.tagPurple,
          AppColors.tagGreen,
          AppColors.tagDeepOrange,
          AppColors.primaryLight,
        ];
        return colors[tag.hashCode.abs() % colors.length];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFF87171),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x33F87171),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Delete Task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tagRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(taskProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular Toggle Checkbox
              GestureDetector(
                onTap: () {
                  ref.read(taskProvider.notifier).toggleTaskCompletion(task);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? AppColors.primary : const Color(0xFF8B8DF9),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title and Date/Note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.recurringNote ?? TaskDateUtils.formatTaskDate(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isCompleted ? AppColors.textMuted : AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Category Tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: task.categories.map((category) {
                  final color = _getTagColor(category);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
