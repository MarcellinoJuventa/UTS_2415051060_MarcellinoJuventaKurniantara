import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import 'ingredient_chip.dart';

/// Reusable Widget: CoffeeCard
/// Kartu menu minuman yang minimalis dan rapi.
class CoffeeCard extends StatelessWidget {
  final CoffeeItem coffee;
  final bool isFavorite;
  final bool isLoggedInDb;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onQuickLog;

  const CoffeeCard({
    super.key,
    required this.coffee,
    required this.isFavorite,
    required this.isLoggedInDb,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onQuickLog,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto Minuman
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  coffee.image,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 88,
                    height: 88,
                    color: AppTheme.softLatte,
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      color: AppTheme.primaryEspresso,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Informasi Menu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.softLatte,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            coffee.category,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentRoast,
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: onToggleFavorite,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.grey.shade400,
                              size: 19,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coffee.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEspresso,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      coffee.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: coffee.ingredients
                                .take(2)
                                .map((ing) => IngredientChip(label: ing))
                                .toList(),
                          ),
                        ),
                        InkWell(
                          onTap: onQuickLog,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLoggedInDb
                                      ? Icons.bookmark_added_rounded
                                      : Icons.add_circle_outline_rounded,
                                  size: 15,
                                  color: AppTheme.accentRoast,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isLoggedInDb ? 'Tersimpan' : 'Catat',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentRoast,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
