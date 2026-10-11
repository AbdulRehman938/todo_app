import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../../../data/services/task_service.dart';
import '../../../data/services/auth_service.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<TaskService>(() => TaskService(), fenix: true);
    Get.lazyPut<TaskController>(() => TaskController());
  }
}
