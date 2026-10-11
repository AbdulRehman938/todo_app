# Features and Backend Integration

## Table of Contents
1. [User Authentication](#user-authentication)
2. [Task Management](#task-management)
3. [Real-time Data Synchronization](#real-time-data-synchronization)
4. [Search, Filtering, and Sorting](#search-filtering-and-sorting)
5. [UI Design and Material 3 Compliance](#ui-design-and-material-3-compliance)
6. [Error Handling](#error-handling)

---

## User Authentication

### Authentication Flow

```
┌──────────────┐
│ Splash Screen │
│  (2 seconds)  │
└──────┬───────┘
       │
       │ Check auth state
       ▼
┌──────────────┐    ┌──────────────┐
│ Logged In?   │───▶│   No         │───▶ Login View
│   Yes        │    └──────────────┘
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Home View   │
└──────────────┘
```

### Firebase Authentication Integration

**Service Layer (auth_service.dart):**

```dart
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user access
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

**Key Features:**

1. **User Registration:**
```dart
Future<UserCredential> registerWithEmailAndPassword({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    // Step 1: Create user account
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Step 2: Update display name
    await userCredential.user?.updateDisplayName(name);

    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  } catch (e) {
    throw Exception('Registration failed: ${e.toString()}');
  }
}
```

**Process:**
1. Validates email and password format (Firebase)
2. Creates user account in Firebase Auth
3. Updates user display name
4. Returns UserCredential with user information

2. **User Login:**
```dart
Future<UserCredential> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  } catch (e) {
    throw Exception('Sign in failed: ${e.toString()}');
  }
}
```

**Process:**
1. Validates credentials against Firebase
2. Returns UserCredential on success
3. Session persists automatically by Firebase

3. **User Logout:**
```dart
Future<void> signOut() async {
  try {
    await _auth.signOut();
  } catch (e) {
    throw Exception('Sign out failed: ${e.toString()}');
  }
}
```

**Process:**
1. Signs out current user
2. Clears session from Firebase
3. Auth state stream updates automatically

4. **Password Reset:**
```dart
Future<void> sendPasswordResetEmail({required String email}) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  } catch (e) {
    throw Exception('Password reset failed: ${e.toString()}');
  }
}
```

### Controller Layer (auth_controller.dart)

**Registration with Validation:**
```dart
Future<void> signup() async {
  // Step 1: Validate form
  if (!signupFormKey.currentState!.validate()) {
    return;
  }

  isLoading.value = true;

  try {
    // Step 2: Call service
    await _authService.registerWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
    );

    // Step 3: Clear form
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    // Step 4: Show success
    Get.snackbar(
      'Success',
      AppStrings.successSignup,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Step 5: Navigate
    _navigateToHome();
  } catch (e) {
    // Step 6: Show error
    Get.snackbar(
      'Error',
      e.toString().replaceAll('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  } finally {
    isLoading.value = false;
  }
}
```

**Validation Rules:**
```dart
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.errorFieldRequired;
  }
  if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.errorFieldRequired;
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return AppStrings.errorEmailInvalid;
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.errorFieldRequired;
  }
  if (value.trim().length < 6) {
    return AppStrings.errorPasswordShort;
  }
  return null;
}

String? validateConfirmPassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.errorFieldRequired;
  }
  if (value.trim() != passwordController.text.trim()) {
    return AppStrings.errorPasswordMismatch;
  }
  return null;
}
```

### UI Implementation (login_view.dart)

**Responsive Layout:**
```dart
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: keyboardHeight > 0 ? keyboardHeight + 24 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              (keyboardHeight > 0 ? keyboardHeight + 24 : 24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            // App Name
            // Form
          ],
        ),
      ),
    ),
  ),
)
```

**Keyboard-Safe Design:**
- `SingleChildScrollView` prevents overflow when keyboard appears
- `viewInsets.bottom` detects keyboard height
- Dynamic bottom padding pushes content up
- `ConstrainedBox` ensures minimum height

**Form Implementation:**
```dart
Form(
  key: controller.loginFormKey,
  child: Column(
    children: [
      CustomTextField(
        label: AppStrings.emailLabel,
        hint: AppStrings.emailHint,
        controller: controller.emailController,
        prefixIcon: Icons.email_outlined,
        isEmail: true,
        validator: controller.validateEmail,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      Obx(
        () => CustomTextField(
          label: AppStrings.passwordLabel,
          hint: AppStrings.passwordHint,
          controller: controller.passwordController,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: controller.validatePassword,
          textInputAction: TextInputAction.done,
          onEditingComplete: () => controller.login(),
        ),
      ),
      const SizedBox(height: 8),
      // Forgot password link
      const SizedBox(height: 24),
      Obx(
        () => CustomButton(
          text: AppStrings.loginButton,
          onPressed: controller.login,
          isLoading: controller.isLoading.value,
          isFullWidth: true,
        ),
      ),
    ],
  ),
)
```

### Auth State Management

**Stream-based Auth Monitoring:**
```dart
// In any widget that needs auth state
class HomeView extends GetView<HomeController> {
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => authController.isLoggedIn
          ? HomeContent()
          : LoginPrompt(),
    );
  }
}
```

**Alternative - Using Auth Stream:**
```dart
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget();
        }

        if (snapshot.data == null) {
          return LoginView();
        }

        return child;
      },
    );
  }
}
```

---

## Task Management

### Firestore Data Structure

**Hierarchical Collection Structure:**
```
todo-app-3c9b7 (Project)
└── users (Collection)
    ├── {userId1} (Document)
    │   └── tasks (Subcollection)
    │       ├── {taskId1} (Document)
    │       │   ├── title: "Buy groceries"
    │       │   ├── description: "Milk, eggs, bread"
    │       │   ├── dueDate: Timestamp(2024-01-15)
    │       │   ├── priority: "high"
    │       │   ├── isCompleted: false
    │       │   ├── createdAt: Timestamp(...)
    │       │   └── updatedAt: Timestamp(...)
    │       └── {taskId2} (Document)
    │       └── ...
    └── {userId2} (Document)
        └── tasks (Subcollection)
            └── ...
