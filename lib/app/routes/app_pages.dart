import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/signup_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/tasks/bindings/task_binding.dart';
import '../../modules/tasks/views/add_edit_task_view.dart';

// Placeholder imports - these will be created later
// import '../modules/task_details/bindings/task_details_binding.dart';
// import '../modules/task_details/views/task_details_view.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash Screen
    GetPage(
      name: AppRoutes.splash,
      page: () {
        debugPrint('AppPages: Building SplashView');
        return const SplashView();
      },
      binding: SplashBinding(),
    ),

    // Authentication
    GetPage(
      name: AppRoutes.login,
      page: () {
        debugPrint('AppPages: Building LoginView');
        return const LoginView();
      },
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () {
        debugPrint('AppPages: Building SignupView');
        return const SignupView();
      },
      binding: AuthBinding(),
    ),

    // Main App
    GetPage(
      name: AppRoutes.home,
      page: () {
        debugPrint('AppPages: Building HomeView');
        return const HomeView();
      },
      binding: HomeBinding(),
    ),

    // Task Management
    GetPage(
      name: AppRoutes.addEditTask,
      page: () {
        debugPrint('AppPages: Building AddEditTaskView');
        return const AddEditTaskView();
      },
      binding: TaskBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.taskDetails,
    //   page: () => const TaskDetailsView(),
    //   binding: TaskDetailsBinding(),
    // ),
  ];
}
