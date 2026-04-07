import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import '../widgets/app_background.dart';

/// Widget that wraps screens with a bottom nav and auto-hiding AppBar.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isAppBarVisible = true;

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Voice Entry';
      case 2:
        return 'Expenses';
      case 3:
        return 'Categories';
      case 4:
        return 'Settings';
      default:
        return 'Poketra Vy';
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      if (direction == ScrollDirection.reverse && _isAppBarVisible) {
        // Scrolling down → hide
        setState(() => _isAppBarVisible = false);
      } else if (direction == ScrollDirection.forward && !_isAppBarVisible) {
        // Scrolling up → show
        setState(() => _isAppBarVisible = true);
      }
    }

    // Also show AppBar when at the top of the scroll view
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels <= 0 && !_isAppBarVisible) {
        setState(() => _isAppBarVisible = true);
      }
    }

    return false; // Don't consume the notification
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final topPadding = MediaQuery.of(context).padding.top;
    const appBarHeight = kToolbarHeight;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: AppBackground(
          child: Stack(
            children: [
              // Main content — padding animates to fill AppBar space when hidden
              Positioned.fill(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.only(
                    top: _isAppBarVisible
                        ? topPadding + appBarHeight
                        : topPadding,
                  ),
                  child: shell,
                ),
              ),

              // Animated AppBar overlay (transparent background)
              AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                offset: _isAppBarVisible ? Offset.zero : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isAppBarVisible ? 1.0 : 0.0,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(top: topPadding),
                    height: topPadding + appBarHeight,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        // Title area
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getTitle(shell.currentIndex),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.search_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

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
                final itemWidth = constraints.maxWidth / 5;
                return Stack(
                  children: [
                    // Sliding Indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      left: shell.currentIndex * itemWidth,
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
                          isSelected: shell.currentIndex == 0,
                          onTap: () => shell.goBranch(0),
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.mic_rounded,
                          label: 'Voice',
                          isSelected: shell.currentIndex == 1,
                          onTap: () => shell.goBranch(1),
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.attach_money_rounded,
                          label: 'Expenses',
                          isSelected: shell.currentIndex == 2,
                          onTap: () => shell.goBranch(2),
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.category_rounded,
                          label: 'Categories',
                          isSelected: shell.currentIndex == 3,
                          onTap: () => shell.goBranch(3),
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          isSelected: shell.currentIndex == 4,
                          onTap: () => shell.goBranch(4),
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
