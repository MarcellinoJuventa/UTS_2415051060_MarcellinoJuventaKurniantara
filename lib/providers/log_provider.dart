import 'package:flutter/foundation.dart';
import '../models/coffee_log.dart';
import '../repositories/log_repository.dart';

/// Provider 2: LogProvider
/// Manages Brew Log state from Supabase: loading, data, error, status filter, and CRUD.
class LogProvider extends ChangeNotifier {
  final LogRepository _repository;

  LogProvider({LogRepository? repository})
      : _repository = repository ?? LogRepository();

  List<CoffeeLog> _logs = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _statusFilter = 'All'; // 'All', 'Favorite', 'To Try'

  List<CoffeeLog> get logs => List.unmodifiable(_logs);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;

  List<CoffeeLog> get filteredLogs {
    if (_statusFilter == 'Favorite') {
      return _logs.where((log) => log.isTried).toList();
    }
    if (_statusFilter == 'To Try') {
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

  Future<void> fetchLogs() async {
    setLoading(true);
    try {
      final result = await _repository.getAllLogs();
      setLogsState(result);
    } catch (e) {
      setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> addCoffeeLog(CoffeeLog newLog) async {
    setSubmitting(true);
    try {
      final created = await _repository.addLog(newLog);
      _logs = [created, ..._logs];
      _errorMessage = null;
      setSubmitting(false);
      return true;
    } catch (e) {
      setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> updateCoffeeLog(CoffeeLog updatedLog) async {
    setSubmitting(true);
    try {
      final saved = await _repository.editLog(updatedLog);
      final index = _logs.indexWhere((item) => item.id == saved.id);
      if (index != -1) {
        final copy = List<CoffeeLog>.from(_logs);
        copy[index] = saved;
        _logs = copy;
      }
      _errorMessage = null;
      setSubmitting(false);
      return true;
    } catch (e) {
      setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deleteCoffeeLog(int id) async {
    setSubmitting(true);
    try {
      await _repository.removeLog(id);
      _logs = _logs.where((item) => item.id != id).toList();
      _errorMessage = null;
      setSubmitting(false);
      return true;
    } catch (e) {
      setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
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
