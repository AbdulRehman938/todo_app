import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import 'auth_service.dart';

class TaskService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get tasks collection reference for current user
  CollectionReference get _tasksCollection {
    final authService = Get.find<AuthService>();
    final userId = authService.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Stream of all tasks for current user (realtime)
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

  // Stream of tasks filtered by completion status
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

  // Stream of tasks filtered by priority
  Stream<List<TaskModel>> getTasksByPriorityStream(String priority) {
    return _tasksCollection
        .where('priority', isEqualTo: priority)
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

  // Stream of tasks for a specific date range
  Stream<List<TaskModel>> getTasksByDateRangeStream(DateTime start, DateTime end) {
    return _tasksCollection
        .where('dueDate', isGreaterThanOrEqualTo: start)
        .where('dueDate', isLessThanOrEqualTo: end)
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

  // Get all tasks once (not realtime)
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final snapshot = await _tasksCollection
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TaskModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: ${e.toString()}');
    }
  }

  // Get task by ID
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

  // Add new task
  Future<String> addTask(TaskModel task) async {
    try {
      final authService = Get.find<AuthService>();
      final userId = authService.currentUserId;

      final taskData = task.toMap();
      taskData.remove('id'); // Remove id as Firestore will generate it
      taskData['userId'] = userId; // Set the userId
      taskData['createdAt'] = FieldValue.serverTimestamp();
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _tasksCollection.add(taskData);
      print('TaskService: Task added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('TaskService: Failed to add task - ${e.toString()}');
      throw Exception('Failed to add task: ${e.toString()}');
    }
  }

  // Update existing task
  Future<void> updateTask(TaskModel task) async {
    try {
      final taskData = task.toMap();
      taskData.remove('id'); // Don't update the id
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      await _tasksCollection.doc(task.id).update(taskData);
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  // Toggle task completion status
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

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  // Delete all completed tasks
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

  // Get task statistics
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

  // Search tasks by title or description
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that fetches all tasks and filters client-side
      // For production, consider using Algolia or a dedicated search service
      final snapshot = await _tasksCollection.get();

      final tasks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TaskModel.fromMap(data);
      }).toList();

      final lowerQuery = query.toLowerCase();
      return tasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
            task.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: ${e.toString()}');
    }
  }
}
