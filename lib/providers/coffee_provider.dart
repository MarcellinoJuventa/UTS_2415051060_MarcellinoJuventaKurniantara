import 'package:flutter/foundation.dart';
import '../models/coffee_item.dart';
import '../repositories/coffee_repository.dart';

/// Provider 1: CoffeeProvider
/// Manages drink menu state: loading, data, error, search, category filter, and favorites.
class CoffeeProvider extends ChangeNotifier {
  final CoffeeRepository _repository;

  CoffeeProvider({CoffeeRepository? repository})
      : _repository = repository ?? CoffeeRepository();

  List<CoffeeItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Coffee', 'Non-Coffee', 'Mocktail'
  final Set<int> _favoriteIds = {1, 2};

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

  List<CoffeeItem> get filteredItems {
    return _items.where((drink) {
      final matchesCategory = _selectedCategory == 'All' ||
          drink.category.toLowerCase() == _selectedCategory.toLowerCase();

      if (!matchesCategory) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase().trim();
      final inTitle = drink.title.toLowerCase().contains(query);
      final inDesc = drink.description.toLowerCase().contains(query);
      final inIngredients = drink.ingredients.any(
        (ing) => ing.toLowerCase().contains(query),
      );
      return inTitle || inDesc || inIngredients;
    }).toList();
  }

  List<CoffeeItem> get favoriteItems =>
      _items.where((item) => _favoriteIds.contains(item.id)).toList();

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
