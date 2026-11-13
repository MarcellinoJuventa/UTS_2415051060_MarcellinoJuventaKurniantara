import '../models/coffee_log.dart';
import '../services/supabase_service.dart';

/// Repository 2: LogRepository
/// Menjembatani LogProvider dengan SupabaseService untuk operasi CRUD database.
class LogRepository {
  final SupabaseService _supabaseService;

  LogRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  Future<List<CoffeeLog>> getAllLogs() => _supabaseService.fetchLogs();

  Future<CoffeeLog> addLog(CoffeeLog log) => _supabaseService.createLog(log);

  Future<CoffeeLog> editLog(CoffeeLog log) => _supabaseService.updateLog(log);

  Future<void> removeLog(int id) => _supabaseService.deleteLog(id);
}
