import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../providers/coffee_provider.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/responsive_layout.dart';
import 'add_log_screen.dart';

/// Screen 3: Drink Detail Screen
class DetailScreen extends StatelessWidget {
  final CoffeeItem coffee;

  const DetailScreen({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    final coffeeProvider = context.watch<CoffeeProvider>();
    final isFavorite = coffeeProvider.isFavorite(coffee.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          coffee.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              coffeeProvider.toggleFavorite(coffee.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isFavorite
                        ? '${coffee.title} added to favorites'
                        : '${coffee.title} removed from favorites',
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
              color: isFavorite ? Colors.redAccent : AppTheme.primaryEspresso,
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
              _buildHeroImage(height: 250),
              const SizedBox(height: 16),
              _buildDetailContent(context),
            ],
          ),
        ),
        wide: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildHeroImage(height: 340),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 6,
                    child: _buildDetailContent(context),
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
      borderRadius: BorderRadius.circular(18),
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
              size: 56,
              color: AppTheme.primaryEspresso,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IngredientChip(
              label: coffee.category,
              isHighlighted: true,
            ),
            const SizedBox(height: 12),
            Text(
              coffee.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEspresso,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              coffee.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const Divider(height: 28),
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEspresso,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: coffee.ingredients
                  .map((ing) => IngredientChip(label: ing))
                  .toList(),
            ),
            const SizedBox(height: 26),
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
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text(
                  'Save to Brew Log',
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
