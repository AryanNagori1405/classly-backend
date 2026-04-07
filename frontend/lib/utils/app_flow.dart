/// App Flow Management
/// 
/// Flow:
/// 1. SplashScreen (3 seconds loading)
/// 2. Check if first time user
///    - YES: RoleSelection → SignupScreen → WelcomeScreen → Home
///    - NO: RoleSelection → LoginScreen → Home
/// 3. Home (StudentHome or TeacherHome)
///    - Navigate to: Profile, Videos, Communities, Doubts
///    - Logout: Back to RoleSelection

class AppFlow {
  // First time user flag
  static bool isFirstTimeUser = true;
  static String? currentUserRole;
  static bool isLoggedIn = false;

  static void setFirstTimeUser(bool value) {
    isFirstTimeUser = value;
  }

  static void setUserRole(String role) {
    currentUserRole = role;
  }

  static void setLoggedIn(bool value) {
    isLoggedIn = value;
  }

  static void reset() {
    isFirstTimeUser = true;
    currentUserRole = null;
    isLoggedIn = false;
  }
}