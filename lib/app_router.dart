import 'package:go_router/go_router.dart';
import 'features/home/screens/home_screen.dart';
import 'features/expenses/screens/expenses_list_screen.dart';
import 'features/expenses/screens/voice_expense_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'core/navigation/main_shell_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isOnboardingComplete = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/onboarding';
      if (!isOnboardingComplete) {
        return '/onboarding';
      }
      if (loggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Record branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/record',
                builder: (context, state) => const VoiceExpenseScreen(),
              ),
            ],
          ),
          // Expenses branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpensesListScreen(),
              ),
            ],
          ),
          // Settings branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
