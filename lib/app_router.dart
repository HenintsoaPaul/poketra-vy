import 'package:go_router/go_router.dart';
import 'features/home/screens/home_screen.dart';
import 'features/expenses/screens/expenses_list_screen.dart';
import 'features/expenses/screens/voice_expense_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'core/navigation/main_shell_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _OnboardingWrapper(
          child: ScaffoldWithNavBar(navigationShell: navigationShell),
        );
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
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

class _OnboardingWrapper extends ConsumerWidget {
  final Widget child;
  const _OnboardingWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnboardingComplete = ref.watch(onboardingProvider);

    if (!isOnboardingComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/onboarding');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
