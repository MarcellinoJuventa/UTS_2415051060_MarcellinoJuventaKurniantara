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

/// Screen 1: Home / Dashboard Screen
/// Menampilkan ringkasan statistik bar, pintasan filter kategori, daftar favorit,
/// dan rekomendasi racikan kopi bar dari REST API.
class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final coffeeProvider = context.watch<CoffeeProvider>();
    final logProvider = context.watch<LogProvider>();
    final isWide = ResponsiveLayout.isWide(context);

    final featuredItems = coffeeProvider.allItems.take(4).toList();
    final favoriteItems = coffeeProvider.favoriteItems;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.coffee_maker_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              '${AppConfig.appName} — Coffee Bar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sinkronisasi API & Database',
            onPressed: () {
              context.read<CoffeeProvider>().fetchCoffeeCatalog();
              context.read<LogProvider>().fetchLogs();
            },
            icon: const Icon(Icons.sync_rounded),
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
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner North Specialty Coffee Bar
                  _buildHeroBanner(context),
                  const SizedBox(height: 18),

                  // Statistik Ringkasan (Responsive Grid/Row)
                  _buildSummaryMetrics(
                    context,
                    coffeeProvider,
                    logProvider,
                    isWide,
                  ),
                  const SizedBox(height: 22),

                  // Quick Category Filter Bar
                  _buildQuickCategorySection(context, coffeeProvider),
                  const SizedBox(height: 22),

                  // Kopi Favorit Bar (Shared State)
                  if (favoriteItems.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Favorit Bar Anda (Shared State)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryEspresso,
                          ),
                        ),
                        Text(
                          '${favoriteItems.length} menu',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentRoast,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 128,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: favoriteItems.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = favoriteItems[index];
                          return _buildFavoriteMiniCard(context, item);
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // Rekomendasi Barista (Dari REST API)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Barista's Pick (Katalog API)",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => onNavigateToTab(1),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                        label: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (coffeeProvider.isLoading && featuredItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (featuredItems.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('Katalog kopi belum dimuat.'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: coffeeProvider.fetchCoffeeCatalog,
                              child: const Text('Muat Katalog Kopi'),
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
                        mainAxisExtent: 195,
                      ),
                      itemBuilder: (context, index) => _buildFeaturedCard(
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
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildFeaturedCard(
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

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryEspresso, Color(0xFF4E342E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warmCaramel.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'NORDIC SPECIALTY COFFEE BAR',
              style: TextStyle(
                color: AppTheme.softLatte,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Eksplorasi Racikan Kopi Bar & Catat Tasting Log Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temukan komposisi minuman Hot & Iced Coffee dari REST API publik dan simpan resep kustom Anda ke database Supabase.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warmCaramel,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => onNavigateToTab(1),
                icon: const Icon(Icons.local_cafe_rounded, size: 18),
                label: const Text('Jelajahi Menu Bar'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddLogScreen()),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Catat Racikan Baru'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics(
    BuildContext context,
    CoffeeProvider coffeeProvider,
    LogProvider logProvider,
    bool isWide,
  ) {
    final cards = [
      _MetricTile(
        icon: Icons.local_cafe_rounded,
        label: 'Menu Bar (API)',
        value: '${coffeeProvider.allItems.length}',
        subtitle:
            '${coffeeProvider.hotCoffeeCount} Hot • ${coffeeProvider.icedCoffeeCount} Iced',
        color: AppTheme.primaryEspresso,
        onTap: () => onNavigateToTab(1),
      ),
      _MetricTile(
        icon: Icons.cloud_done_rounded,
        label: 'Tersimpan (Supabase)',
        value: '${logProvider.logs.length}',
        subtitle:
            '${logProvider.triedCount} Dicoba • ${logProvider.wishlistCount} Wishlist',
        color: AppTheme.accentRoast,
        onTap: () => onNavigateToTab(2),
      ),
      _MetricTile(
        icon: Icons.star_rounded,
        label: 'Rata-rata Rating',
        value: logProvider.averageRating.toStringAsFixed(1),
        subtitle: '${coffeeProvider.favoriteIds.length} Kopi Favorit Bar',
        color: Colors.amber.shade800,
        onTap: () => onNavigateToTab(2),
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: c,
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: cards
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: c,
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuickCategorySection(
    BuildContext context,
    CoffeeProvider coffeeProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pintasan Kategori Bar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.primaryEspresso,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.apps_rounded, size: 17),
                  label: const Text('Semua Menu'),
                  onPressed: () {
                    coffeeProvider.setCategory('All');
                    onNavigateToTab(1);
                  },
                ),
                ActionChip(
                  avatar: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 17,
                    color: AppTheme.hotAmber,
                  ),
                  label: const Text('Hot Espresso & Milk'),
                  onPressed: () {
                    coffeeProvider.setCategory('Hot');
                    onNavigateToTab(1);
                  },
                ),
                ActionChip(
                  avatar: const Icon(
                    Icons.ac_unit_rounded,
                    size: 17,
                    color: AppTheme.icedBlue,
                  ),
                  label: const Text('Iced & Cold Brew'),
                  onPressed: () {
                    coffeeProvider.setCategory('Iced');
                    onNavigateToTab(1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteMiniCard(BuildContext context, CoffeeItem item) {
    return SizedBox(
      width: 240,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailScreen(coffee: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.image,
                    width: 68,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 68,
                      height: 90,
                      color: AppTheme.softLatte,
                      child: const Icon(Icons.coffee_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentRoast,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.ingredients.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(
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

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEspresso,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
