import 'package:flutter/material.dart';
import 'login_screen.dart';

// Retained for backward compatibility – redirects to LoginScreen.
class UIDLoginScreen extends StatelessWidget {
  const UIDLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(selectedRole: 'student');
  }
}
