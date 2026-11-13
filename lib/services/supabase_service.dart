import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/coffee_log.dart';

/// Service 2: SupabaseService
/// Mengelola koneksi langsung ke backend database Supabase PostgreSQL (tabel `coffee_logs`)
/// untuk operasi CRUD (Create, Read, Update, Delete) menggunakan publishable anon key.
class SupabaseService {
  final http.Client _client;

  SupabaseService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'apikey': AppConfig.supabaseAnonKey,
        'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  String get _tableEndpoint =>
      '${AppConfig.supabaseRestUrl}/${AppConfig.coffeeLogsTable}';

  /// READ (SELECT * FROM coffee_logs ORDER BY created_at DESC)
  Future<List<CoffeeLog>> fetchLogs() async {
    try {
      final uri = Uri.parse('$_tableEndpoint?select=*&order=created_at.desc');
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(CoffeeLog.fromJson)
              .toList();
        }
        return [];
      } else {
        throw Exception(
          'Gagal memuat data dari Supabase (Status ${response.statusCode}): ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception(
        'Koneksi ke database Supabase timeout. Periksa jaringan internet Anda.',
      );
    } catch (e) {
      throw Exception('Error membaca database Supabase: $e');
    }
  }

  /// CREATE (INSERT INTO coffee_logs)
  Future<CoffeeLog> createLog(CoffeeLog log) async {
    try {
      final uri = Uri.parse(_tableEndpoint);
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(log.toInsertJson()),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return CoffeeLog.fromJson(decoded.first as Map<String, dynamic>);
        }
        return log;
      } else {
        throw Exception(
          'Gagal menyimpan catatan ke Supabase (Status ${response.statusCode}).',
        );
      }
    } on TimeoutException {
      throw Exception('Waktu koneksi habis saat menyimpan ke database.');
    } catch (e) {
      throw Exception('Error menyimpan data ke Supabase: $e');
    }
  }

  /// UPDATE (PATCH coffee_logs WHERE id = eq.<id>)
  Future<CoffeeLog> updateLog(CoffeeLog log) async {
    if (log.id == null) {
      throw Exception('ID catatan kopi tidak valid untuk diupdate.');
    }
    try {
      final uri = Uri.parse('$_tableEndpoint?id=eq.${log.id}');
      final response = await _client
          .patch(
            uri,
            headers: _headers,
            body: jsonEncode(log.toUpdateJson()),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return CoffeeLog.fromJson(decoded.first as Map<String, dynamic>);
        }
        return log;
      } else {
        throw Exception(
          'Gagal memperbarui data di Supabase (Status ${response.statusCode}).',
        );
      }
    } on TimeoutException {
      throw Exception('Waktu koneksi habis saat memperbarui database.');
    } catch (e) {
      throw Exception('Error memperbarui data di Supabase: $e');
    }
  }

  /// DELETE (DELETE FROM coffee_logs WHERE id = eq.<id>)
  Future<void> deleteLog(int id) async {
    try {
      final uri = Uri.parse('$_tableEndpoint?id=eq.$id');
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Gagal menghapus data dari Supabase (Status ${response.statusCode}).',
        );
      }
    } on TimeoutException {
      throw Exception('Waktu koneksi habis saat menghapus data dari database.');
    } catch (e) {
      throw Exception('Error menghapus data di Supabase: $e');
    }
  }
}
