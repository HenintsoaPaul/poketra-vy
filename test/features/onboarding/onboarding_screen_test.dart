import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';
import 'package:poketra_vy/features/onboarding/screens/onboarding_screen.dart';
import 'package:go_router/go_router.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;

  setUp(() {
    mockHiveService = MockHiveService();

    when(() => mockHiveService.isOnboardingComplete()).thenReturn(false);
    when(
      () => mockHiveService.setOnboardingComplete(any()),
    ).thenAnswer((_) async {});
    when(() => mockHiveService.getExpenses()).thenReturn([]);
  });

  Widget createOnboardingScreen(GoRouter router) {
    return ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('OnboardingScreen flow: welcome -> info -> completion', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(createOnboardingScreen(router));
    await tester.pumpAndSettle();

    // 1. Welcome page
    expect(find.text('Welcome to Poketra Vy'), findsOneWidget);

    // 2. Tap next -> Info page
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('Effortless Voice Tracking'), findsOneWidget);

    // 3. Tap Get Started -> Completion & Navigation
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify completion was saved
    verify(() => mockHiveService.setOnboardingComplete(true)).called(1);

    // Verify navigation to home screen
    expect(find.text('Home Screen'), findsOneWidget);
    expect(router.state.uri.toString(), '/');
  });
}
