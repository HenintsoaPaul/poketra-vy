import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poketra_vy/core/services/hive_service.dart';
import 'package:poketra_vy/core/providers/onboarding_provider.dart';
import 'package:poketra_vy/features/expenses/providers/expense_list_provider.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  setUpAll(() {
    registerFallbackValue(true);
  });

  late MockHiveService mockHiveService;
  late ProviderContainer container;

  setUp(() {
    mockHiveService = MockHiveService();
    when(() => mockHiveService.isOnboardingComplete()).thenReturn(false);

    container = ProviderContainer(
      overrides: [hiveServiceProvider.overrideWithValue(mockHiveService)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('OnboardingNotifier', () {
    test('initializes with state from hive', () {
      final onboarding = container.read(onboardingProvider);
      expect(onboarding, isFalse);
      verify(() => mockHiveService.isOnboardingComplete()).called(1);
    });

    test('completeOnboarding updates state and hive', () async {
      when(
        () => mockHiveService.setOnboardingComplete(any()),
      ).thenAnswer((_) async => {});

      await container.read(onboardingProvider.notifier).completeOnboarding();

      final state = container.read(onboardingProvider);
      expect(state, isTrue);
      verify(() => mockHiveService.setOnboardingComplete(true)).called(1);
    });

    test('resetOnboarding updates state and hive', () async {
      when(
        () => mockHiveService.setOnboardingComplete(any()),
      ).thenAnswer((_) async => {});

      // Force state to true first
      await container.read(onboardingProvider.notifier).completeOnboarding();

      await container.read(onboardingProvider.notifier).resetOnboarding();

      final state = container.read(onboardingProvider);
      expect(state, isFalse);
      verify(() => mockHiveService.setOnboardingComplete(false)).called(1);
    });
  });
}
