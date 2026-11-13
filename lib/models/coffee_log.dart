/// Model 2: CoffeeLog
/// Represents a row in the `public.coffee_logs` table on Supabase PostgreSQL.
class CoffeeLog {
  final int? id;
  final int coffeeId;
  final String coffeeTitle;
  final String coffeeImage;
  final String category; // 'Hot' or 'Iced'
  final String sweetnessLevel; // 'No Sugar', 'Less Sweet', 'Normal', 'Extra Sweet'
  final String customNote;
  final int rating; // 1 - 5
  final bool isTried; // true = Favorite, false = To Try
  final DateTime createdAt;

  const CoffeeLog({
    this.id,
    required this.coffeeId,
    required this.coffeeTitle,
    required this.coffeeImage,
    required this.category,
    required this.sweetnessLevel,
    required this.customNote,
    required this.rating,
    required this.isTried,
    required this.createdAt,
  });

  String get recipe {
    if (customNote.startsWith('[Recipe: ')) {
      final endIdx = customNote.indexOf(']');
      if (endIdx != -1) {
        return customNote.substring(9, endIdx).trim();
      }
    }
    if (customNote.startsWith('[Resep: ')) {
      final endIdx = customNote.indexOf(']');
      if (endIdx != -1) {
        return customNote.substring(8, endIdx).trim();
      }
    }
    return 'Espresso, Steamed Milk';
  }

  String get personalNote {
    if (customNote.startsWith('[Recipe: ') ||
        customNote.startsWith('[Resep: ')) {
      final endIdx = customNote.indexOf(']');
      if (endIdx != -1 && endIdx + 1 < customNote.length) {
        return customNote.substring(endIdx + 1).trim();
      }
    }
    return customNote;
  }

  static String encodeRecipeAndNote({
    required String recipe,
    required String note,
  }) {
    final cleanRecipe = recipe.trim().isEmpty ? '-' : recipe.trim();
    final cleanNote = note.trim();
    return '[Recipe: $cleanRecipe] $cleanNote';
  }

  factory CoffeeLog.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    final rawCoffeeId = json['coffee_id'];
    final parsedCoffeeId = rawCoffeeId is int
        ? rawCoffeeId
        : int.tryParse(rawCoffeeId?.toString() ?? '') ?? 0;

    final rawRating = json['rating'];
    final parsedRating = rawRating is int
        ? rawRating
        : int.tryParse(rawRating?.toString() ?? '') ?? 5;

    final rawCreatedAt = json['created_at']?.toString();
    final parsedDate = rawCreatedAt != null
        ? DateTime.tryParse(rawCreatedAt)?.toLocal() ?? DateTime.now()
        : DateTime.now();

    return CoffeeLog(
      id: parsedId,
      coffeeId: parsedCoffeeId,
      coffeeTitle: (json['coffee_title'] ?? 'North Brew').toString(),
      coffeeImage: (json['coffee_image'] ??
              'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600')
          .toString(),
      category: (json['category'] ?? 'Hot').toString(),
      sweetnessLevel: (json['sweetness_level'] ?? 'Normal').toString(),
      customNote: (json['custom_note'] ?? '').toString(),
      rating: parsedRating.clamp(1, 5),
      isTried: json['is_tried'] == true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'coffee_id': coffeeId,
      'coffee_title': coffeeTitle,
      'coffee_image': coffeeImage,
      'category': category,
      'sweetness_level': sweetnessLevel,
      'custom_note': customNote,
      'rating': rating,
      'is_tried': isTried,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'coffee_title': coffeeTitle,
      'category': category,
      'sweetness_level': sweetnessLevel,
      'custom_note': customNote,
      'rating': rating,
      'is_tried': isTried,
    };
  }

  CoffeeLog copyWith({
    int? id,
    int? coffeeId,
    String? coffeeTitle,
    String? coffeeImage,
    String? category,
    String? sweetnessLevel,
    String? customNote,
    int? rating,
    bool? isTried,
    DateTime? createdAt,
  }) {
    return CoffeeLog(
      id: id ?? this.id,
      coffeeId: coffeeId ?? this.coffeeId,
      coffeeTitle: coffeeTitle ?? this.coffeeTitle,
      coffeeImage: coffeeImage ?? this.coffeeImage,
      category: category ?? this.category,
      sweetnessLevel: sweetnessLevel ?? this.sweetnessLevel,
      customNote: customNote ?? this.customNote,
      rating: rating ?? this.rating,
      isTried: isTried ?? this.isTried,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
