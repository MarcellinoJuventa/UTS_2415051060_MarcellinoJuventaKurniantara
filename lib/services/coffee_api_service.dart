import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/coffee_item.dart';

/// Service 1: CoffeeApiService
/// Mengambil katalog minuman dari REST API publik (SampleAPIs Coffee & TheCocktailDB)
/// dan menormalisasi deskripsi serta bahan komposisi ke Bahasa Indonesia.
class CoffeeApiService {
  final http.Client _client;

  CoffeeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<CoffeeItem>> fetchAllCoffeeDrinks() async {
    try {
      final responses = await Future.wait([
        _safeGet(AppConfig.hotCoffeeApiUrl),
        _safeGet(AppConfig.icedCoffeeApiUrl),
        _safeGet(AppConfig.nonCoffeeApiUrl),
        _safeGet(AppConfig.mocktailApiUrl),
      ]);

      final hotRes = responses[0];
      final icedRes = responses[1];
      final nonCoffeeRes = responses[2];
      final mocktailRes = responses[3];

      final List<CoffeeItem> catalog = [];

      // 1. Parse Hot Coffee -> 'Kopi'
      if (hotRes != null && hotRes.statusCode == 200) {
        final decoded = jsonDecode(hotRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final coffee =
                  CoffeeItem.fromJson(item, defaultCategory: 'Kopi');
              if (_isValidEntry(coffee)) {
                final localizedIng =
                    coffee.ingredients.map(_translateIngredient).toList();
                catalog.add(
                  CoffeeItem(
                    id: coffee.id,
                    title: coffee.title,
                    description: _localizeDescription(
                      coffee.title,
                      localizedIng,
                      'Kopi',
                    ),
                    ingredients: localizedIng,
                    image: coffee.image,
                    category: 'Kopi',
                  ),
                );
              }
            }
          }
        }
      }

