# GetX State Management and Routing

## Table of Contents
1. [GetX Overview](#getx-overview)
2. [Reactive Programming with GetX](#reactive-programming-with-getx)
3. [GetX Controllers](#getx-controllers)
4. [GetX Navigation](#getx-navigation)
5. [Dependency Injection](#dependency-injection)

---

## GetX Overview

### What is GetX?

**GetX** is a Flutter framework that provides:
- State management
- Dependency injection
- Route management
- Utilities for HTTP requests, localization, storage, and more

**Why GetX for this project?**
- **Minimal boilerplate**: Less code than Provider or Bloc
- **Performance**: Optimized for Flutter's reactivity
- **Simple syntax**: Easy to learn and use
- **Complete solution**: Handles state, DI, and routing in one package
- **Reactive**: Built-in reactive programming support

### GetX Installation

**pubspec.yaml:**
```yaml
dependencies:
  get: ^4.7.3
```

**Initialization in main.dart:**
```dart
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
    );
  }
}
```

**Key Points:**
- Replace `MaterialApp` with `GetMaterialApp`
- Enables GetX routing and state management
- Configured with theme support

---

## Reactive Programming with GetX

### What is Reactive Programming?

Reactive programming is a declarative programming paradigm concerned with data streams and the propagation of change.

**In GetX:**
- Variables become "observable"
- UI automatically updates when variables change
- No need for `setState()` or manual rebuilds

### GetX Reactive Variables

#### 1. RxBool - Boolean Observable

**Declaration:**
```dart
final RxBool isLoading = false.obs;
```

**Reading Value:**
```dart
// Method 1: Direct access
bool currentLoadingState = isLoading.value;

// Method 2: In Obx widget
Obx(() => Text(controller.isLoading.value ? 'Loading...' : 'Loaded'))
```

**Updating Value:**
```dart
isLoading.value = true;  // Set to true
isLoading.toggle();    // Flip true/false
```

**Use Case in AuthController:**
```dart
final RxBool isLoading = false.obs;

Future<void> login() async {
  isLoading.value = true;  // Show loading indicator
  
  try {
    await _authService.signInWithEmailAndPassword(...);
    // Navigate to home
  } catch (e) {
    // Show error
  } finally {
    isLoading.value = false;  // Hide loading indicator
  }
}
```

#### 2. RxString - String Observable

**Declaration:**
```dart
final RxString searchQuery = ''.obs;
```

**Use Case in TaskController:**
```dart
final RxString searchQuery = ''.obs;

void setSearchQuery(String query) {
  searchQuery.value = query;
  // UI automatically updates to show filtered results
}
```

**UI Binding:**
```dart
TextField(
  onChanged: controller.setSearchQuery,
  // OR
  onChanged: (value) => controller.searchQuery.value = value,
)
```

#### 3. RxList - List Observable

**Declaration:**
```dart
final RxList<TaskModel> tasks = <TaskModel>[].obs;
```

**Reading Value:**
```dart
List<TaskModel> currentTasks = tasks.toList();
```

**Modifying List:**
```dart
// Add item
tasks.add(newTask);

// Add multiple items
tasks.addAll(newTasks);

// Remove item
tasks.remove(task);

// Remove at index
tasks.removeAt(index);

// Clear all
tasks.clear();

// Replace entire list
tasks.assignAll(newTasks);
```

**Use Case in TaskController:**
```dart
final RxList<TaskModel> tasks = <TaskModel>[].obs;

void _fetchTasks() async {
  isLoading.value = true;
  try {
    _taskService.getTasksStream().listen((taskList) {
      tasks.assignAll(taskList);  // Replaces entire list
      _updateCounts();
    });
  } catch (e) {
    Get.snackbar('Error', AppStrings.errorLoadTasks);
  } finally {
    isLoading.value = false;
  }
}
```

#### 4. RxEnum - Enum Observable

**Declaration:**
```dart
final Rx<TaskFilter> currentFilter = TaskFilter.all.obs;
final Rx<TaskSort> currentSort = TaskSort.dueDate.obs;
```

**Use Case in TaskController:**
```dart
enum TaskFilter {
  all,
  pending,
  completed,
}

final Rx<TaskFilter> currentFilter = TaskFilter.all.obs;

void setFilter(TaskFilter filter) {
  currentFilter.value = filter;
  // UI automatically updates to show filtered tasks
}
```

#### 5. Computed Reactive Values

**Using Getters:**
```dart
class TaskController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;

  // Computed properties (reactive)
  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => tasks.where((task) => !task.isCompleted).length;
}
```

**In UI:**
```dart
Obx(
  () => Text('Total: ${controller.totalTasks}'),
)
```

**Note:** Getters automatically trigger updates when the observable they depend on changes.

### Obx Widget - Reactive UI Updates

**Basic Usage:**
```dart
Obx(
  () => Text(
    controller.isLoading.value ? 'Loading...' : 'Done',
  ),
)
```

**Automatic Rebuild:**
- Obx automatically rebuilds when any observable inside it changes
- Only rebuilds the widget inside Obx, not the entire screen
- More efficient than setState()

**Multiple Observables:**
```dart
Obx(
  () => Column(
    children: [
      Text('Tasks: ${controller.tasks.length}'),
      if (controller.isLoading.value)
        CircularProgressIndicator(),
      if (controller.searchQuery.value.isNotEmpty)
        Text('Searching: ${controller.searchQuery.value}'),
    ],
  ),
)
```

**Conditional Rendering:**
```dart
Obx(
  () => controller.isLoading.value
      ? LoadingWidget()
      : TaskListWidget(),
)
```

**With Computed Properties:**
```dart
Obx(
  () => Row(
    children: [
      _buildStatCard('Total', controller.totalTasks),
      _buildStatCard('Completed', controller.completedTasks),
      _buildStatCard('Pending', controller.pendingTasks),
    ],
  ),
)
```

### GetX vs setState Comparison

**Traditional setState:**
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool isLoading = false;

  void loadData() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? CircularProgressIndicator() : Text('Loaded');
  }
}
```

**GetX Obx:**
```dart
class MyWidget extends StatelessWidget {
  final controller = Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? CircularProgressIndicator()
          : Text('Loaded'),
    );
  }
}

class MyController extends GetxController {
  final RxBool isLoading = false.obs;

  void loadData() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2));
    isLoading.value = false;
  }
}
```

**Advantages of GetX:**
- No StatefulWidget needed
- Cleaner code
- Better performance (selective rebuilds)
- State survives hot reload

---

## GetX Controllers

### What is a GetX Controller?

A GetX Controller is a class that extends `GetxController` and manages:
- Application state
- Business logic
- Lifecycle management
- Dependency injection

### Controller Lifecycle

**Lifecycle Methods:**
```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is created
    // Initialize state, set up streams, fetch initial data
    print('Controller initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // Called after onInit, after first frame is rendered
    // Use for UI-related initializations
  }

  @override
  void onClose() {
    // Called when controller is deleted
    // Clean up resources, close streams, dispose controllers
    print('Controller disposed');
    super.onClose();
  }
}
```

**Lifecycle Events:**
1. **onInit()**: Controller creation, before first frame
2. **onReady()**: After first frame, ready for UI interaction
3. **onClose()**: Controller deletion, cleanup

### AuthController

**Location:** `lib/modules/auth/controllers/auth_controller.dart`

**Responsibilities:**
- Authentication state management
- Form validation
- Login/Signup logic
- Logout functionality
- Navigation

**Key Features:**

1. **Form State Management:**
```dart
final RxBool isLoading = false.obs;
final RxBool isObscurePassword = true.obs;
final RxBool isObscureConfirmPassword = true.obs;