```

**Benefits of This Structure:**
1. **Data Isolation**: Each user's tasks are in their own subcollection
2. **Security**: Firestore rules can enforce user-specific access
3. **Scalability**: Efficient queries within user subcollection
4. **Privacy**: Users can only access their own data

### CRUD Operations

#### 1. Create (Add Task)

**Service Implementation:**
```dart
Future<String> addTask(TaskModel task) async {
  try {
    final taskData = task.toMap();
    taskData.remove('id');  // Firestore will generate ID
    taskData['createdAt'] = FieldValue.serverTimestamp();
    taskData['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _tasksCollection.add(taskData);
    return docRef.id;
  } catch (e) {
    throw Exception('Failed to add task: ${e.toString()}');
  }
}
```

**Controller Call:**
```dart
Future<void> addTask(TaskModel task) async {
  isLoading.value = true;
  try {
    await _taskService.addTask(task);
    Get.snackbar('Success', AppStrings.successTaskSaved);
  } catch (e) {
    Get.snackbar('Error', AppStrings.errorSaveTask);
    rethrow;
  } finally {
    isLoading.value = false;
  }
}
```

**UI Call:**
```dart
CustomButton(
  text: AppStrings.saveTask,
  onPressed: saveTask,
  isLoading: isLoading.value,
  isFullWidth: true,
)
```

#### 2. Read (Fetch Tasks)

**Real-time Stream:**
```dart
Stream<List<TaskModel>> getTasksStream() {
  return _tasksCollection
      .orderBy('dueDate', descending: false)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return TaskModel.fromMap(data);
        }).toList();
      });
}
```

**Controller Subscription:**
```dart
void _fetchTasks() async {
  isLoading.value = true;
  try {
    _taskService.getTasksStream().listen((taskList) {
      tasks.assignAll(taskList);
      _updateCounts();
    });
  } catch (e) {
    Get.snackbar('Error', AppStrings.errorLoadTasks);
  } finally {
    isLoading.value = false;
  }
}
```

**Automatic UI Updates:**
```dart
Obx(
  () => ListView.builder(
    itemCount: controller.tasks.length,
    itemBuilder: (context, index) {
      final task = controller.tasks[index];
      return TaskCard(task: task);
    },
  ),
)
```

#### 3. Update (Edit Task)

**Service Implementation:**
```dart
Future<void> updateTask(TaskModel task) async {
  try {
    final taskData = task.toMap();
    taskData.remove('id');  // Don't update document ID
    taskData['updatedAt'] = FieldValue.serverTimestamp();

    await _tasksCollection.doc(task.id).update(taskData);
  } catch (e) {
    throw Exception('Failed to update task: ${e.toString()}');
  }
}
```

**Partial Update Optimization:**
```dart
// Only update specific fields
await _tasksCollection.doc(taskId).update({
  'isCompleted': true,
  'updatedAt': FieldValue.serverTimestamp(),
});
```

#### 4. Delete (Remove Task)

**Service Implementation:**
```dart
Future<void> deleteTask(String taskId) async {
  try {
    await _tasksCollection.doc(taskId).delete();
  } catch (e) {
    throw Exception('Failed to delete task: ${e.toString()}');
  }
}
```

**With Confirmation:**
```dart
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
```

### User-Scoped Data Isolation

**Collection Reference with User ID:**
```dart
CollectionReference get _tasksCollection {
  final userId = Get.find<AuthService>().currentUserId;
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  return _firestore.collection('users').doc(userId).collection('tasks');
}
```

**Security Benefits:**
1. **Authentication Guard**: Throws exception if not logged in
2. **Data Privacy**: Users can only access their own subcollection
3. **Query Efficiency**: Queries only relevant user data
4. **Cost Efficiency**: No cross-user data transfer

---

## Real-time Data Synchronization

### Firestore Streams

**How Streams Work:**
```
Firestore Database
       │
       │ Data changes (add/update/delete)
       │
       ▼
   Firestore Stream
       │
       │ Stream event
       ▼
