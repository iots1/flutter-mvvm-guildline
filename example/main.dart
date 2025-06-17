// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/http_service.dart';
import 'providers/app_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/screens/user_profile_screen.dart';
import 'features/notification/presentation/screens/notification_screen.dart';
import 'core/theme/app_theme.dart'; // Import your custom theme

void main() {
  HttpService.setEnvironment(Environment.Development); // Set desired environment
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders, // All providers from core and features
      child: MaterialApp(
        title: 'Flutter MVVM App',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(), // Starting screen
        routes: {
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const UserProfileScreen(),
          '/notifications': (context) => const NotificationScreen(),
          // Define other routes here
        },
      ),
    );
  }
}