      // 2. Parse Iced Coffee -> 'Kopi'
      if (icedRes != null && icedRes.statusCode == 200) {
        final decoded = jsonDecode(icedRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final parsed =
                  CoffeeItem.fromJson(item, defaultCategory: 'Kopi');
              if (_isValidEntry(parsed)) {
                final uniqueId =
                    parsed.id < 1000 ? parsed.id + 1000 : parsed.id;
                final localizedIng =
                    parsed.ingredients.map(_translateIngredient).toList();
                catalog.add(
                  CoffeeItem(
                    id: uniqueId,
                    title: parsed.title,
                    description: _localizeDescription(
                      parsed.title,
                      localizedIng,
                      'Kopi',
                    ),
                    ingredients: localizedIng,
                    image: parsed.image,
                    category: 'Kopi',
                  ),
                );
              }
            }
          }
        }
      }

      // 3. Parse Non-Coffee (TheCocktailDB c=Cocoa) -> 'Non-Kopi'
      if (nonCoffeeRes != null && nonCoffeeRes.statusCode == 200) {
        final decoded = jsonDecode(nonCoffeeRes.body);
        if (decoded is Map<String, dynamic> && decoded['drinks'] is List) {
          final drinks = decoded['drinks'] as List;
          for (final raw in drinks.take(10)) {
            if (raw is Map<String, dynamic>) {
              final id =
                  int.tryParse(raw['idDrink']?.toString() ?? '') ?? 2000;
              final title = (raw['strDrink'] ?? '').toString().trim();
              final image = (raw['strDrinkThumb'] ?? '').toString().trim();
              if (title.isNotEmpty && image.startsWith('http')) {
                catalog.add(
                  CoffeeItem(
                    id: id,
                    title: title,
                    description:
                        'Minuman coklat dan susu racikan lembut dengan aroma vanila yang kaya rasa.',
                    ingredients: const [
                      'Coklat Pilihan',
                      'Susu Segar',
                      'Krim Vanila',
                    ],
                    image: image,
                    category: 'Non-Kopi',
                  ),
                );
              }
            }
          }
        }
      }

      // 4. Parse Minuman Segar / Mocktail (TheCocktailDB a=Non_Alcoholic) -> 'Minuman Segar'
      if (mocktailRes != null && mocktailRes.statusCode == 200) {
        final decoded = jsonDecode(mocktailRes.body);
        if (decoded is Map<String, dynamic> && decoded['drinks'] is List) {
          final drinks = decoded['drinks'] as List;
          for (final raw in drinks.take(14)) {
            if (raw is Map<String, dynamic>) {
              final id =
                  int.tryParse(raw['idDrink']?.toString() ?? '') ?? 3000;
              final title = (raw['strDrink'] ?? '').toString().trim();
              final image = (raw['strDrinkThumb'] ?? '').toString().trim();
              if (title.isNotEmpty && image.startsWith('http')) {
                catalog.add(
                  CoffeeItem(
                    id: id,
                    title: title,
                    description:
                        'Minuman segar non-alkohol dari perpaduan sari buah pilihan, sirup manis, dan es batu.',
                    ingredients: const [
                      'Sari Buah Segar',
                      'Sirup Manis',
                      'Air Soda',
                      'Es Batu',
                    ],
                    image: image,
                    category: 'Minuman Segar',
                  ),
                );
              }
            }
          }
        }
      }

      if (catalog.isEmpty) {
        return _curatedFallbackCatalog;
      }

      return catalog;
    } catch (e) {
      throw Exception('Gagal memuat daftar menu: $e');
    }
  }

  Future<http.Response?> _safeGet(String url) async {
    try {
      return await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      return null;
    }
  }

  String _translateIngredient(String raw) {
    final lower = raw.toLowerCase().trim();
    const dictionary = {
      'espresso': 'Espresso',
      '1 oz espresso': '1 Shot Espresso',
      '2 oz espresso': 'Double Espresso',
      'short pulled espresso': 'Espresso Pekat',
      'long pulled espresso': 'Long Espresso',
      'steamed milk': 'Susu Kukus',
      'milk': 'Susu Segar',
      'cold milk': 'Susu Dingin',
      'foamed milk': 'Busa Susu',
      'foam': 'Busa Susu',
      'hot water': 'Air Panas',
      'water': 'Air Mineral',
      'ice': 'Es Batu',
      'sugar': 'Gula',
      'brown sugar': 'Gula Aren',
      'caramel syrup': 'Sirup Karamel',
      'chocolate': 'Coklat',
      'cocoa': 'Bubuk Kakao',
      'whipped cream': 'Krim Kocok',
      'cream': 'Krim Lembut',
      'vanilla extract': 'Ekstrak Vanila',
      'coffee': 'Kopi Hitam',
      'sweet': 'Pemanis',
      'traditional': 'Seduhan Tradisional',
      'panela': 'Gula Tebu',
      'whiskey': 'Sirup Rum Non-Alkohol',
    };

    for (final entry in dictionary.entries) {
      if (lower == entry.key) return entry.value;
    }
    if (lower.contains('espresso')) return 'Espresso';
    if (lower.contains('steamed milk')) return 'Susu Kukus';
    if (lower.contains('milk')) return 'Susu Segar';
    if (lower.contains('foam')) return 'Busa Susu';
    if (lower.contains('water')) return 'Air Panas';
    if (lower.contains('chocolate') || lower.contains('cocoa')) return 'Coklat';
    if (lower.contains('caramel')) return 'Sirup Karamel';
    if (lower.contains('cream')) return 'Krim Lembut';
    if (lower.contains('ice')) return 'Es Batu';
    if (lower.contains('sugar')) return 'Gula';
    return raw;
  }

  String _localizeDescription(
    String title,
    List<String> ingredients,
    String category,
  ) {
    final komp = ingredients.join(', ').toLowerCase();
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('latte')) {
      return 'Minuman kopi lembut dari perpaduan $komp dengan tekstur yang creamy dan seimbang.';
    }
    if (lowerTitle.contains('cappuccino')) {
      return 'Perpaduan klasik espresso dengan susu hangat dan lapisan busa susu tebal di bagian atas.';
    }
    if (lowerTitle.contains('americano') || lowerTitle.contains('black')) {
      return 'Seduhan kopi hitam dengan karakter rasa espresso yang tegas, bersih, dan aromatik.';
    }
    if (lowerTitle.contains('mocha') || lowerTitle.contains('mocaccino')) {
      return 'Kombinasi nikmat antara espresso pekat, coklat pilihan, dan susu hangat yang lembut.';
    }
    if (lowerTitle.contains('macchiato')) {
      return 'Minuman berbasis espresso dengan sentuhan susu lembut dan aroma manis yang khas.';
    }
    return 'Minuman $title pilihan yang diracik dari komposisi $komp dengan cita rasa seimbang.';
  }

  bool _isValidEntry(CoffeeItem item) {
    final lower = item.title.toLowerCase();
    if (lower.isEmpty ||
        lower == 'north signature brew' ||
        lower.contains('test') ||
        lower.contains('asd') ||
        item.title.length < 3) {
      return false;
    }
    return true;
  }

  static const List<CoffeeItem> _curatedFallbackCatalog = [
    CoffeeItem(
      id: 1,
      title: 'Caffe Mocha',
      description:
          'Perpaduan double espresso dengan saus coklat pekat dan susu kukus lembut.',
      ingredients: ['Double Espresso', 'Coklat Pekat', 'Susu Kukus'],
      image:
          'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=600',
      category: 'Kopi',
    ),
    CoffeeItem(
      id: 2,
      title: 'Coklat Hangat Spesial',
      description:
          'Minuman coklat hangat dengan susu segar dan taburan bubuk kakao.',
      ingredients: ['Coklat Pilihan', 'Susu Kukus', 'Vanila'],
      image:
          'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=600',
      category: 'Non-Kopi',
    ),
    CoffeeItem(
      id: 3,
      title: 'Citrus Berry Cooler',
      description:
          'Minuman segar perpaduan buah beri, perasan lemon, daun mint, dan air soda.',
      ingredients: ['Sari Buah Beri', 'Lemon Segar', 'Daun Mint', 'Air Soda'],
      image:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600',
      category: 'Minuman Segar',
    ),
  ];
}
