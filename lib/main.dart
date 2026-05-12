import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme/app_theme.dart';
import 'core/services/backend_warmup_service.dart';

import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/shell/app_shell.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Wake Render backend in background

  BackendWarmupService.warmup();

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

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return const OnboardingScreen();
          }

          if (user.isAnonymous) {
            FirebaseAuth.instance.signOut();
            return const OnboardingScreen();
          }

          return const AppShell();
        },
      ),
    );
  }
}