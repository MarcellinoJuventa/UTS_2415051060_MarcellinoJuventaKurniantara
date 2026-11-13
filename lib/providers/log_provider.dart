import 'package:flutter/foundation.dart';
import '../models/coffee_log.dart';

/// Provider 2: LogProvider
/// Mengelola state jurnal racikan kopi pribadi (Brew Log) dari database Supabase:
/// loading, data, error, filter status (All / Tried / Wishlist), serta operasi CRUD.
class LogProvider extends ChangeNotifier {
  List<CoffeeLog> _logs = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _statusFilter = 'All'; // 'All', 'Tried', 'Wishlist'

  List<CoffeeLog> get logs => List.unmodifiable(_logs);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;

  List<CoffeeLog> get filteredLogs {
    if (_statusFilter == 'Tried') {
      return _logs.where((log) => log.isTried).toList();
    }
    if (_statusFilter == 'Wishlist') {
      return _logs.where((log) => !log.isTried).toList();
    }
    return List.unmodifiable(_logs);
  }

  int get triedCount => _logs.where((l) => l.isTried).length;
  int get wishlistCount => _logs.where((l) => !l.isTried).length;

  double get averageRating {
    if (_logs.isEmpty) return 0.0;
    final total = _logs.fold<int>(0, (sum, item) => sum + item.rating);
    return total / _logs.length;
  }

  bool isCoffeeLogged(int coffeeId) =>
      _logs.any((log) => log.coffeeId == coffeeId);

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  @protected
  void setLogsState(List<CoffeeLog> logs) {
    _logs = logs;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @protected
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @protected
  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  @protected
  void setError(String? message) {
    _errorMessage = message;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
