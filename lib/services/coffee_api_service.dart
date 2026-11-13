import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/coffee_item.dart';

/// Service 1: CoffeeApiService
/// Fetches drink catalog from SampleAPIs Coffee & TheCocktailDB Public REST API.
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

      // 1. Parse Hot Coffee -> 'Coffee'
      if (hotRes != null && hotRes.statusCode == 200) {
        final decoded = jsonDecode(hotRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final coffee =
                  CoffeeItem.fromJson(item, defaultCategory: 'Coffee');
              if (_isValidEntry(coffee)) {
                catalog.add(
                  CoffeeItem(
                    id: coffee.id,
                    title: coffee.title,
                    description: coffee.description,
                    ingredients: coffee.ingredients,
                    image: coffee.image,
                    category: 'Coffee',
                  ),
                );
              }
            }
          }
        }
      }

      // 2. Parse Iced Coffee -> 'Coffee'
      if (icedRes != null && icedRes.statusCode == 200) {
        final decoded = jsonDecode(icedRes.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final parsed =
                  CoffeeItem.fromJson(item, defaultCategory: 'Coffee');
              if (_isValidEntry(parsed)) {
                final uniqueId =
                    parsed.id < 1000 ? parsed.id + 1000 : parsed.id;
                catalog.add(
                  CoffeeItem(
                    id: uniqueId,
                    title: parsed.title,
                    description: parsed.description,
                    ingredients: parsed.ingredients,
                    image: parsed.image,
                    category: 'Coffee',
                  ),
                );
              }
            }
          }
        }
      }

      // 3. Parse Non-Coffee (TheCocktailDB c=Cocoa) -> 'Non-Coffee'
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
                        'Rich and velvety cocoa blend crafted with steamed milk and subtle vanilla notes.',
                    ingredients: const [
                      'Premium Cocoa',
                      'Steamed Milk',
                      'Vanilla Cream',
                    ],
                    image: image,
                    category: 'Non-Coffee',
                  ),
                );
              }
            }
          }
        }
      }

      // 4. Parse Mocktail (TheCocktailDB a=Non_Alcoholic) -> 'Mocktail'
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
                        'Refreshing non-alcoholic bar mocktail crafted with fresh fruit infusion, botanical syrup, and ice.',
                    ingredients: const [
                      'Fruit Infusion',
                      'Botanical Syrup',
                      'Sparkling Water',
                      'Crystal Ice',
                    ],
                    image: image,
                    category: 'Mocktail',
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
      throw Exception('Failed to load drink menu: $e');
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
          'Rich double espresso blended with dark chocolate sauce and velvety steamed milk.',
      ingredients: ['Double Espresso', 'Dark Chocolate', 'Steamed Milk'],
      image:
          'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=600',
      category: 'Coffee',
    ),
    CoffeeItem(
      id: 2,
      title: 'Signature Hot Chocolate',
      description:
          'Warm artisan cocoa crafted with fresh milk and dusted with dark cocoa powder.',
      ingredients: ['Dark Cocoa', 'Steamed Milk', 'Vanilla'],
      image:
          'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=600',
      category: 'Non-Coffee',
    ),
    CoffeeItem(
      id: 3,
      title: 'Citrus Berry Cooler',
      description:
          'Refreshing mocktail combining mixed berries, fresh lemon juice, mint leaves, and sparkling water.',
      ingredients: ['Mixed Berries', 'Fresh Lemon', 'Mint', 'Sparkling Water'],
      image:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600',
      category: 'Mocktail',
    ),
  ];
}
