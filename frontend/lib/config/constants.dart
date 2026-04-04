class AppConstants {
  // App Info
  static const String appName = 'Classly';
  static const String appVersion = '1.0.0';

  // API
  static const String apiBaseUrl = 'http://localhost:5000/api';
  static const int apiTimeout = 30;

  // Padding & Margins
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Animation Durations
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 500);
  static const Duration durationXLong = Duration(milliseconds: 800);

  // Shared Preferences Keys
  static const String keyToken = 'token';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';

  // Routes
  static const String routeSplash = '/splash';
  static const String routeRoleSelection = '/role-selection';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeStudentHome = '/student-home';
  static const String routeTeacherHome = '/teacher-home';
  static const String routeCourses = '/courses';
  static const String routeCourseDetail = '/course-detail';
  static const String routeVideoPlayer = '/video-player';
  static const String routeForum = '/forum';
  static const String routeProfile = '/profile';
}

class AppStrings {
  // General
  static const String appName = 'Classly';
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String skip = 'Skip';

  // Auth
  static const String welcome = 'Welcome to Classly';
  static const String signUp = 'Sign Up';
  static const String login = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String changePassword = 'Change Password';
  static const String noAccount = 'Don\'t have an account?';
  static const String haveAccount = 'Already have an account?';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String selectRole = 'Select Your Role';

  // Roles
  static const String student = 'Student';
  static const String teacher = 'Teacher';
  static const String learner = 'Continue as Student';
  static const String educator = 'Continue as Teacher';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String home = 'Home';
  static const String courses = 'Courses';
  static const String forums = 'Forums';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';

  // Courses
  static const String allCourses = 'All Courses';
  static const String myCourses = 'My Courses';
  static const String createCourse = 'Create Course';
  static const String courseTitle = 'Course Title';
  static const String courseDescription = 'Description';
  static const String instructor = 'Instructor';
  static const String students = 'Students';
  static const String videos = 'Videos';
  static const String noCoursesFound = 'No courses found';

  // Videos
  static const String uploadVideo = 'Upload Video';
  static const String videoTitle = 'Video Title';
  static const String videoDescription = 'Description';
  static const String duration = 'Duration';
  static const String views = 'Views';
  static const String upvotes = 'Upvotes';
  static const String downloads = 'Downloads';

  // Profile
  static const String myProfile = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String logout = 'Logout';

  // Made with love
  static const String madeWith = 'Made with 💗 by Aryan Nagori';
}