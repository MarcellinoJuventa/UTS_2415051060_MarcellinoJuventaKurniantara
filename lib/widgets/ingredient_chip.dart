import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Reusable Widget 3: IngredientChip
/// Menampilkan komposisi bahan minuman kopi bar atau badge kategori (Hot / Iced).
class IngredientChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isHighlighted;

  const IngredientChip({
    super.key,
    required this.label,
    this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighlighted
        ? AppTheme.primaryEspresso
        : AppTheme.softLatte.withValues(alpha: 0.75);
    final fgColor = isHighlighted ? Colors.white : AppTheme.primaryEspresso;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fgColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
