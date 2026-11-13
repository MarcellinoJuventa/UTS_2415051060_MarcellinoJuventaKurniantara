import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../providers/coffee_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/coffee_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/state_view_widget.dart';
import 'add_log_screen.dart';
import 'detail_screen.dart';

/// Screen 2: Coffee Catalog / Bar Menu Screen
/// Menampilkan katalog menu minuman kopi dari REST API (SampleAPIs Coffee),
/// mendukung pencarian real-time, filter kategori (All / Hot / Iced),
/// tampilan responsif (ListView pada Compact, GridView pada Wide),
/// serta penanganan Loading, Error, dan Empty State.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final TextEditingController _searchController;

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
        title: const Row(
          children: [
            Icon(Icons.local_cafe_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              'North Bar Menu (REST API)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang Katalog API',
            onPressed: () => context.read<CoffeeProvider>().fetchCoffeeCatalog(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel Pencarian & Filter Kategori
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: coffeeProvider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText:
                        'Cari nama kopi, rasa, atau bahan (misal: Espresso, Oat, Caramel)...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: coffeeProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              coffeeProvider.setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear_rounded),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Kategori:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.primaryEspresso,
                      ),
                    ),
                    ChoiceChip(
                      label: Text('Semua (${coffeeProvider.allItems.length})'),
                      selected: coffeeProvider.selectedCategory == 'All',
                      onSelected: (_) => coffeeProvider.setCategory('All'),
                    ),
                    ChoiceChip(
                      avatar: const Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: AppTheme.hotAmber,
                      ),
                      label: Text('Hot (${coffeeProvider.hotCoffeeCount})'),
                      selected: coffeeProvider.selectedCategory == 'Hot',
                      onSelected: (_) => coffeeProvider.setCategory('Hot'),
                    ),
                    ChoiceChip(
                      avatar: const Icon(
                        Icons.ac_unit_rounded,
                        size: 16,
                        color: AppTheme.icedBlue,
                      ),
                      label: Text('Iced (${coffeeProvider.icedCoffeeCount})'),
                      selected: coffeeProvider.selectedCategory == 'Iced',
                      onSelected: (_) => coffeeProvider.setCategory('Iced'),
                    ),
                  ],
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
        message: 'Mengambil katalog kopi dari SampleAPIs REST API...',
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
        title: 'Menu Kopi Tidak Ditemukan',
        subtitle:
            'Tidak ada minuman kopi yang cocok dengan kata kunci "${coffeeProvider.searchQuery}" pada kategori ${coffeeProvider.selectedCategory}.',
        actionLabel: 'Reset Pencarian & Filter',
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
        mainAxisExtent: 195,
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
                        ? '"${coffee.title}" disimpan ke Favorit Bar!'
                        : '"${coffee.title}" dihapus dari Favorit Bar.',
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
