import '../models/coffee_item.dart';
import '../services/coffee_api_service.dart';

/// Repository 1: CoffeeRepository
/// Menjembatani CoffeeProvider dengan CoffeeApiService sesuai pola arsitektur:
/// UI -> Provider -> Repository -> Service -> REST API
class CoffeeRepository {
  final CoffeeApiService _apiService;

  CoffeeRepository({CoffeeApiService? apiService})
      : _apiService = apiService ?? CoffeeApiService();

  Future<List<CoffeeItem>> getCoffeeCatalog() async {
    return _apiService.fetchAllCoffeeDrinks();
  }
}