Controller (listen)
       │
       │ Update RxList
       ▼
    UI (Obx)
       │
       ▼
  Automatic Rebuild
```

**Stream Implementation:**
```dart
Stream<List<TaskModel>> getTasksStream() {
  return _tasksCollection
      .orderBy('dueDate', descending: false)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return TaskModel.fromMap(data);
        }).toList();
      });
}
```

**Controller Subscription:**
```dart
void _fetchTasks() async {
  isLoading.value = true;
  try {
    _taskService.getTasksStream().listen((taskList) {
      tasks.assignAll(taskList);  // Automatic UI update
      _updateCounts();
    });
  } catch (e) {
    Get.snackbar('Error', AppStrings.errorLoadTasks);
  } finally {
    isLoading.value = false;
  }
}
```

**Automatic UI Updates:**
```dart
Obx(
  () => ListView.builder(
    itemCount: controller.tasks.length,
    itemBuilder: (context, index) {
      final task = controller.tasks[index];
      return TaskCard(
        task: task,
        onToggleComplete: (isCompleted) {
          controller.toggleTaskCompletion(task.id, isCompleted);
        },
      );
    },
  ),
)
```

**Stream Lifecycle:**
1. **Subscription**: When controller initializes
2. **Events**: Fired on any data change
3. **Unsubscription**: When controller disposes (automatic)

### Real-time Toggle Completion

**Service:**
```dart
Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
  try {
    await _tasksCollection.doc(taskId).update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    throw Exception('Failed to toggle task completion: ${e.toString()}');
  }
}
```

**Controller:**
```dart
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
    Get.snackbar('Error', AppStrings.errorSaveTask);
  }
}
```

**Real-time Flow:**
1. User taps checkbox on task card
2. Controller calls `toggleTaskCompletion()`
3. Service updates Firestore
4. Firestore stream detects change
5. Controller updates `tasks` list
6. UI automatically rebuilds with new state
7. Checkbox visual updates automatically

### Offline Support

**Firestore Offline Capabilities:**
- Automatic cache when online
- Local writes when offline
- Automatic sync when reconnected
- Optimistic UI updates

**Implementation:**
```dart
// Firebase SDK handles this automatically
// No additional code needed
// Firestore automatically:
// - Caches data locally
// - Queues writes when offline
// - Syncs when connection restored
```

---

## Search, Filtering, and Sorting

### Search Implementation

**Reactive Search Query:**
```dart
final RxString searchQuery = ''.obs;

void setSearchQuery(String query) {
  searchQuery.value = query;
}
```

**Search Algorithm:**
```dart
List<TaskModel> get filteredTasks {
  var filtered = <TaskModel>[];

  // Apply filter first
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
  // ...

  return filtered;
}
```

**UI Search Bar:**
```dart
Container(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
)
```

**Search Features:**
- Case-insensitive matching
- Searches title and description
- Real-time filtering (no submit button)
- Combines with filters and sorts

### Filtering Implementation

**Filter Enum:**
```dart
enum TaskFilter {
  all,
  pending,
  completed,
}
```

**Reactive Filter State:**
```dart
final Rx<TaskFilter> currentFilter = TaskFilter.all.obs;

