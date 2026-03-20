import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'features/expenses/providers/expense_list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  // Schedule Daily Reminder using settings from Hive
  await notificationService.rescheduleDailyNotification(hiveService);

  runApp(
    ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(hiveService)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Poketra Vy',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF244B73),
          primary: const Color(0xFF244B73),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF244B73),
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF244B73),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
