import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import 'ingredient_chip.dart';

/// Reusable Widget 4: CoffeeCard
/// Kartu item katalog kopi dari REST API yang mendukung interaksi klik detail,
/// tombol favorit (shared state), dan tombol cepat tambah ke Brew Log.
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
    final isIced = coffee.category.toLowerCase() == 'iced';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Minuman Kopi
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      coffee.image,
                      width: 96,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 96,
                        height: 110,
                        color: AppTheme.softLatte,
                        child: const Icon(
                          Icons.local_cafe_rounded,
                          color: AppTheme.primaryEspresso,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isIced ? AppTheme.icedBlue : AppTheme.hotAmber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        coffee.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Detail Teks & Interaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coffee.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryEspresso,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: isFavorite
                              ? 'Hapus dari Favorit Bar'
                              : 'Simpan ke Favorit Bar',
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? Colors.redAccent
                                : Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      coffee.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: coffee.ingredients
                          .take(3)
                          .map((ing) => IngredientChip(label: ing))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isLoggedInDb)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tersimpan di Log',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                        TextButton.icon(
                          onPressed: onQuickLog,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: AppTheme.accentRoast,
                          ),
                          icon: const Icon(Icons.note_add_outlined, size: 16),
                          label: const Text(
                            'Catat Racikan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
