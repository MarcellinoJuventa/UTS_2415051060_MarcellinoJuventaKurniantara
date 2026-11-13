import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../providers/coffee_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/coffee_card.dart';
import '../widgets/responsive_layout.dart';
import 'add_log_screen.dart';
import 'detail_screen.dart';

/// Screen 1: Home Screen (Minimalist & Clean English UI)
class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  static const List<String> _categories = [
    'All',
    'Coffee',
    'Non-Coffee',
    'Mocktail',
  ];

  @override
  Widget build(BuildContext context) {
    final coffeeProvider = context.watch<CoffeeProvider>();
    final logProvider = context.watch<LogProvider>();
    final isWide = ResponsiveLayout.isWide(context);

    final featuredItems = coffeeProvider.filteredItems.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConfig.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'New Log',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddLogScreen()),
              );
            },
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<CoffeeProvider>().fetchCoffeeCatalog(),
            context.read<LogProvider>().fetchLogs(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCleanHero(context, logProvider.logs.length),
                  const SizedBox(height: 20),

                  // Category Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected =
                            coffeeProvider.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => coffeeProvider.setCategory(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Featured Menu Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Drinks',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateToTab(1),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (coffeeProvider.isLoading && featuredItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (featuredItems.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text('No drinks available right now.'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: coffeeProvider.fetchCoffeeCatalog,
                              child: const Text('Reload Menu'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isWide)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: featuredItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 138,
                      ),
                      itemBuilder: (context, index) => _buildMenuCard(
                        context,
                        featuredItems[index],
                        coffeeProvider,
                        logProvider,
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: featuredItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _buildMenuCard(
                        context,
                        featuredItems[index],
                        coffeeProvider,
                        logProvider,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHero(BuildContext context, int savedCount) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primaryEspresso,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NORTH BAR',
                  style: TextStyle(
                    color: AppTheme.warmCaramel,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Crafted Coffee & Signature Drinks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$savedCount recipes saved in your Brew Log',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warmCaramel,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => onNavigateToTab(1),
                  child: const Text(
                    'Explore Menu',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_cafe_outlined,
              color: AppTheme.softLatte,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    CoffeeItem coffee,
    CoffeeProvider coffeeProvider,
    LogProvider logProvider,
  ) {
    final isFav = coffeeProvider.isFavorite(coffee.id);
    return CoffeeCard(
      coffee: coffee,
      isFavorite: isFav,
      isLoggedInDb: logProvider.isCoffeeLogged(coffee.id),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailScreen(coffee: coffee)),
        );
      },
      onToggleFavorite: () {
        coffeeProvider.toggleFavorite(coffee.id);
      },
      onQuickLog: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddLogScreen(initialCoffee: coffee),
          ),
        );
      },
    );
  }
}
