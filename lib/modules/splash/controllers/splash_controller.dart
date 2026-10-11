import 'dart:async';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  late final AuthService _authService;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    // Get AuthService lazily to ensure it's initialized
    try {
      _authService = Get.find<AuthService>();
    } catch (e) {
      // If AuthService is not found, navigate to login
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    _checkAuthStatus();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  void _checkAuthStatus() {
    // Listen to auth state changes for proper initialization
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        _authSubscription?.cancel(); // Cancel after first event
        if (user != null) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      },
      onError: (error) {
        _authSubscription?.cancel();
        // On error, navigate to login as fallback
        Get.offAllNamed(AppRoutes.login);
      },
    );

    // Add a timeout fallback in case auth state doesn't emit
    Future.delayed(const Duration(seconds: 3), () {
      if (_authSubscription != null) {
        _authSubscription?.cancel();
        // After timeout, check current state
        if (_authService.isLoggedIn) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }
}
