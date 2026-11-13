import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../widgets/responsive_layout.dart';

/// Navigasi utama aplikasi North:
/// - Menggunakan NavigationBar (BottomNavigationBar M3) pada layar Compact (< 600px)
/// - Menggunakan NavigationRail pada layar Wide/Expanded (>= 600px)
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
      label: 'Bar Menu',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
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
                        Icons.coffee_maker_rounded,
                        color: Colors.white,
                        size: 24,
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
                  label: Text('Bar Menu'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
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
