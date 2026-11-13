import 'package:flutter/foundation.dart';
import '../models/coffee_item.dart';
import '../repositories/coffee_repository.dart';

/// Provider 1: CoffeeProvider
/// Mengelola state katalog menu kopi bar (loading, data, error, search query,
/// filter kategori Hot/Iced, dan shared state daftar kopi favorit/bookmark).
class CoffeeProvider extends ChangeNotifier {
  final CoffeeRepository _repository;

  CoffeeProvider({CoffeeRepository? repository})
      : _repository = repository ?? CoffeeRepository();

  List<CoffeeItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Hot', 'Iced'
  final Set<int> _favoriteIds = {1, 2};

  /// Mengambil data katalog minuman kopi dari REST API melalui CoffeeRepository
  Future<void> fetchCoffeeCatalog() async {
    setLoadingState(true);
    try {
      final result = await _repository.getCoffeeCatalog();
      setDataState(result);
    } catch (e) {
      setErrorState(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  List<CoffeeItem> get allItems => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  /// Daftar kopi hasil filter pencarian & kategori (Hot / Iced)
  List<CoffeeItem> get filteredItems {
    return _items.where((coffee) {
      final matchesCategory = _selectedCategory == 'All' ||
          coffee.category.toLowerCase() == _selectedCategory.toLowerCase();

      if (!matchesCategory) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase().trim();
      final inTitle = coffee.title.toLowerCase().contains(query);
      final inDesc = coffee.description.toLowerCase().contains(query);
      final inIngredients = coffee.ingredients.any(
        (ing) => ing.toLowerCase().contains(query),
      );
      return inTitle || inDesc || inIngredients;
    }).toList();
  }

  List<CoffeeItem> get favoriteItems =>
      _items.where((item) => _favoriteIds.contains(item.id)).toList();

  int get hotCoffeeCount =>
      _items.where((c) => c.category.toLowerCase() == 'hot').length;

  int get icedCoffeeCount =>
      _items.where((c) => c.category.toLowerCase() == 'iced').length;

  bool isFavorite(int coffeeId) => _favoriteIds.contains(coffeeId);

  void toggleFavorite(int coffeeId) {
    if (_favoriteIds.contains(coffeeId)) {
      _favoriteIds.remove(coffeeId);
    } else {
      _favoriteIds.add(coffeeId);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  @protected
  void setLoadingState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @protected
  void setDataState(List<CoffeeItem> items) {
    _items = items;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @protected
  void setErrorState(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
