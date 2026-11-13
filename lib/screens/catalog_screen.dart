import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coffee_item.dart';
import '../providers/coffee_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/coffee_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/state_view_widget.dart';
import 'add_log_screen.dart';
import 'detail_screen.dart';

/// Screen 2: Menu Screen
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final TextEditingController _searchController;

  static const List<String> _categories = [
    'Semua',
    'Coffee',
    'Non-Coffee',
    'Mocktail',
  ];

  @override
  void initState() {
    super.initState();
    final currentQuery = context.read<CoffeeProvider>().searchQuery;
    _searchController = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coffeeProvider = context.watch<CoffeeProvider>();
    final logProvider = context.watch<LogProvider>();
    final items = coffeeProvider.filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan Menu',
            onPressed: () => context.read<CoffeeProvider>().fetchCoffeeCatalog(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pencarian & Filter Kategori yang bersih
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: coffeeProvider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Cari menu',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: coffeeProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              coffeeProvider.setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear_rounded, size: 18),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
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
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildCatalogBody(
              context,
              coffeeProvider,
              logProvider,
              items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogBody(
    BuildContext context,
    CoffeeProvider coffeeProvider,
    LogProvider logProvider,
    List<CoffeeItem> items,
  ) {
    if (coffeeProvider.isLoading) {
      return const LoadingStateView(
        message: 'Memuat daftar menu...',
      );
    }

    if (coffeeProvider.errorMessage != null && coffeeProvider.allItems.isEmpty) {
      return ErrorStateView(
        message: coffeeProvider.errorMessage!,
        onRetry: coffeeProvider.fetchCoffeeCatalog,
      );
    }

    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: 'Menu Tidak Ditemukan',
        subtitle: 'Coba gunakan kata kunci atau kategori lain.',
        actionLabel: 'Reset Filter',
        onAction: () {
          _searchController.clear();
          coffeeProvider.clearFilters();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: coffeeProvider.fetchCoffeeCatalog,
      child: ResponsiveCollectionView(
        itemCount: items.length,
        mainAxisExtent: 132,
        itemBuilder: (context, index, _) {
          final coffee = items[index];
          final isFav = coffeeProvider.isFavorite(coffee.id);
          final isLogged = logProvider.isCoffeeLogged(coffee.id);

          return CoffeeCard(
            coffee: coffee,
            isFavorite: isFav,
            isLoggedInDb: isLogged,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetailScreen(coffee: coffee),
                ),
              );
            },
            onToggleFavorite: () {
              coffeeProvider.toggleFavorite(coffee.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isFav
                        ? '${coffee.title} ditambahkan ke favorit'
                        : '${coffee.title} dihapus dari favorit',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onQuickLog: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddLogScreen(initialCoffee: coffee),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