void setFilter(TaskFilter filter) {
  currentFilter.value = filter;
}
```

**Filter Chips UI:**
```dart
Obx(
  () => Wrap(
    spacing: 8,
    children: [
      _buildFilterChip(context, AppStrings.allTasks, TaskFilter.all),
      _buildFilterChip(context, AppStrings.pendingTasks, TaskFilter.pending),
      _buildFilterChip(context, AppStrings.completedTasks, TaskFilter.completed),
    ],
  ),
)

Widget _buildFilterChip(BuildContext context, String label, TaskFilter filter) {
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
            : AppColors.textPrimary,
      ),
      backgroundColor: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
```

**Filter Logic:**
```dart
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
```

### Sorting Implementation

**Sort Enum:**
```dart
enum TaskSort {
  dueDate,
  priority,
  createdAt,
}
```

**Reactive Sort State:**
```dart
final Rx<TaskSort> currentSort = TaskSort.dueDate.obs;

void setSort(TaskSort sort) {
  currentSort.value = sort;
}
```

**Sort UI:**
```dart
Obx(
  () => Row(
    children: [
      Icon(Icons.sort_outlined, size: 20, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text('Sort by:', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(width: 8),
      _buildSortOption('Due Date', TaskSort.dueDate),
      const SizedBox(width: 8),
      _buildSortOption('Priority', TaskSort.priority),
    ],
  ),
)

Widget _buildSortOption(String label, TaskSort sort) {
  return Obx(
    () => InkWell(
      onTap: () => controller.setSort(sort),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: controller.currentSort.value == sort
              ? AppColors.primary.withOpacity(0.1)
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
          style: TextStyle(
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
```

**Sort Algorithms:**

**By Due Date:**
```dart
case TaskSort.dueDate:
  filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  break;
```
- Sorts chronologically
- Earliest due date first

**By Priority:**
```dart
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
```
- High priority first
- Medium priority second
- Low priority last

**By Creation Date:**
```dart
case TaskSort.createdAt:
  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  break;
```
- Newest tasks first
- Reverse chronological order

### Combined Search + Filter + Sort

**Computed Property:**
```dart
List<TaskModel> get filteredTasks {
  var filtered = <TaskModel>[];

  // Step 1: Apply filter
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

  // Step 2: Apply search
  if (searchQuery.value.isNotEmpty) {
    final query = searchQuery.value.toLowerCase();
    filtered = filtered.where((task) {
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();
  }

  // Step 3: Apply sort
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
```

**Execution Order:**
1. Filter (All/Pending/Completed)
2. Search (title/description)
3. Sort (due date/priority/created at)

**Performance Considerations:**
- Filter applied first (reduces dataset)
- Search applied second (reduces further)
- Sort applied last (sorts smallest dataset)
- O(n log n) sorting complexity acceptable for small-to-medium datasets

---

## UI Design and Material 3 Compliance

### Material 3 Design System

**Key Material 3 Features:**
1. **Dynamic Color**: Colors derived from user's wallpaper
2. **Updated Components**: Cards, buttons, inputs with new styling
3. **Rounded Corners**: 12-28px border radius
4. **Elevation**: Subtle shadows instead of heavy drop shadows
5. **Typography**: System font stack, larger text scales

### Color Palette (app_colors.dart)

**Primary Colors:**
```dart
static const Color primary = Color(0xFF6366F1);      // Indigo/Violet
static const Color primaryDark = Color(0xFF4F46E5);
static const Color primaryLight = Color(0xFF818CF8);
static const Color primaryContainer = Color(0xFFE0E7FF);
```

**Secondary Colors:**
```dart
static const Color secondary = Color(0xFF8B5CF6);    // Purple
static const Color secondaryDark = Color(0xFF7C3AED);
static const Color secondaryLight = Color(0xFFA78BFA);
```

**Background Colors:**
```dart
static const Color background = Color(0xFFFAFAFA);  // Light mode
static const Color backgroundDark = Color(0xFF121212); // Dark mode
static const Color surface = Color(0xFFFFFFFF);
static const Color surfaceDark = Color(0xFF1E1E1E);
```

**Priority Colors:**
```dart
static const Color priorityLow = Color(0xFF10B981);      // Green
static const Color priorityLowLight = Color(0xFFD1FAE5);
static const Color priorityMedium = Color(0xFFF59E0B);    // Orange
static const Color priorityMediumLight = Color(0xFFFEF3C7);
static const Color priorityHigh = Color(0xFFEF4444);     // Red
static const Color priorityHighLight = Color(0xFFFEE2E2);
```

### Typography System

**Text Theme Configuration:**
```dart
textTheme: const TextTheme(
  displayLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  ),
  headlineLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  titleLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  ),
)
```

**Usage:**
```dart
Text(
  AppStrings.homeTitle,
  style: Theme.of(context).textTheme.headlineLarge,
)
```

### Reusable Widgets

#### 1. CustomButton

**Features:**
- Multiple types: Primary, Secondary, Outlined, Text
- Loading state with circular progress indicator
- Icon support
- Disabled state
- Material 3 styling

**Implementation:**
```dart
enum ButtonType {
  primary,
  secondary,
  outlined,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType buttonType;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isFullWidth;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading && !isDisabled;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(buttonType),
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    final button = switch (buttonType) {
      case ButtonType.primary => ElevatedButton(...),
      case ButtonType.secondary => ElevatedButton(...),
      case ButtonType.outlined => OutlinedButton(...),
      case ButtonType.text => TextButton(...),
    };

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
```

**Usage:**
```dart
CustomButton(
  text: AppStrings.loginButton,
  onPressed: controller.login,
  isLoading: controller.isLoading.value,
  isFullWidth: true,
)
```

#### 2. CustomTextField

**Features:**
- Label and hint text
- Prefix and suffix icons
- Password obscuring with toggle
- Validation error display
- Multiple input types (email, number, phone)
- Multi-line support
- Material 3 rounded design

**Implementation:**
```dart
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isEmail;
  final String? Function(String?)? validator;
  // ...
}

@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (widget.label != null) ...[
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
      ],
      TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        validator: widget.validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon)
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(_obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: _toggleObscureText,
                )
              : null,
        ),
      ),
    ],
  );
}
```

**Usage:**
```dart
CustomTextField(
  label: AppStrings.emailLabel,
  hint: AppStrings.emailHint,
  controller: controller.emailController,
  prefixIcon: Icons.email_outlined,
  isEmail: true,
  validator: controller.validateEmail,
)
```

#### 3. TaskCard

**Features:**
- Displays task title and description
- Formatted due date (Today, Tomorrow, Yesterday, or full date)
- Priority badge with color coding
- Status checkbox/toggle
- Edit and delete action buttons
- Completed task styling (strikethrough, dimmed)
- Overdue task highlighting
- Material 3 card design

**Implementation:**
```dart
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleComplete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
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
                  _buildPriorityBadge(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: onToggleComplete,
                  ),
                ],
              ),
              // Description, due date, actions...
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
```

**Usage:**
```dart
TaskCard(
  task: task,
  onTap: () => controller.goToTaskDetails(task),
  onEdit: () => controller.goToEditTask(task),
  onDelete: () => controller.deleteTaskWithConfirmation(task.id),
  onToggleComplete: (isCompleted) {
    controller.toggleTaskCompletion(task.id, isCompleted);
  },
)
```

#### 4. LoadingWidget

**Features:**
- Circular progress indicator
- Shimmer loading effect
- Custom loading message
- List shimmer placeholder

**Implementation:**
```dart
class LoadingWidget extends StatelessWidget {
  final LoadingType loadingType;
  final String? message;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loadingType == LoadingType.circular)
            _buildCircularIndicator()
          else
            _buildShimmer(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message),
          ],
        ],
      ),
    );
  }
}
```

**Usage:**
```dart
Obx(
  () => controller.isLoading.value
      ? LoadingWidget()
      : TaskList(),
)
```

### Responsive Design

**Keyboard-Safe Layouts:**
```dart
SingleChildScrollView(
  padding: EdgeInsets.only(
    left: 24,
    right: 24,
    top: 24,
    bottom: keyboardHeight > 0 ? keyboardHeight + 24 : 24,
  ),
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          (keyboardHeight > 0 ? keyboardHeight + 24 : 24),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [...],
    ),
  ),
)
```

**Responsive Padding:**
```dart
padding: const EdgeInsets.symmetric(
  horizontal: 24,
  vertical: 16,
),
```

**Responsive Text Scaling:**
```dart
builder: (context, child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(
        MediaQuery.of(context).textScaler.scale(1.0),
      ),
    ),
    child: child!,
  );
}
```

### Dark Mode Support

**Theme Configuration:**
```dart
theme: _buildLightTheme(),
darkTheme: _buildDarkTheme(),
themeMode: ThemeMode.system,
```

**Automatic Theme Detection:**
- System theme setting
- Material 3 light/dark color schemes
- Automatic text color adaptation

**Dark Mode Colors:**
```dart
static const Color backgroundDark = Color(0xFF121212);
static const Color surfaceDark = Color(0xFF1E1E1E);
static const Color cardDark = Color(0xFF2C2C2C);
static const Color textPrimaryDark = Color(0xFFF9FAFB);
static const Color textSecondaryDark = Color(0xFF9CA3AF);
```

---

## Error Handling

### Error Handling Strategy

**Three-Layer Error Handling:**

1. **Service Layer**: Catch and translate errors
2. **Controller Layer**: Display user-friendly messages
3. **UI Layer**: Show error states

### Service Layer Error Handling

**AuthService Example:**
```dart
Future<UserCredential> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  } catch (e) {
    throw Exception('Sign in failed: ${e.toString()}');
  }
}

