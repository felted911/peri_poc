import 'package:flutter/material.dart';
import 'package:peri_poc/core/dependency_injection.dart';
import 'package:peri_poc/core/theme/app_theme.dart';
import 'package:peri_poc/core/constants/app_constants.dart';
import 'package:peri_poc/interfaces/i_voice_service.dart';
import 'package:peri_poc/services/permission_service.dart';
import 'package:peri_poc/presentation/home/home_screen.dart';

/// Setup function that can be used in tests
Future<void> setupApp() async {
  // Ensure Flutter bindings are initialized before any platform channels are used
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app dependencies
  await initializeDependencies();

  // Initialize voice and permission services
  final permissionService = serviceLocator<PermissionService>();
  final voiceService = serviceLocator<IVoiceService>();

  await permissionService.initialize();
  await voiceService.initialize();
}

void main() async {
  // Set up the app
  await setupApp();

  // Run the app
  runApp(const PeriApp());
}

class PeriApp extends StatelessWidget {
  const PeriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(title: 'Peritest Voice Assistant'),
    );
  }
}
