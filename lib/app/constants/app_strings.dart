class AppStrings {
  // App Title
  static const String appName = 'TaskFlow';
  static const String appTagline = 'Organize your life, one task at a time';

  // Authentication - Login
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue';
  static const String emailLabel = 'Email';
  static const String emailHint = 'Enter your email';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginButton = 'Sign In';
  static const String noAccount = "Don't have an account?";
  static const String signUpLink = 'Sign Up';

  // Authentication - Signup
  static const String signUpTitle = 'Create Account';
  static const String signUpSubtitle = 'Join us today';
  static const String nameLabel = 'Full Name';
  static const String nameHint = 'Enter your full name';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordHint = 'Confirm your password';
  static const String signUpButton = 'Create Account';
  static const String haveAccount = 'Already have an account?';
  static const String loginLink = 'Sign In';

  // Home Screen
  static const String homeTitle = 'My Tasks';
  static const String todayTasks = 'Today';
  static const String upcomingTasks = 'Upcoming';
  static const String completedTasks = 'Completed';
  static const String pendingTasks = 'Pending';
  static const String allTasks = 'All Tasks';
  static const String noTasks = 'No tasks yet';
  static const String noTasksDescription = 'Tap the + button to add your first task';
  static const String searchHint = 'Search tasks...';
  static const String filterTasks = 'Filter Tasks';
  static const String sortTasks = 'Sort Tasks';

  // Task Details
  static const String taskDetails = 'Task Details';
  static const String taskTitle = 'Task Title';
  static const String taskDescription = 'Description';
  static const String taskDescriptionHint = 'Add a description...';
  static const String dueDate = 'Due Date';
  static const String dueTime = 'Due Time';
  static const String priority = 'Priority';
  static const String category = 'Category';
  static const String status = 'Status';
  static const String createdAt = 'Created At';
  static const String updatedAt = 'Updated At';

  // Add/Edit Task
  static const String addTask = 'Add New Task';
  static const String editTask = 'Edit Task';
  static const String taskTitleHint = 'Enter task title';
  static const String taskDescriptionPlaceholder = 'Describe your task...';
  static const String selectDate = 'Select Date';
  static const String selectTime = 'Select Time';
  static const String selectPriority = 'Select Priority';
  static const String selectCategory = 'Select Category';
  static const String saveTask = 'Save Task';
  static const String cancel = 'Cancel';
  static const String deleteTask = 'Delete Task';

  // Priority Levels
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';

  // Task Status
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';

  // Categories
  static const String categoryWork = 'Work';
  static const String categoryPersonal = 'Personal';
  static const String categoryShopping = 'Shopping';
  static const String categoryHealth = 'Health';
  static const String categoryStudy = 'Study';
  static const String categoryOther = 'Other';

  // Empty States
  static const String emptyTasks = 'No Tasks Found';
  static const String emptyTasksMessage = 'You have no tasks in this category';
  static const String emptySearch = 'No Results';
  static const String emptySearchMessage = 'Try a different search term';

  // Error Messages
  static const String errorGeneric = 'Something went wrong';
  static const String errorEmailInvalid = 'Please enter a valid email';
  static const String errorPasswordShort = 'Password must be at least 6 characters';
  static const String errorPasswordMismatch = 'Passwords do not match';
  static const String errorFieldRequired = 'This field is required';
  static const String errorNetwork = 'Network error. Please check your connection';
  static const String errorAuth = 'Authentication failed';
  static const String errorLogin = 'Login failed. Please check your credentials';
  static const String errorSignup = 'Sign up failed. Please try again';
  static const String errorLoadTasks = 'Failed to load tasks';
  static const String errorSaveTask = 'Failed to save task';
  static const String errorDeleteTask = 'Failed to delete task';

  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successSignup = 'Account created successfully';
  static const String successLogout = 'Logged out successfully';
  static const String successTaskSaved = 'Task saved successfully';
  static const String successTaskDeleted = 'Task deleted successfully';
  static const String successTaskCompleted = 'Task marked as completed';

  // Actions
  static const String logout = 'Logout';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String complete = 'Complete';
  static const String undo = 'Undo';
  static const String confirm = 'Confirm';
  static const String dismiss = 'Dismiss';
  static const String retry = 'Retry';
  static const String close = 'Close';

  // Settings
  static const String settings = 'Settings';
  static const String theme = 'Theme';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String systemMode = 'System';
  static const String language = 'Language';
  static const String notifications = 'Notifications';
  static const String about = 'About';
  static const String version = 'Version';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // Dialogs
  static const String deleteDialogTitle = 'Delete Task';
  static const String deleteDialogMessage = 'Are you sure you want to delete this task?';
  static const String logoutDialogTitle = 'Logout';
  static const String logoutDialogMessage = 'Are you sure you want to logout?';

  // Loading
  static const String loading = 'Loading...';
  static const String saving = 'Saving...';
  static const String deleting = 'Deleting...';
  static const String pleaseWait = 'Please wait...';

  // Placeholder Images
  static const String emptyIllustration = 'assets/images/empty_tasks.png';
  static const String errorIllustration = 'assets/images/error.png';
  static const String successIllustration = 'assets/images/success.png';
}
