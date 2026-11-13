import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/coffee_provider.dart';
import 'providers/log_provider.dart';
import 'screens/add_log_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_logs_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NorthApp());
}

class NorthApp extends StatelessWidget {
  const NorthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CoffeeProvider()..fetchCoffeeCatalog(),
        ),
        ChangeNotifierProvider(
          create: (_) => LogProvider()..fetchLogs(),
        ),
      ],
      child: MaterialApp(
        title: '${AppConfig.appName} - ${AppConfig.appTagline}',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const NorthRootScreen(),
      ),
    );
  }
}

class NorthRootScreen extends StatefulWidget {
  const NorthRootScreen({super.key});

  @override
  State<NorthRootScreen> createState() => _NorthRootScreenState();
}

class _NorthRootScreenState extends State<NorthRootScreen> {
  int _selectedIndex = 0;

  void _setTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigateToTab: _setTab),
      const CatalogScreen(),
      const SavedLogsScreen(),
      const ProfileScreen(),
    ];

    return MainNavigationShell(
      currentIndex: _selectedIndex,
      onDestinationSelected: _setTab,
      pages: pages,
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryEspresso,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddLogScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Catatan'),
            )
          : null,
    );
  }
}
