import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/coffee_item.dart';

/// Service 1: CoffeeApiService
/// Melakukan HTTP GET ke public REST API SampleAPIs Coffee (/coffee/hot dan /coffee/iced)
/// dan mengonversi JSON response menjadi `List<CoffeeItem>`.
class CoffeeApiService {
  final http.Client _client;

  CoffeeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<CoffeeItem>> fetchAllCoffeeDrinks() async {
    try {
      final responses = await Future.wait([
        _client
            .get(Uri.parse(AppConfig.hotCoffeeApiUrl))
            .timeout(const Duration(seconds: 12)),
        _client
            .get(Uri.parse(AppConfig.icedCoffeeApiUrl))
            .timeout(const Duration(seconds: 12)),
      ]);

      final hotResponse = responses[0];
      final icedResponse = responses[1];

      if (hotResponse.statusCode != 200 && icedResponse.statusCode != 200) {
        throw Exception(
          'Gagal memuat katalog kopi dari REST API (Status ${hotResponse.statusCode}).',
        );
      }

      final List<CoffeeItem> combined = [];

      if (hotResponse.statusCode == 200) {
        final decodedHot = jsonDecode(hotResponse.body);
        if (decodedHot is List) {
          for (final item in decodedHot) {
            if (item is Map<String, dynamic>) {
              final coffee = CoffeeItem.fromJson(item, defaultCategory: 'Hot');
              if (_isValidCoffeeEntry(coffee)) {
                combined.add(coffee);
              }
            }
          }
        }
      }

      if (icedResponse.statusCode == 200) {
        final decodedIced = jsonDecode(icedResponse.body);
        if (decodedIced is List) {
          for (final item in decodedIced) {
            if (item is Map<String, dynamic>) {
              final parsed = CoffeeItem.fromJson(item, defaultCategory: 'Iced');
              if (_isValidCoffeeEntry(parsed)) {
                // Pastikan ID unik saat digabung dengan Hot Coffee
                final uniqueId = parsed.id < 1000 ? parsed.id + 1000 : parsed.id;
                combined.add(
                  CoffeeItem(
                    id: uniqueId,
                    title: parsed.title,
                    description: parsed.description,
                    ingredients: parsed.ingredients,
                    image: parsed.image,
                    category: 'Iced',
                  ),
                );
              }
            }
          }
        }
      }

      if (combined.isEmpty) {
        return _curatedFallbackCatalog;
      }

      return combined;
    } on TimeoutException {
      throw Exception(
        'Koneksi ke server katalog REST API melewati batas waktu (timeout). Periksa koneksi internet Anda.',
      );
    } catch (e) {
      throw Exception('Terjadi kendala saat mengambil data REST API: $e');
    }
  }

  bool _isValidCoffeeEntry(CoffeeItem item) {
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
          'Perpaduan rich double espresso dengan saus dark chocolate hangat dan steamed milk lembut.',
      ingredients: ['Double Espresso', 'Dark Chocolate', 'Steamed Milk', 'Cocoa Dust'],
      image: 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=600',
      category: 'Hot',
    ),
    CoffeeItem(
      id: 2,
      title: 'Iced Caramel Macchiato',
      description:
          'Susu segar dingin dengan sirup vanila, dituang espresso shot di atasnya dan saus karamel.',
      ingredients: ['Espresso Shot', 'Cold Milk', 'Vanilla Syrup', 'Caramel Drizzle', 'Ice'],
      image: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600',
      category: 'Iced',
    ),
  ];
}
