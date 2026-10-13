import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final Task? existingTask;

  const AddTaskDialog({
    super.key,
    this.existingTask,
  });

  static Future<void> show(BuildContext context, {Task? existingTask}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskDialog(existingTask: existingTask),
    );
  }

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagInputController;

  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;
  late List<String> _selectedCategories;

  final List<String> _availableCategories = [
    'Delivery',
    'Shift',
    'Ride',
    'Freelance',
    'Work',
    'Personal',
    'Study',
    'Habit',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingTask?.description ?? '');
    _tagInputController = TextEditingController();

    _selectedPriority = widget.existingTask?.priority ?? TaskPriority.medium;
    _selectedDate = widget.existingTask?.dueDate ?? DateTime.now();
    _selectedCategories = widget.existingTask != null
        ? List<String>.from(widget.existingTask!.categories)
        : ['Personal'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.existingTask != null) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        dueDate: _selectedDate,
        priority: _selectedPriority,
        categories: _selectedCategories.isEmpty ? ['Personal'] : _selectedCategories,
      );
      ref.read(taskProvider.notifier).updateTask(updated);
    } else {
      ref.read(taskProvider.notifier).addTask(
            title: title,
            description: _descriptionController.text.trim(),
            dueDate: _selectedDate,
            priority: _selectedPriority,
            categories: _selectedCategories.isEmpty ? ['Personal'] : _selectedCategories,
          );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Dialog Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Task' : 'Add New Task',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title Field
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              decoration: const InputDecoration(
                hintText: 'Task Title',
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 14),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add some details...',
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16),

            // Due Date & Priority Pickers
            Row(
              children: [
                // Due Date
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              TaskDateUtils.formatTaskDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Priority Selection
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TaskPriority>(
                        value: _selectedPriority,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                        items: TaskPriority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPriority = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Category Chips
            const Text(
              'CATEGORIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._availableCategories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.inputBackground,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(cat);
                        } else {
                          _selectedCategories.remove(cat);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Add Task',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
