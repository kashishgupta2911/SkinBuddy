import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/shell/app_shell.dart';
import 'firebase_options.dart';

import 'package:http/http.dart' as http;

Future<void> warmupBackend() async {
  try {
    final response = await http.get(
      Uri.parse('https://skinbuddy.onrender.com/health'),
    );

    debugPrint(
      'Render warmup status: ${response.statusCode}',
    );
  } catch (e) {
    debugPrint(
      'Render warmup failed: $e',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Wake Render backend
  await warmupBackend();

  // Remove old anonymous login sessions
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null && currentUser.isAnonymous) {
    await FirebaseAuth.instance.signOut();
  }

  runApp(const SkinBuddyApp());
}

class SkinBuddyApp extends StatelessWidget {
  const SkinBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinBuddy',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = snapshot.data;

          // No logged-in user → onboarding first
          if (user == null) {
            return const OnboardingScreen();
          }

          // Anonymous users should not be allowed
          if (user.isAnonymous) {
            FirebaseAuth.instance.signOut();
            return const OnboardingScreen();
          }

          // Real logged-in user → AppShell
          return const AppShell();
        },
      ),
    );
  }
}