import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/expenses/providers/expenses_provider.dart';
import '../../core/providers/formatter_provider.dart';

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
      appBar: AppBar(
        title: Text(_getTitle(navigationShell.currentIndex)),

        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          // IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
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

      /// Body
      body: navigationShell,

      /// Floating Action Button
      floatingActionButton: navigationShell.currentIndex == 1
          ? null
          : FloatingActionButton(
              onPressed: () => navigationShell.goBranch(1),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.mic, size: 28),
            ),
    );
  }
}
