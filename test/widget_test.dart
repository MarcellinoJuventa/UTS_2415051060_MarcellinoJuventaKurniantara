import 'package:flutter_test/flutter_test.dart';
import 'package:north_coffee_bar/config/app_config.dart';
import 'package:north_coffee_bar/models/coffee_item.dart';
import 'package:north_coffee_bar/models/coffee_log.dart';

void main() {
  test('CoffeeItem JSON parsing and model validation works properly', () {
    final item = CoffeeItem.fromJson({
      'id': 10,
      'title': 'North Iced Latte',
      'description': 'Double shot espresso with cold fresh milk.',
      'ingredients': ['Espresso', 'Fresh Milk', 'Ice'],
      'image': 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600',
      'category': 'Iced',
    });

    expect(item.id, 10);
    expect(item.title, 'North Iced Latte');
    expect(item.category, 'Iced');
    expect(item.ingredients.length, 3);
  });

  test('CoffeeLog model serialization for Supabase CRUD works properly', () {
    final log = CoffeeLog(
      id: 1,
      coffeeId: 10,
      coffeeTitle: 'North Cortado',
      coffeeImage: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600',
      category: 'Hot',
      sweetnessLevel: 'Less Sweet',
      customNote: 'Rasio 1:1 espresso dan warm oat milk.',
      rating: 5,
      isTried: true,
      createdAt: DateTime(2026, 11, 13),
    );

    final insertPayload = log.toInsertJson();
    expect(insertPayload['coffee_title'], 'North Cortado');
    expect(insertPayload['rating'], 5);
    expect(AppConfig.studentNim, '2415051060');
  });
}
