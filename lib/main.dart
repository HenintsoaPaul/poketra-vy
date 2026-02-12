import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'core/services/hive_service.dart';
import 'features/expenses/providers/expenses_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(hiveService)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Voice Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF244B73),
          primary: const Color(0xFF244B73),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF244B73),
        ),
        scaffoldBackgroundColor: const Color(0xFFEDF5FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF244B73),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
