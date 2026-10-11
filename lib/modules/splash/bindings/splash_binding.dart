import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../data/services/auth_service.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
