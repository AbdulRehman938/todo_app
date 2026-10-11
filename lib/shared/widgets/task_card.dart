import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/constants/app_colors.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_enums.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleComplete;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Card(
      elevation: task.isCompleted ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? AppColors.border.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      color: isDarkMode
          ? (task.isCompleted ? AppColors.cardDark : AppColors.cardElevatedDark)
          : (task.isCompleted ? AppColors.card : AppColors.cardElevated),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority Badge
                  _buildPriorityBadge(),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: task.isCompleted
                                ? AppColors.textTertiary
                                : (isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status Checkbox
                  if (onToggleComplete != null)
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          onToggleComplete!(value);
                        }
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Description
              if (task.description.isNotEmpty) ...[
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: task.isCompleted
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              // Due Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: isOverdue
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(task.dueDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                  const Spacer(),
                  // Action Buttons
                  if (showActions) ...[
                    if (onEdit != null)
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.info,
                        onTap: onEdit!,
                      ),
                    if (onDelete != null)
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        onTap: onDelete!,
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (task.priority) {
      case TaskPriority.high:
        backgroundColor = AppColors.priorityHighLight;
        textColor = AppColors.priorityHigh;
        label = 'High';
        break;
      case TaskPriority.medium:
        backgroundColor = AppColors.priorityMediumLight;
        textColor = AppColors.priorityMedium;
        label = 'Medium';
        break;
      case TaskPriority.low:
        backgroundColor = AppColors.priorityLowLight;
        textColor = AppColors.priorityLow;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${DateFormat('h:mm a').format(date)}';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }
}
