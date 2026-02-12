import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/expenses/providers/expenses_provider.dart';
import '../../core/providers/formatter_provider.dart';
import '../widgets/glass_container.dart';

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
    final expenses = ref.watch(expensesProvider);
    final totalBalance = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final formattedBalance = ref
        .watch(currencyFormatterProvider)
        .format(totalBalance);

    return Scaffold(
      extendBody: true,

      /// AppBar with glass container
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: GlassContainer(
            borderRadius: 16,
            opacity: 0.1,
            blur: 10,
            child: AppBar(
              title: Text(
                _getTitle(navigationShell.currentIndex),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Theme.of(context).primaryColor,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search_outlined),
                ),
              ],
            ),
          ),
        ),
      ),

      /// Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// Drawer Header
            UserAccountsDrawerHeader(
              accountName: const Text('Paul Henintsoa'),
              accountEmail: Text('Total Spent: $formattedBalance'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),

            /// Drawer Items
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: navigationShell.currentIndex == 0,
              onTap: () {
                navigationShell.goBranch(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Expenses'),
              selected: navigationShell.currentIndex == 2,
              onTap: () {
                navigationShell.goBranch(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              selected: navigationShell.currentIndex == 3,
              onTap: () {
                navigationShell.goBranch(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      /// Body with smooth transition
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(
          key: ValueKey(navigationShell.currentIndex),
          child: navigationShell,
        ),
      ),

      /// Floating Glass Bottom Navigation
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            borderRadius: 32,
            opacity: 0.15,
            blur: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavButton(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _NavButton(
                  icon: Icons.mic_rounded,
                  label: 'Voice',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () {
                    navigationShell.goBranch(1);
                  },
                ),
                _NavButton(
                  icon: Icons.list_alt_rounded,
                  label: 'List',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2),
                ),
                _NavButton(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.4),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
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
