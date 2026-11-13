/// Model 1: CoffeeItem
/// Merepresentasikan item katalog minuman kopi dari REST API (SampleAPIs Coffee).
class CoffeeItem {
  final int id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String image;
  final String category; // 'Hot' atau 'Iced'

  const CoffeeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.image,
    required this.category,
  });

  /// Parsing JSON dari SampleAPIs Coffee (/coffee/hot atau /coffee/iced)
  /// Dilengkapi null-safety dan normalisasi tipe data.
  factory CoffeeItem.fromJson(
    Map<String, dynamic> json, {
    String defaultCategory = 'Hot',
  }) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final rawTitle = (json['title'] ?? '').toString().trim();
    final rawDescription = (json['description'] ?? '').toString().trim();
    final rawImage = (json['image'] ?? '').toString().trim();

    // Parse ingredients yang bisa berupa List<dynamic> atau String
    final rawIngredients = json['ingredients'];
    List<String> parsedIngredients = [];
    if (rawIngredients is List) {
      parsedIngredients = rawIngredients
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawIngredients is String && rawIngredients.isNotEmpty) {
      parsedIngredients = rawIngredients
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (parsedIngredients.isEmpty) {
      parsedIngredients = ['Specialty Arabica Espresso', 'Filtered Water'];
    }

    final validImage = rawImage.startsWith('http')
        ? rawImage
        : 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600';

    return CoffeeItem(
      id: parsedId,
      title: rawTitle.isEmpty ? 'North Signature Brew' : rawTitle,
      description: rawDescription.isEmpty
          ? 'Racikan kopi spesialti dengan ekstraksi seimbang khas bar North.'
          : rawDescription,
      ingredients: parsedIngredients,
      image: validImage,
      category: (json['category'] ?? defaultCategory).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'image': image,
      'category': category,
    };
  }
}
