import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_strings.dart';
import '../../../shared/widgets/task_card.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/task_enums.dart';

class HomeView extends GetView<TaskController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, authController, isDarkMode),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    _buildStatisticsCards(context, isDarkMode),
                    const SizedBox(height: 24),

                    // Search Bar
                    _buildSearchBar(context, isDarkMode),
                    const SizedBox(height: 16),

                    // Filter Chips
                    _buildFilterChips(context, isDarkMode),
                    const SizedBox(height: 16),

                    // Sort Options
                    _buildSortOptions(context, isDarkMode),
                    const SizedBox(height: 16),

                    // Task List
                    _buildTaskList(context, isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAddTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthController authController,
    bool isDarkMode,
  ) {
    final userName = authController.nameController.text.isNotEmpty
        ? authController.nameController.text
        : (authController.emailController.text.isNotEmpty
            ? authController.emailController.text.split('@')[0]
            : 'User');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.homeTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          IconButton(
            onPressed: authController.logout,
            icon: const Icon(Icons.logout_outlined),
            color: AppColors.error,
            tooltip: AppStrings.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, bool isDarkMode) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Total',
              controller.totalTasks,
              AppColors.primary,
              Icons.task_alt,
              isDarkMode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Completed',
              controller.completedTasks,
              AppColors.success,
              Icons.check_circle_outline,
              isDarkMode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Pending',
              controller.pendingTasks,
              AppColors.warning,
              Icons.pending_outlined,
              isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          prefixIcon: const Icon(Icons.search_outlined),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDarkMode) {
    return Obx(
      () => Wrap(
        spacing: 8,
        children: [
          _buildFilterChip(
            context,
            AppStrings.allTasks,
            TaskFilter.all,
            isDarkMode,
          ),
          _buildFilterChip(
            context,
            AppStrings.pendingTasks,
            TaskFilter.pending,
            isDarkMode,
          ),
          _buildFilterChip(
            context,
            AppStrings.completedTasks,
            TaskFilter.completed,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    TaskFilter filter,
    bool isDarkMode,
  ) {
    return Obx(
      () => FilterChip(
        label: Text(label),
        selected: controller.currentFilter.value == filter,
        onSelected: (_) => controller.setFilter(filter),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: controller.currentFilter.value == filter
              ? Colors.white
              : (isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary),
        ),
        backgroundColor: isDarkMode
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context, bool isDarkMode) {
    return Obx(
      () => Row(
        children: [
          Icon(
            Icons.sort_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Sort by:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(width: 8),
          _buildSortOption(
            context,
            'Due Date',
            TaskSort.dueDate,
            isDarkMode,
          ),
          const SizedBox(width: 8),
          _buildSortOption(
            context,
            'Priority',
            TaskSort.priority,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String label,
    TaskSort sort,
    bool isDarkMode,
  ) {
    return Obx(
      () => InkWell(
        onTap: () => controller.setSort(sort),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: controller.currentSort.value == sort
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.currentSort.value == sort
                  ? AppColors.primary
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: controller.currentSort.value == sort
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: controller.currentSort.value == sort
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, bool isDarkMode) {
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final filteredTasks = controller.filteredTasks;

        if (filteredTasks.isEmpty) {
          return _buildEmptyState(context, isDarkMode);
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(
                task: task,
                onTap: () => controller.goToTaskDetails(task),
                onEdit: () => controller.goToEditTask(task),
                onDelete: () => controller.deleteTaskWithConfirmation(task.id),
                onToggleComplete: (isCompleted) {
                  controller.toggleTaskCompletion(task.id, isCompleted);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noTasks,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noTasksDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
