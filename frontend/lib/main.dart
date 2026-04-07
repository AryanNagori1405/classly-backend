import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/video_provider.dart';
import 'providers/community_provider.dart';
import 'providers/feedback_provider.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => VideoProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedbackProvider(apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classly',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreenWrapper(),
    );
  }
}

/// Wrapper to ensure AuthProvider is initialized before showing SplashScreen
class SplashScreenWrapper extends StatelessWidget {
  const SplashScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
