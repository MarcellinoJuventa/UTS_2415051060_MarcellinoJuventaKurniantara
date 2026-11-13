import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_log.dart';
import '../providers/log_provider.dart';
import '../widgets/log_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/state_view_widget.dart';
import 'add_log_screen.dart';
import 'edit_log_screen.dart';

/// Screen 6: Saved Logs / Brew Log Screen
/// Menampilkan daftar catatan racikan kopi dari database Supabase (READ),
/// mendukung filter status, navigasi ke EditLogScreen (UPDATE), serta
/// penghapusan data dengan Confirmation AlertDialog (DELETE).
class SavedLogsScreen extends StatelessWidget {
  const SavedLogsScreen({super.key});

  Future<void> _confirmAndDelete(BuildContext context, CoffeeLog log) async {
    if (log.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Expanded(child: Text('Konfirmasi Hapus Catatan')),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${log.coffeeTitle}" dari database Supabase? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<LogProvider>();
    final success = await provider.deleteCoffeeLog(log.id!);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Catatan "${log.coffeeTitle}" berhasil dihapus dari Supabase.'
              : (provider.errorMessage ?? 'Gagal menghapus catatan.'),
        ),
        backgroundColor: success ? AppTheme.primaryEspresso : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<LogProvider>();
    final logs = logProvider.filteredLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              'North Brew Log (Supabase)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan Data Database',
            onPressed: () => context.read<LogProvider>().fetchLogs(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Tambah Catatan Baru',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddLogScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar status catatan
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Filter Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.primaryEspresso,
                  ),
                ),
                ChoiceChip(
                  label: Text('Semua (${logProvider.logs.length})'),
                  selected: logProvider.statusFilter == 'All',
                  onSelected: (_) => logProvider.setStatusFilter('All'),
                ),
                ChoiceChip(
                  label: Text('Sudah Dicoba (${logProvider.triedCount})'),
                  selected: logProvider.statusFilter == 'Tried',
                  onSelected: (_) => logProvider.setStatusFilter('Tried'),
                ),
                ChoiceChip(
                  label: Text('Wishlist (${logProvider.wishlistCount})'),
                  selected: logProvider.statusFilter == 'Wishlist',
                  onSelected: (_) => logProvider.setStatusFilter('Wishlist'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildBody(context, logProvider, logs),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LogProvider provider,
    List<CoffeeLog> logs,
  ) {
    if (provider.isLoading) {
      return const LoadingStateView(
        message: 'Memuat catatan racikan kopi dari database Supabase...',
      );
    }

    if (provider.errorMessage != null && provider.logs.isEmpty) {
      return ErrorStateView(
        message: provider.errorMessage!,
        onRetry: provider.fetchLogs,
      );
    }

    if (logs.isEmpty) {
      return EmptyStateView(
        icon: Icons.auto_stories_outlined,
        title: 'Belum Ada Catatan Racikan Kopi',
        subtitle:
            'Tambahkan racikan kopi favorit Anda dari katalog bar atau buat catatan baru ke Supabase.',
        actionLabel: 'Tambah Catatan Kopi',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddLogScreen()),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchLogs,
      child: ResponsiveCollectionView(
        itemCount: logs.length,
        mainAxisExtent: 235,
        itemBuilder: (context, index, _) {
          final log = logs[index];
          return LogCard(
            log: log,
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditLogScreen(log: log)),
              );
            },
            onDelete: () => _confirmAndDelete(context, log),
            onToggleStatus: () async {
              final updated = log.copyWith(isTried: !log.isTried);
              final ok = await provider.updateCoffeeLog(updated);
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Status "${log.coffeeTitle}" diubah menjadi ${updated.isTried ? "Sudah Dicoba" : "Wishlist"}.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
