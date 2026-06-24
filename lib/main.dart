import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize mock Firebase integration
  await FirebaseService.instance.initializeApp();

  runApp(
    const ProviderScope(
      child: Play2CodeApp(),
    ),
  );
}

class Play2CodeApp extends StatelessWidget {
  const Play2CodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Play2Code',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
