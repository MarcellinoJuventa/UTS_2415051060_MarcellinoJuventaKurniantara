import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../widgets/responsive_layout.dart';

/// Main Navigation Shell:
/// - NavigationBar on Compact screens (< 600px)
/// - NavigationRail on Wide/Expanded screens (>= 600px)
class MainNavigationShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> pages;
  final Widget? floatingActionButton;

  const MainNavigationShell({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.pages,
    this.floatingActionButton,
  });

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.local_cafe_outlined),
      selectedIcon: Icon(Icons.local_cafe_rounded),
      label: 'Menu',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_border_rounded),
      selectedIcon: Icon(Icons.bookmark_rounded),
      label: 'Brew Log',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPage = pages[currentIndex];

    return ResponsiveLayout(
      compact: Scaffold(
        body: currentPage,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.softLatte,
          destinations: _destinations,
        ),
      ),
      wide: Scaffold(
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              extended: MediaQuery.sizeOf(context).width >= 960,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.softLatte,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEspresso,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_cafe_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppConfig.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEspresso,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.local_cafe_outlined),
                  selectedIcon: Icon(Icons.local_cafe_rounded),
                  label: Text('Menu'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded),
                  label: Text('Brew Log'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: currentPage),
          ],
        ),
      ),
    );
  }
}