final loginFormKey = GlobalKey<FormState>();
final signupFormKey = GlobalKey<FormState>();

final nameController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();
```

2. **Login with Validation:**
```dart
Future<void> login() async {
  // Step 1: Validate form
  if (!loginFormKey.currentState!.validate()) {
    return;
  }

  // Step 2: Show loading state
  isLoading.value = true;

  try {
    // Step 3: Call service
    await _authService.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Step 4: Clear form
    emailController.clear();
    passwordController.clear();

    // Step 5: Show success message
    Get.snackbar(
      'Success',
      AppStrings.successLogin,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Step 6: Navigate
    _navigateToHome();
  } catch (e) {
    // Step 7: Show error message
    Get.snackbar(
      'Error',
      e.toString().replaceAll('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  } finally {
    // Step 8: Hide loading state
    isLoading.value = false;
  }
}
```

3. **Validation Methods:**
```dart
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
```

4. **Logout with Confirmation:**
```dart
Future<void> logout() async {
  Get.defaultDialog(
    title: AppStrings.logoutDialogTitle,
    middleText: AppStrings.logoutDialogMessage,
    textConfirm: AppStrings.confirm,
    textCancel: AppStrings.cancel,
    confirmTextColor: Colors.white,
    buttonColor: Colors.red.shade600,
    onConfirm: () async {
      Get.back();
      isLoading.value = true;

      try {
        await _authService.signOut();

        Get.snackbar(
          'Success',
          AppStrings.successLogout,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        Get.offAllNamed('/login');
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
    },
  );
}
```

### TaskController

**Location:** `lib/modules/tasks/controllers/task_controller.dart`

**Responsibilities:**
- Task state management
- CRUD operations
- Filtering and sorting
- Search functionality
- Statistics computation

**Key Features:**

1. **Reactive State:**
```dart
final RxList<TaskModel> tasks = <TaskModel>[].obs;
final RxString searchQuery = ''.obs;
final Rx<TaskFilter> currentFilter = TaskFilter.all.obs;
final Rx<TaskSort> currentSort = TaskSort.dueDate.obs;
final RxBool isLoading = false.obs;
```

2. **Computed Properties:**
```dart
int get totalTasks => tasks.length;
int get completedTasks => tasks.where((task) => task.isCompleted).length;
int get pendingTasks => tasks.where((task) => !task.isCompleted).length;
```

3. **Computed Filtered Tasks:**
```dart
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
```

4. **Real-time Data Fetching:**
```dart
void _fetchTasks() async {
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
```

5. **CRUD with Feedback:**
```dart
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
```

6. **Delete with Confirmation:**
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

### SplashController

**Location:** `lib/modules/splash/controllers/splash_controller.dart`

**Responsibilities:**
- Splash screen display
- Auth state check
- Navigation to appropriate screen

**Implementation:**
```dart
class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // Delay for splash screen effect
    Future.delayed(const Duration(seconds: 2), () {
      if (_authService.isLoggedIn) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }
}
```

---

## GetX Navigation

### Named Routes

**Route Constants (app_routes.dart):**
```dart
class AppRoutes {
  // Authentication Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main App Routes
  static const String home = '/home';
  static const String splash = '/splash';

  // Task Routes
  static const String addEditTask = '/add-edit-task';
  static const String taskDetails = '/task-details';

  // Settings Routes
  static const String settings = '/settings';
  static const String profile = '/profile';
}
```

**Benefits:**
- Type-safe navigation
- Centralized route management
- Easy to modify routes
- IDE autocomplete support

### Route Configuration (app_pages.dart)

```dart
class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash Screen
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Authentication
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),

    // Main App
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // Task Management
    GetPage(
      name: AppRoutes.addEditTask,
      page: () => const AddEditTaskView(),
      binding: TaskBinding(),
    ),
  ];
}
```

**GetPage Parameters:**
- **name**: Route path
- **page**: Widget to display
- **binding**: Dependency injection binding
- **middlewares**: Navigation guards (optional)
- **transition**: Custom transition (optional)

### Navigation Methods

#### 1. Navigate to New Screen
```dart
// Push new screen onto stack
Get.toNamed(AppRoutes.signup);

// OR with Get.to (not recommended for named routes)
Get.to(() => SignupView());
```

#### 2. Replace Current Screen
```dart
// Replace current screen with new screen
Get.offNamed(AppRoutes.home);
```

#### 3. Replace All Screens (Clear Stack)
```dart
// Clear back stack and navigate to new screen
Get.offAllNamed(AppRoutes.home);
```

**Use Case:** After login/logout
```dart
// After successful login
Get.offAllNamed(AppRoutes.home);

// After logout
Get.offAllNamed(AppRoutes.login);
```

#### 4. Navigate Back
```dart
// Go back to previous screen
Get.back();

// Go back with result
Get.back(result: 'Task saved');

// Pop until specific route
Get.until((route) => Get.currentRoute == AppRoutes.home);
```

#### 5. Pass Arguments
```dart
// Navigate with arguments
Get.toNamed(
  AppRoutes.addEditTask,
  arguments: {
    'isEdit': true,
    'task': taskModel,
  },
);

// Receive arguments in destination
class AddEditTaskView extends GetView<TaskController> {
  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final isEdit = arguments['isEdit'] as bool? ?? false;
    final task = arguments['task'] as TaskModel?;
    // ...
  }
}
```

#### 6. Dialog Navigation
```dart
// Show dialog
Get.defaultDialog(
  title: 'Delete Task',
  middleText: 'Are you sure?',
  textConfirm: 'Delete',
  textCancel: 'Cancel',
  onConfirm: () {
    Get.back();  // Close dialog
    // Perform delete
  },
);

// Bottom sheet
Get.bottomSheet(
  Container(
    child: ListView(...),
  ),
);

// Snackbar
Get.snackbar(
  'Success',
  'Task saved',
  snackPosition: SnackPosition.BOTTOM,
);
```

### Navigation Guards with Middlewares

**Example Auth Guard:**
```dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // Protect home route
    if (route == AppRoutes.home && !authService.isLoggedIn) {
      return RouteSettings(name: AppRoutes.login);
    }
    
    return null;
  }
}

