import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/auth_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline local data persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    ProviderScope(
      child: TaskManagementApp(
        hasSeenOnboarding: hasSeenOnboarding,
      ),
    ),
  );
}

class TaskManagementApp extends ConsumerWidget {
  final bool hasSeenOnboarding;

  const TaskManagementApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management',
      theme: AppTheme.lightTheme,
      home: _resolveInitialScreen(authState),
    );
  }

  Widget _resolveInitialScreen(AuthState authState) {
    if (!hasSeenOnboarding) {
      return const OnboardingScreen();
    }
    if (authState is AuthenticatedState) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