String _handleAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Wrong password provided.';
    case 'email-already-in-use':
      return 'Email is already in use.';
    case 'invalid-email':
      return 'Email address is invalid.';
    case 'weak-password':
      return 'Password is too weak.';
    case 'user-disabled':
      return 'This user account has been disabled.';
    case 'too-many-requests':
      return 'Too many requests. Try again later.';
    default:
      return 'Authentication failed: ${e.message}';
  }
}
```

**TaskService Example:**
```dart
Future<void> deleteTask(String taskId) async {
  try {
    await _tasksCollection.doc(taskId).delete();
  } catch (e) {
    throw Exception('Failed to delete task: ${e.toString()}');
  }
}
```

### Controller Layer Error Handling

**AuthController Example:**
```dart
Future<void> login() async {
  if (!loginFormKey.currentState!.validate()) {
    return;
  }

  isLoading.value = true;

  try {
    await _authService.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    emailController.clear();
    passwordController.clear();

    Get.snackbar(
      'Success',
      AppStrings.successLogin,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    _navigateToHome();
  } catch (e) {
    Get.snackbar(
      'Error',
      e.toString().replaceAll('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  } finally {
    isLoading.value = false;
  }
}
```

**Error Message Pattern:**
1. Remove "Exception:" prefix for cleaner messages
2. Use red background for errors
3. Use green background for success
4. Set appropriate duration (short for success, longer for errors)

### UI Layer Error States

**Loading State:**
```dart
Obx(
  () => controller.isLoading.value
      ? LoadingWidget(message: AppStrings.pleaseWait)
      : TaskList(),
)
```

**Empty State:**
```dart
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.noTasksDescription,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
```

**Validation Error Display:**
```dart
CustomTextField(
  label: AppStrings.emailLabel,
  controller: emailController,
  validator: validateEmail,
  // Automatically shows error below field
)
```

### Snackbar Notifications

**Success Snackbar:**
```dart
Get.snackbar(
  'Success',
  AppStrings.successTaskSaved,
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.green.shade600,
  colorText: Colors.white,
  duration: const Duration(seconds: 2),
)
```

**Error Snackbar:**
```dart
Get.snackbar(
  'Error',
  AppStrings.errorSaveTask,
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.red.shade600,
  colorText: UIErrorText,
  duration: const Duration(seconds: 3),
)
```

**Info Snackbar:**
```dart
Get.snackbar(
  'Info',
  'Task marked as completed',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.blue.shade600,
  colorText: Colors.white,
  duration: const Duration(seconds: 1),
)
```

### Dialog Error Handling

**Confirmation Dialog:**
```dart
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
```

**Dialog Error Handling:**
```dart
try {
  await deleteTask(taskId);
  Get.back();  // Close dialog on success
} catch (e) {
  // Keep dialog open, show error message
  Get.snackbar('Error', 'Failed to delete task');
}
```

---

## Summary

This Flutter To-Do application demonstrates comprehensive feature implementation with:

### Authentication
- Firebase Auth integration
- User registration with validation
- Secure login/logout
- Auth state monitoring
- Password reset functionality

### Task Management
- Complete CRUD operations
- User-scoped data isolation
- Firestore integration
- Optimistic UI updates

### Real-time Sync
- Firestore streams for live updates
- Automatic UI synchronization
- Offline support
- Efficient data queries

### Advanced Features
- Real-time search with filtering
- Multiple filter options (All/Pending/Completed)
- Multiple sort options (Due Date/Priority/Created At)
- Combined search + filter + sort

### UI/UX Excellence
- Material 3 design compliance
- Modern color palette
- Responsive layouts
- Dark mode support
- Reusable components
- Smooth animations
- Professional typography

### Error Handling
- Three-layer error handling
- User-friendly error messages
- Loading states
- Empty states
- Validation feedback
- Confirmation dialogs

This architecture ensures a robust, maintainable, and user-friendly application ready for production deployment.
