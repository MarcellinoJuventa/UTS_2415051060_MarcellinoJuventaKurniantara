import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';

/// Reusable Widget: CoffeeCard
/// Clean, overflow-safe drink menu card.
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
              // Drink Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  coffee.image,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 84,
                    height: 84,
                    color: AppTheme.softLatte,
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      color: AppTheme.primaryEspresso,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Drink Info (Strict 4-row single-line layout so it never overflows)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.grey.shade400,
                              size: 18,
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEspresso,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coffee.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coffee.ingredients.take(3).join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentRoast,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onQuickLog,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLoggedInDb
                                      ? Icons.bookmark_added_rounded
                                      : Icons.add_circle_outline_rounded,
                                  size: 14,
                                  color: AppTheme.primaryEspresso,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isLoggedInDb ? 'Saved' : 'Log',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryEspresso,
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
