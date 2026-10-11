import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/services/auth_service.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('SplashBinding: dependencies called');
    Get.put<AuthService>(AuthService(), permanent: true);
    debugPrint('SplashBinding: AuthService registered');
    Get.put<AuthController>(AuthController(), permanent: true);
    debugPrint('SplashBinding: AuthController registered');
    Get.put<SplashController>(SplashController());
    debugPrint('SplashBinding: SplashController registered');
  }
}
