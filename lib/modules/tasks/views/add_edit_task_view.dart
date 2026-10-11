import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_strings.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/task_enums.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/task_controller.dart';

class AddEditTaskView extends GetView<TaskController> {
  const AddEditTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final isEdit = arguments?['isEdit'] as bool? ?? false;
    final task = arguments?['task'] as TaskModel?;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Initialize controllers
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController =
        TextEditingController(text: task?.description ?? '');
    final selectedDate = Rx<DateTime>(task?.dueDate ?? DateTime.now());
    final selectedTime = Rx<TimeOfDay>(
      TimeOfDay.fromDateTime(task?.dueDate ?? DateTime.now()),
    );
    final selectedPriority = Rx<TaskPriority>(
      task?.priority ?? TaskPriority.medium,
    );

    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;

    Future<void> saveTask() async {
      print('AddEditTaskView: saveTask called - isEdit: $isEdit');
      if (!formKey.currentState!.validate()) {
        print('AddEditTaskView: Form validation failed');
        return;
      }

      isLoading.value = true;

      try {
        final now = DateTime.now();
        final dueDateTime = DateTime(
          selectedDate.value.year,
          selectedDate.value.month,
          selectedDate.value.day,
          selectedTime.value.hour,
          selectedTime.value.minute,
        );

        final taskModel = TaskModel(
          id: task?.id ?? '',
          userId: '', // Will be set by service
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          dueDate: dueDateTime,
          priority: selectedPriority.value,
          isCompleted: task?.isCompleted ?? false,
          createdAt: task?.createdAt ?? now,
          updatedAt: now,
        );

        print('AddEditTaskView: Task model created - ${taskModel.title}');

        if (isEdit && task != null) {
          print('AddEditTaskView: Updating task');
          await controller.updateTask(taskModel);
        } else {
          print('AddEditTaskView: Adding new task');
          await controller.addTask(taskModel);
        }

        print('AddEditTaskView: Navigating back');
        Get.back();
      } catch (e) {
        print('AddEditTaskView: Error saving task - ${e.toString()}');
        // Error handled in controller
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? AppStrings.editTask : AppStrings.addTask),
        actions: [
          TextButton(
            onPressed: () {
              print('AddEditTaskView: Cancel button pressed');
              Get.back();
            },
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                CustomTextField(
                  label: AppStrings.taskTitle,
                  hint: AppStrings.taskTitleHint,
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.errorFieldRequired;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Description Field
                CustomTextField(
                  label: AppStrings.taskDescription,
                  hint: AppStrings.taskDescriptionPlaceholder,
                  controller: descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Due Date Picker
                Text(
                  AppStrings.dueDate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => InkWell(
                    onTap: () async {
                      print('AddEditTaskView: Date picker tapped');
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        print('AddEditTaskView: Date selected: $picked');
                        selectedDate.value = picked;
                      } else {
                        print('AddEditTaskView: Date picker cancelled');
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM d, yyyy').format(selectedDate.value),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Due Time Picker
                Text(
                  AppStrings.dueTime,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => InkWell(
                    onTap: () async {
                      print('AddEditTaskView: Time picker tapped');
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime.value,
                      );
                      if (picked != null) {
                        print('AddEditTaskView: Time selected: $picked');
                        selectedTime.value = picked;
                      } else {
                        print('AddEditTaskView: Time picker cancelled');
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime.value.format(context),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Priority Dropdown
                Text(
                  AppStrings.priority,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TaskPriority>(
                        value: selectedPriority.value,
                        isExpanded: true,
                        items: TaskPriority.values.map((priority) {
                          return DropdownMenuItem<TaskPriority>(
                            value: priority,
                            child: Row(
                              children: [
                                _buildPriorityIcon(priority),
                                const SizedBox(width: 12),
                                Text(
                                  priority.name.capitalize!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          print('AddEditTaskView: Priority changed to: $value');
                          if (value != null) {
                            selectedPriority.value = value;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                Obx(
                  () => CustomButton(
                    text: AppStrings.saveTask,
                    onPressed: saveTask,
                    isLoading: isLoading.value,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = AppColors.priorityHigh;
        break;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
        break;
      case TaskPriority.low:
        color = AppColors.priorityLow;
        break;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}


