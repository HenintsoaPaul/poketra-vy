import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../../features/expenses/providers/expenses_provider.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  final hiveService = ref.watch(hiveServiceProvider);
  return OnboardingNotifier(hiveService);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final HiveService _hiveService;

  OnboardingNotifier(this._hiveService)
    : super(_hiveService.isOnboardingComplete());

  Future<void> completeOnboarding() async {
    await _hiveService.setOnboardingComplete(true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    await _hiveService.setOnboardingComplete(false);
    state = false;
  }
}