// Usage in AppPages
GetPage(
  name: AppRoutes.home,
  page: () => const HomeView(),
  binding: HomeBinding(),
  middlewares: [AuthMiddleware()],
),
```

---

## Dependency Injection

### What is Dependency Injection?

Dependency Injection (DI) is a design pattern where:
- Dependencies are provided to a class rather than created internally
- Promotes loose coupling
- Makes testing easier
- Centralizes object creation

### GetX DI Methods

#### 1. Get.put() - Immediate Creation

**Usage:**
```dart
Get.put<AuthService>(AuthService());
```

**Characteristics:**
- Creates instance immediately
- Stored in memory
- Not lazy-loaded
- Singleton behavior

**Use Case:** Critical services needed immediately
```dart
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
```

#### 2. Get.lazyPut() - Lazy Creation

**Usage:**
```dart
Get.lazyPut<AuthService>(() => AuthService());
```

**Characteristics:**
- Created only when first accessed
- Stored in memory after creation
- Singleton behavior
- More efficient for unused dependencies

**Use Case:** Controllers and views
```dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
```

#### 3. Get.find() - Retrieve Instance

**Usage:**
```dart
final authService = Get.find<AuthService>();
```

**Characteristics:**
- Retrieves existing instance
- Throws error if not found
- Used in controllers to access services

**Use Case:** Accessing dependencies in controllers
```dart
class TaskController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  // ...
}
```

#### 4. Get.delete() - Remove Instance

**Usage:**
```dart
Get.delete<AuthService>();
```

**Characteristics:**
- Removes instance from memory
- Calls onClose() if it's a GetxController
- Frees resources

**Use Case:** Cleanup on logout
```dart
Future<void> logout() async {
  await _authService.signOut();
  Get.delete<TaskController>();
  Get.offAllNamed(AppRoutes.login);
}
```

### Bindings

**What are Bindings?**
Bindings are classes that implement the `Bindings` interface and manage dependency injection for a route or controller.

**AuthBinding Example:**
```dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService with fenix mode (persists after disposal)
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    // Register AuthController (lazy-loaded)
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
```

**Lifecycle:**
- **Created**: When route is navigated to
- **Disposed**: When route is removed from stack (unless fenix mode)

### Fenix Mode

**What is Fenix Mode?**
Fenix mode keeps the dependency alive even after the route is disposed.

**Usage:**
```dart
Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
```

**Use Case:** Services that should persist across routes
- AuthService (user session)
- TaskService (real-time data streams)
- SettingsService (app preferences)

**Without Fenix:**
```dart
Get.lazyPut<AuthService>(() => AuthService());
// Disposed when route closes
```

**With Fenix:**
```dart
Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
// Persists across routes
```

### Permanent Mode

**What is Permanent Mode?**
Permanent mode keeps the dependency alive forever (until app closes).

**Usage:**
```dart
Get.put<AuthService>(AuthService(), permanent: true);
```

**Use Case:** Critical services needed throughout app
- Firebase initialization
- Global state managers

### Complete DI Example

**Binding for Home Screen:**
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Services - persist across routes (fenix)
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<TaskService>(() => TaskService(), fenix: true);
    
    // Controllers - dispose with route
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<TaskController>(() => TaskController());
  }
}
```

