# Architecture and MVC Pattern

## Table of Contents
1. [MVC Architecture Overview](#mvc-architecture-overview)
2. [Separation of Concerns](#separation-of-concerns)
3. [Data Models](#data-models)
4. [Services Layer](#services-layer)
5. [Project Directory Structure](#project-directory-structure)

---

## MVC Architecture Overview

### What is MVC?
**Model-View-Controller (MVC)** is a software architectural pattern that divides an application into three interconnected components:

- **Model**: Represents the data and business logic of the application
- **View**: Handles the presentation layer (UI)
- **Controller**: Acts as an intermediary between Model and View, handling user input and updating the model

### MVC Implementation in This Project

Our Flutter To-Do application follows the MVC pattern with the GetX framework's reactive state management:

```
┌─────────────────────────────────────────────────────────────┐
│                         View Layer                           │
│  (Views: LoginView, SignupView, HomeView, etc.)           │
│  - UI Components                                            │
│  - User Interaction                                        │
│  - Reactive Updates via Obx()                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ GetX Reactive Data Binding
                     │
┌────────────────────▼────────────────────────────────────────┐
│                      Controller Layer                       │
│  (Controllers: AuthController, TaskController)            │
│  - Business Logic                                          │
│  - State Management (Rx variables)                         │
│  - Form Validation                                         │
│  - Navigation Logic                                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Service Calls
                     │
┌────────────────────▼────────────────────────────────────────┐
│                      Service Layer                          │
│  (Services: AuthService, TaskService)                      │
│  - API/Firebase Interactions                               │
│  - Data Transformation                                    │
│  - Error Handling                                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Data Objects
                     │
┌────────────────────▼────────────────────────────────────────┐
│                       Model Layer                           │
│  (Models: UserModel, TaskModel)                            │
│  - Data Structures                                        │
│  - Serialization/Deserialization                          │
│  - Business Rules                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Separation of Concerns

### Why Separation of Concerns Matters

Separation of concerns is a design principle that states:
> "A computer program should be divided into distinct sections, each addressing a separate concern."

**Benefits in our project:**

1. **Maintainability**: Changes to UI don't affect business logic
2. **Testability**: Each layer can be tested independently
3. **Reusability**: Services and models can be reused across different views
4. **Scalability**: Easy to add new features without modifying existing code
5. **Collaboration**: Different team members can work on different layers simultaneously

### Implementation Examples

#### Example 1: UI Without Business Logic

**View Layer (home_view.dart):**
```dart
// Only UI logic - no business rules
Widget _buildTaskList(BuildContext context, bool isDarkMode) {
  return Obx(
    () {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredTasks = controller.filteredTasks;

      if (filteredTasks.isEmpty) {
        return _buildEmptyState(context, isDarkMode);
      }

      return ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return TaskCard(
            task: task,
            onTap: () => controller.goToTaskDetails(task),
            onEdit: () => controller.goToEditTask(task),
            onDelete: () => controller.deleteTaskWithConfirmation(task.id),
            onToggleComplete: (isCompleted) {
              controller.toggleTaskCompletion(task.id, isCompleted);
            },
          );
        },
      );
    },
  );
}
```

**Controller Layer (task_controller.dart):**
```dart
// Business logic - filtering and sorting
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
  }

  return filtered;
}
```

#### Example 2: Service Layer Isolation

**Service Layer (auth_service.dart):**
```dart
// Only Firebase interaction - no UI logic
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

**Controller Layer (auth_controller.dart):**
```dart
// Controller handles validation and UI feedback
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

    // Clear form
    emailController.clear();
    passwordController.clear();

    // Show success message
    Get.snackbar(
      'Success',
      AppStrings.successLogin,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Navigate to home
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

---

## Data Models

### UserModel

**Location:** `lib/data/models/user_model.dart`

**Purpose:** Represents user data structure for authentication and profile management.

**Fields:**
```dart
class UserModel {
  final String id;           // Unique user identifier (Firebase Auth UID)
  final String name;         // User's display name
  final String email;        // User's email address
}
```

**Serialization (toMap):**
```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'email': email,
  };
}
```
- Converts the UserModel object to a Map for Firestore storage
- Used when saving user data to database

**Deserialization (fromMap):**
```dart
factory UserModel.fromMap(Map<String, dynamic> map) {
  return UserModel(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    email: map['email'] as String? ?? '',
  );
}
```
- Converts Firestore document data to UserModel object
- Includes null safety with default empty strings
- Used when retrieving user data from database

**Immutability (copyWith):**
```dart
UserModel copyWith({
  String? id,
  String? name,
  String? email,
}) {
  return UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
  );
}
```
- Creates a new UserModel with updated fields
- Enables functional programming patterns
- Useful for state updates without mutation

---

### TaskModel

**Location:** `lib/data/models/task_model.dart`

**Purpose:** Represents task data structure with comprehensive task management features.

**Fields:**
```dart
class TaskModel {
  final String id;              // Unique task identifier (Firestore document ID)
  final String userId;          // ID of the user who owns this task
  final String title;           // Task title
  final String description;     // Task description
  final DateTime dueDate;      // Due date and time
  final TaskPriority priority; // Priority level (Low, Medium, High)
  final bool isCompleted;       // Completion status
  final DateTime createdAt;     // Timestamp when task was created
  final DateTime updatedAt;     // Timestamp when task was last updated
}
```

**Priority Enum:**
```dart
enum TaskPriority {
  low,
  medium,
  high,
}
```
- Type-safe priority levels
- Prevents invalid priority values
- Enables switch statements for priority-based logic

**Serialization with DateTime Handling:**
```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'dueDate': dueDate,
    'priority': priority.name,  // Enum to string conversion
    'isCompleted': isCompleted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
