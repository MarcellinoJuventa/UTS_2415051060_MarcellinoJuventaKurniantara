import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../providers/coffee_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/responsive_layout.dart';
import 'add_log_screen.dart';

/// Screen 3: Coffee Detail Screen
/// Menampilkan detail lengkap minuman kopi dari katalog REST API (passing data `CoffeeItem`),
/// komposisi bahan bar, status favorit (shared state), serta navigasi ke `AddLogScreen`.
class DetailScreen extends StatelessWidget {
  final CoffeeItem coffee;

  const DetailScreen({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    final coffeeProvider = context.watch<CoffeeProvider>();
    final logProvider = context.watch<LogProvider>();
    final isFavorite = coffeeProvider.isFavorite(coffee.id);
    final isLogged = logProvider.isCoffeeLogged(coffee.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          coffee.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            onPressed: () {
              coffeeProvider.toggleFavorite(coffee.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isFavorite
                        ? '"${coffee.title}" ditambahkan ke Favorit Bar!'
                        : '"${coffee.title}" dihapus dari Favorit Bar.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
      body: ResponsiveLayout(
        compact: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroImage(height: 260),
              const SizedBox(height: 18),
              _buildDetailContent(context, isLogged),
            ],
          ),
        ),
        wide: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildHeroImage(height: 380),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 6,
                    child: _buildDetailContent(context, isLogged),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage({required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        coffee.image,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: height,
          color: AppTheme.softLatte,
          child: const Center(
            child: Icon(
              Icons.local_cafe_rounded,
              size: 64,
              color: AppTheme.primaryEspresso,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, bool isLogged) {
    final isIced = coffee.category.toLowerCase() == 'iced';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                IngredientChip(
                  label: '${coffee.category} Coffee',
                  icon: isIced
                      ? Icons.ac_unit_rounded
                      : Icons.local_fire_department_rounded,
                  isHighlighted: true,
                ),
                IngredientChip(
                  label: 'ID Katalog #${coffee.id}',
                  icon: Icons.qr_code_rounded,
                ),
                if (isLogged)
                  const IngredientChip(
                    label: 'Tersimpan di Supabase',
                    icon: Icons.cloud_done_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              coffee.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEspresso,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Karakter Rasa & Deskripsi Bar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentRoast,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              coffee.description,
              style: TextStyle(
                fontSize: 14.5,
                color: Colors.grey.shade800,
                height: 1.55,
              ),
            ),
            const Divider(height: 28),
            const Text(
              'Komposisi Racikan Bar (Ingredients)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentRoast,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: coffee.ingredients
                  .map(
                    (ing) => IngredientChip(
                      label: ing,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddLogScreen(initialCoffee: coffee),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text(
                  'Simpan Racikan ke Brew Log (Supabase)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
