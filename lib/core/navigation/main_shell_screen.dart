import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/expenses/providers/expense_list_provider.dart';
import '../../core/providers/formatter_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/app_background.dart';

/// Widget that wraps screens with a drawer and FAB
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Voice Entry';
      case 2:
        return 'Expenses';
      case 3:
        return 'Settings';
      default:
        return 'Poketra Vy';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);
    final totalBalance = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final formattedBalance = ref
        .watch(currencyFormatterProvider)
        .format(totalBalance);

    return Scaffold(
      extendBody: true,

      /// Transparent AppBar
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              _getTitle(navigationShell.currentIndex),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_outlined)),
        ],
      ),

      /// Body inside AppBackground
      body: AppBackground(child: navigationShell),

      /// Floating Glass Bottom Navigation
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            borderRadius: 32,
            opacity: 0.3,
            blur: 25,
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 4;
                return Stack(
                  children: [
                    // Sliding Indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      left: navigationShell.currentIndex * itemWidth,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        width: itemWidth,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: Icons.dashboard_rounded,
                          label: 'Home',
                          isSelected: navigationShell.currentIndex == 0,
                          onTap: () => navigationShell.goBranch(0),
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.mic_rounded,
                          label: 'Voice',
                          isSelected: navigationShell.currentIndex == 1,
                          onTap: () => navigationShell.goBranch(1),
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.list_alt_rounded,
                          label: 'List',
                          isSelected: navigationShell.currentIndex == 2,
                          onTap: () => navigationShell.goBranch(2),
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          isSelected: navigationShell.currentIndex == 3,
                          onTap: () => navigationShell.goBranch(3),
                          width: itemWidth,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final inactiveColor = primaryColor.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : inactiveColor,
                size: 26,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