```

**Deserialization with Firestore Timestamp Conversion:**
```dart
factory TaskModel.fromMap(Map<String, dynamic> map) {
  return TaskModel(
    id: map['id'] as String? ?? '',
    userId: map['userId'] as String? ?? '',
    title: map['title'] as String? ?? '',
    description: map['description'] as String? ?? '',
    dueDate: map['dueDate'] != null
        ? (map['dueDate'] as dynamic).toDate()  // Firestore Timestamp to DateTime
        : DateTime.now(),
    priority: _parsePriority(map['priority'] as String?),
    isCompleted: map['isCompleted'] as bool? ?? false,
    createdAt: map['createdAt'] != null
        ? (map['createdAt'] as dynamic).toDate()
        : DateTime.now(),
    updatedAt: map['updatedAt'] != null
        ? (map['updatedAt'] as dynamic).toDate()
        : DateTime.now(),
  );
}
```

**Priority Parsing Helper:**
```dart
static TaskPriority _parsePriority(String? priority) {
  switch (priority?.toLowerCase()) {
    case 'low':
      return TaskPriority.low;
    case 'medium':
      return TaskPriority.medium;
    case 'high':
      return TaskPriority.high;
    default:
      return TaskPriority.medium;  // Default to medium
  }
}
```
- Handles string-to-enum conversion
- Provides default value for invalid data
- Case-insensitive matching

**Helper Methods:**
```dart
String get priorityDisplay {
  switch (priority) {
    case TaskPriority.low:
      return 'Low';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.high:
      return 'High';
  }
}
```
- Returns human-readable priority string
- Used in UI display

---

## Services Layer

### AuthService

**Location:** `lib/data/services/auth_service.dart`

**Purpose:** Wrapper around Firebase Authentication providing a clean API for authentication operations.

**Key Features:**

1. **Singleton Pattern (GetX Service):**
```dart
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ...
}
```
- Extends GetxService for automatic lifecycle management
- Singleton instance accessible throughout the app

2. **Current User Access:**
```dart
User? get currentUser => _auth.currentUser;
String? get currentUserId => _auth.currentUser?.uid;
bool get isLoggedIn => _auth.currentUser != null;
```
- Reactive getters for user state
- Enables auth guards and conditional UI rendering

3. **Auth State Stream:**
```dart
Stream<User?> get authStateChanges => _auth.authStateChanges();
```
- Stream of authentication state changes
- Used for automatic navigation based on auth status
- Enables real-time auth state monitoring

4. **Registration with Display Name:**
```dart
Future<UserCredential> registerWithEmailAndPassword({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update user display name
    await userCredential.user?.updateDisplayName(name);

    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  } catch (e) {
    throw Exception('Registration failed: ${e.toString()}');
  }
}
```
- Creates user account
- Updates display name immediately
- Comprehensive error handling

5. **Error Handling:**
```dart
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
    // ... more cases
    default:
      return 'Authentication failed: ${e.message}';
  }
}
```
- Converts Firebase error codes to user-friendly messages
- Centralized error handling logic

---

### TaskService

**Location:** `lib/data/services/task_service.dart`

**Purpose:** Firestore service for task CRUD operations with user-scoped data isolation.

**Key Features:**

1. **User-Scoped Collection Reference:**
```dart
CollectionReference get _tasksCollection {
  final userId = Get.find<AuthService>().currentUserId;
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  return _firestore.collection('users').doc(userId).collection('tasks');
}
```
- **Data Isolation:** Each user's tasks are stored in their own subcollection
- **Structure:** `users/{userId}/tasks/{taskId}`
- **Security:** Ensures users can only access their own tasks
- **Automatic Auth Guard:** Throws exception if user not authenticated

2. **Real-time Data Synchronization:**
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
- **Firestore Streams:** Real-time updates when data changes
- **Automatic UI Updates:** Connected to GetX reactive variables
- **Default Sorting:** Tasks ordered by due date

3. **Filtered Streams:**
```dart
Stream<List<TaskModel>> getTasksByCompletionStream(bool isCompleted) {
  return _tasksCollection
      .where('isCompleted', isEqualTo: isCompleted)
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
- Server-side filtering with Firestore queries
- More efficient than client-side filtering
- Reduces data transfer

4. **CRUD Operations:**

**Create (Add Task):**
```dart
Future<String> addTask(TaskModel task) async {
  try {
    final taskData = task.toMap();
    taskData.remove('id');  // Remove id as Firestore will generate it
    taskData['createdAt'] = FieldValue.serverTimestamp();
    taskData['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _tasksCollection.add(taskData);
    return docRef.id;
  } catch (e) {
    throw Exception('Failed to add task: ${e.toString()}');
  }
}
```
- Generates unique document ID
- Adds server timestamps
- Returns new task ID

**Read (Get Task by ID):**
```dart
Future<TaskModel?> getTaskById(String taskId) async {
  try {
    final doc = await _tasksCollection.doc(taskId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return TaskModel.fromMap(data);
  } catch (e) {
    throw Exception('Failed to fetch task: ${e.toString()}');
  }
}
```
- Fetches single task by ID
- Returns null if not found

**Update (Update Task):**
```dart
Future<void> updateTask(TaskModel task) async {
  try {
    final taskData = task.toMap();
    taskData.remove('id');  // Don't update the id
    taskData['updatedAt'] = FieldValue.serverTimestamp();

    await _tasksCollection.doc(task.id).update(taskData);
  } catch (e) {
    throw Exception('Failed to update task: ${e.toString()}');
  }
}
```
- Updates existing task
- Updates timestamp automatically

**Delete (Delete Task):**
```dart
Future<void> deleteTask(String taskId) async {
  try {
    await _tasksCollection.doc(taskId).delete();
  } catch (e) {
    throw Exception('Failed to delete task: ${e.toString()}');
  }
}
```
- Deletes task document
- Idempotent operation

5. **Toggle Completion:**
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
- Optimized single-field update
- Updates timestamp
- Efficient partial update

6. **Batch Operations:**
```dart
Future<void> deleteCompletedTasks() async {
  try {
    final snapshot = await _tasksCollection
        .where('isCompleted', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  } catch (e) {
    throw Exception('Failed to delete completed tasks: ${e.toString()}');
  }
}
```
- Uses Firestore batch writes
- Atomic operation (all or nothing)
- Efficient for bulk operations

7. **Statistics:**
```dart
Future<Map<String, int>> getTaskStatistics() async {
  try {
    final snapshot = await _tasksCollection.get();

    int total = snapshot.docs.length;
    int completed = 0;
    int pending = 0;
    int highPriority = 0;
    int mediumPriority = 0;
    int lowPriority = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['isCompleted'] == true) {
        completed++;
      } else {
        pending++;
      }

      final priority = data['priority'] as String?;
      switch (priority?.toLowerCase()) {
        case 'high':
          highPriority++;
          break;
        case 'medium':
          mediumPriority++;
          break;
        case 'low':
          lowPriority++;
          break;
      }
    }

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'highPriority': highPriority,
      'mediumPriority': mediumPriority,
      'lowPriority': lowPriority,
    };
  } catch (e) {
    throw Exception('Failed to get task statistics: ${e.toString()}');
  }
}
```
- Aggregates task statistics
- Useful for dashboard widgets
- Priority breakdown

---

## Project Directory Structure

```
todo_app/
├── lib/
│   ├── app/
│   │   ├── constants/
│   │   │   ├── app_colors.dart       # Color palette and theme constants
│   │   │   └── app_strings.dart       # All static strings for UI
│   │   └── routes/
│   │       ├── app_routes.dart        # Route name constants
│   │       └── app_pages.dart         # GetX route configuration
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── task_model.dart       # Task data model
│   │   │   ├── task_enums.dart       # Task-related enums
│   │   │   └── user_model.dart       # User data model
│   │   └── services/
│   │       ├── auth_service.dart     # Firebase Auth wrapper
│   │       └── task_service.dart     # Firestore task operations
│   │
│   ├── modules/
│   │   ├── auth/                    # Authentication module
│   │   │   ├── bindings/
│   │   │   │   └── auth_binding.dart # Dependency injection
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart # Auth business logic
│   │   │   └── views/
│   │   │       ├── login_view.dart    # Login screen
│   │   │       └── signup_view.dart   # Registration screen
│   │   │
│   │   ├── home/                    # Home/dashboard module
│   │   │   ├── bindings/
│   │   │   │   └── home_binding.dart # Home dependencies
│   │   │   └── views/
│   │   │       └── home_view.dart    # Task list dashboard
│   │   │
│   │   ├── splash/                  # Splash screen module
│   │   │   ├── bindings/
│   │   │   │   └── splash_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── splash_controller.dart
│   │   │   └── views/
│   │   │       └── splash_view.dart
│   │   │
│   │   └── tasks/                   # Task management module
│   │       ├── bindings/
│   │       │   └── task_binding.dart
│   │       ├── controllers/
│   │       │   └── task_controller.dart
│   │       └── views/
│   │           └── add_edit_task_view.dart
│   │
│   ├── shared/
│   │   └── widgets/
│   │       ├── custom_button.dart     # Reusable button widget
│   │       ├── custom_text_field.dart # Reusable input field
│   │       ├── loading_widget.dart    # Loading indicators
│   │       └── task_card.dart        # Task display card
│   │
│   ├── firebase_options.dart         # Firebase configuration
│   └── main.dart                     # App entry point
│
├── docs/                             # Documentation
│   ├── 01_architecture_and_mvc.md    # This file
│   ├── 02_getx_state_management_and_routing.md
│   └── 03_features_and_backend_integration.md
│
├── pubspec.yaml                      # Dependencies
└── README.md
```

### Folder Responsibilities

**app/**
- **constants**: Centralized configuration (colors, strings)
- **routes**: Navigation configuration
- **Purpose**: Cross-cutting concerns used throughout the app

**data/**
- **models**: Data structures and business rules
- **services**: External API/Firebase interactions
- **Purpose**: Data layer independent of UI

**modules/**
- Feature-based organization (auth, home, tasks, splash)
- Each module contains: bindings, controllers, views
- **Purpose**: Self-contained features following MVC

**shared/widgets/**
- Reusable UI components
- **Purpose**: Code reuse and consistent UI

**firebase_options.dart**
- Generated by FlutterFire CLI
- Contains Firebase configuration for all platforms
- **Purpose**: Firebase initialization

**main.dart**
- App entry point
- Firebase initialization
- Theme configuration
- **Purpose**: App bootstrap

---

## Key Architectural Decisions

### 1. Feature-Based Module Structure
**Decision:** Organize by feature (auth, home, tasks) rather than by layer (all controllers, all views)

**Benefits:**
- Easier to locate related files
- Modules can be developed independently
- Easier to delete or add features
- Follows Flutter best practices

### 2. Service Layer Pattern
**Decision:** Separate service classes for Firebase interactions

**Benefits:**
- Single Responsibility Principle
- Easy to mock for testing
- Reusable across different controllers
- Centralized error handling

### 3. Immutable Models
**Decision:** Use immutable models with copyWith

**Benefits:**
- Predictable state changes
- Easier debugging
- Thread-safe
- Functional programming patterns

### 4. Type-Safe Enums
**Decision:** Use Dart enums for priority and filters

**Benefits:**
- Compile-time type checking
- IDE autocomplete
- Prevents invalid values
- Better refactoring support

### 5. Reactive Streams
**Decision:** Use Firestore streams for real-time updates

**Benefits:**
- Automatic UI updates
- No manual refresh needed
- Efficient (server-side updates)
- Event-driven architecture

---

## Summary

This Flutter To-Do application demonstrates a clean, maintainable architecture following MVC principles with GetX state management. The separation of concerns ensures that:

1. **Models** handle data structure and business rules
2. **Services** manage external API interactions
3. **Controllers** contain business logic and state management
4. **Views** focus solely on UI presentation

This architecture makes the application:
- **Maintainable**: Easy to locate and modify code
- **Testable**: Each layer can be tested independently
- **Scalable**: Easy to add new features
- **Reusable**: Components can be reused across the app
- **Professional**: Follows industry best practices