**Controller Accessing Dependencies:**
```dart
class TaskController extends GetxController {
  // Service dependencies
  final TaskService _taskService = Get.find<TaskService>();
  
  // Optional: Access other controllers
  // final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _fetchTasks();
  }

  @override
  void onClose() {
    // Cleanup
    super.onClose();
  }
}
```

### DI Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    App Initialization                      │
│                   (main.dart)                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ GetMaterialApp
                     │
┌────────────────────▼────────────────────────────────────────┐
│                      Route Navigation                        │
│                   (AppPages + AppRoutes)                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ User navigates to /home
                     │
┌────────────────────▼────────────────────────────────────────┐
│                      HomeBinding                               │
│  ├─ Get.lazyPut<AuthService>(fenix: true)                │
│  ├─ Get.lazyPut<TaskService>(fenix: true)                  │
│  ├─ Get.lazyPut<AuthController>()                          │
│  └─ Get.lazyPut<TaskController>()                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ HomeView loads
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   HomeView                                    │
│  └─ Get.find<TaskController>()                          │
│      └─ controller.filteredTasks (reactive)               │
└─────────────────────────────────────────────────────────────┘
```

### DI Benefits in This Project

1. **Testability:**
   - Easy to mock services for unit tests
   - Controllers can be tested independently

2. **Reusability:**
   - Services shared across multiple controllers
   - Single source of truth for instances

3. **Performance:**
   - Lazy loading reduces startup time
   - Memory efficient (dispose when not needed)

4. **Maintainability:**
   - Centralized dependency creation
   - Easy to swap implementations

---

## Summary

GetX provides a complete solution for state management, routing, and dependency injection in this Flutter To-Do application:

### State Management
- **Reactive Variables**: RxBool, RxString, RxList, RxEnum
- **Obx Widget**: Automatic UI updates
- **Controllers**: Business logic and state management
- **Computed Properties**: Reactive derived values

### Navigation
- **Named Routes**: Type-safe, centralized configuration
- **Navigation Methods**: toNamed, offNamed, offAllNamed, back
- **Arguments**: Data passing between screens
- **Dialogs**: defaultDialog, bottomSheet, snackbar

### Dependency Injection
- **Get.put()**: Immediate creation
- **Get.lazyPut()**: Lazy creation
- **Get.find()**: Retrieve instances
- **Bindings**: Route-level DI management
- **Fenix Mode**: Persist dependencies across routes

This architecture results in:
- **Clean Code**: Separation of concerns
- **Better Performance**: Selective rebuilds
- **Easier Testing**: Mockable dependencies
- **Type Safety**: Compile-time checks
- **Developer Experience**: Less boilerplate
