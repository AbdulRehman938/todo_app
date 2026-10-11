import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_strings.dart';
import '../../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxBool isObscurePassword = true.obs;
  final RxBool isObscureConfirmPassword = true.obs;

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    if (_authService.isLoggedIn) {
      _navigateToHome();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isObscurePassword.value = !isObscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    isObscureConfirmPassword.value = !isObscureConfirmPassword.value;
  }

  // Login
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

  // Signup
  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await _authService.registerWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
      );

      // Clear form
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // Show success message
      Get.snackbar(
        'Success',
        AppStrings.successSignup,
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

  // Logout
  Future<void> logout() async {
    Get.defaultDialog(
      title: AppStrings.logoutDialogTitle,
      middleText: AppStrings.logoutDialogMessage,
      textConfirm: AppStrings.confirm,
      textCancel: AppStrings.cancel,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      backgroundColor: Colors.white,
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

  // Navigate to home
  void _navigateToHome() {
    Get.offAllNamed('/home');
  }

  // Navigate to signup
  void goToSignup() {
    Get.toNamed('/signup');
  }

  // Navigate to login
  void goToLogin() {
    Get.toNamed('/login');
  }

  // Validation helpers
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
}
