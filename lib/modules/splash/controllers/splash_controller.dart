import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    debugPrint('SplashController: onInit called');
    
    // Get AuthService lazily to ensure it's initialized
    try {
      _authService = Get.find<AuthService>();
      debugPrint('SplashController: AuthService found');
    } catch (e) {
      // If AuthService is not found, navigate to login
      debugPrint('SplashController: AuthService not found - $e');
      _navigateToLogin();
      return;
    }
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    debugPrint('SplashController: Checking auth status...');
    
    // Wait a moment for Firebase to initialize, then check auth state
    Future.delayed(const Duration(seconds: 2), () {
      final isLoggedIn = _authService.isLoggedIn;
      debugPrint('SplashController: isLoggedIn = $isLoggedIn');
      
      if (isLoggedIn) {
        debugPrint('SplashController: Navigating to home');
        Get.offAllNamed(AppRoutes.home);
      } else {
        debugPrint('SplashController: Navigating to login');
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    debugPrint('SplashController: Calling Get.offAllNamed(login)');
    Get.offAllNamed(AppRoutes.login);
  }
}
