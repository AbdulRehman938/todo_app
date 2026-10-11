import 'package:get/get.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/services/task_service.dart';
import '../../../data/services/auth_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<TaskService>(() => TaskService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<TaskController>(() => TaskController());
  }
}
