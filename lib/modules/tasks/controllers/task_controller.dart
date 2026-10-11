import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_strings.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/services/task_service.dart';

class TaskController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();

  // Reactive state
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<TaskFilter> currentFilter = TaskFilter.all.obs;
  final Rx<TaskSort> currentSort = TaskSort.dueDate.obs;
  final RxBool isLoading = false.obs;

  // Computed reactive values
  int get totalTasks => tasks.length;
  int get completedTasks =>
      tasks.where((task) => task.isCompleted).length;
  int get pendingTasks =>
      tasks.where((task) => !task.isCompleted).length;

  // Filtered and sorted tasks
  List<TaskModel> get filteredTasks {
    var filtered = <TaskModel>[];

    // Apply filter
    switch (currentFilter.value) {
      case TaskFilter.all:
        filtered = tasks.toList();
        break;
      case TaskFilter.pending:
        filtered = tasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filtered = tasks.where((task) => task.isCompleted).toList();
        break;
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sort
    switch (currentSort.value) {
      case TaskSort.dueDate:
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSort.priority:
        filtered.sort((a, b) {
          final priorityOrder = {
            TaskPriority.high: 0,
            TaskPriority.medium: 1,
            TaskPriority.low: 2,
          };
          return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        });
        break;
      case TaskSort.createdAt:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    _fetchTasks();
  }

  // Fetch tasks from Firestore
  Future<void> _fetchTasks() async {
    isLoading.value = true;
    try {
      _taskService.getTasksStream().listen((taskList) {
        tasks.assignAll(taskList);
        _updateCounts();
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        AppStrings.errorLoadTasks,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update task counts
  void _updateCounts() {
    // Counts are computed properties, no need to update
  }

  // Add new task
  Future<void> addTask(TaskModel task) async {
    isLoading.value = true;
    try {
      await _taskService.addTask(task);
      Get.snackbar(
        'Success',
        AppStrings.successTaskSaved,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        AppStrings.errorSaveTask,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update existing task
  Future<void> updateTask(TaskModel task) async {
    isLoading.value = true;
    try {
      await _taskService.updateTask(task);
      Get.snackbar(
        'Success',
        AppStrings.successTaskSaved,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        AppStrings.errorSaveTask,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    isLoading.value = true;
    try {
      await _taskService.deleteTask(taskId);
      Get.snackbar(
        'Success',
        AppStrings.successTaskDeleted,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        AppStrings.errorDeleteTask,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _taskService.toggleTaskCompletion(taskId, isCompleted);
      if (isCompleted) {
        Get.snackbar(
          'Success',
          AppStrings.successTaskCompleted,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        AppStrings.errorSaveTask,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Set filter
  void setFilter(TaskFilter filter) {
    currentFilter.value = filter;
  }

  // Set sort
  void setSort(TaskSort sort) {
    currentSort.value = sort;
  }

  // Navigate to add task
  void goToAddTask() {
    Get.toNamed('/add-edit-task', arguments: {'isEdit': false});
  }

  // Navigate to edit task
  void goToEditTask(TaskModel task) {
    Get.toNamed('/add-edit-task', arguments: {'isEdit': true, 'task': task});
  }

  // Navigate to task details
  void goToTaskDetails(TaskModel task) {
    Get.toNamed('/task-details', arguments: {'task': task});
  }

  // Delete task with confirmation
  void deleteTaskWithConfirmation(String taskId) {
    Get.defaultDialog(
      title: AppStrings.deleteDialogTitle,
      middleText: AppStrings.deleteDialogMessage,
      textConfirm: AppStrings.delete,
      textCancel: AppStrings.cancel,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      onConfirm: () async {
        Get.back();
        await deleteTask(taskId);
      },
    );
  }
}
