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

/// Screen 6: Brew Log Screen
class SavedLogsScreen extends StatelessWidget {
  const SavedLogsScreen({super.key});

  static const List<String> _filters = [
    'Semua',
    'Favorite',
    'Belum Dicoba',
  ];

  Future<void> _confirmAndDelete(BuildContext context, CoffeeLog log) async {
    if (log.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text(
          'Hapus "${log.coffeeTitle}" dari Brew Log?',
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
            child: const Text('Hapus'),
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
              ? 'Catatan "${log.coffeeTitle}" dihapus'
              : (provider.errorMessage ?? 'Gagal menghapus catatan'),
        ),
        backgroundColor:
            success ? AppTheme.primaryEspresso : Colors.red.shade700,
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
        title: const Text(
          'Brew Log',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            onPressed: () => context.read<LogProvider>().fetchLogs(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter: Semua, Favorite, Belum Dicoba
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = logProvider.statusFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => logProvider.setStatusFilter(filter),
                    ),
                  );
                }).toList(),
              ),
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
        message: 'Memuat catatan...',
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
        icon: Icons.bookmark_border_rounded,
        title: 'Belum Ada Catatan',
        subtitle: 'Simpan minuman dari menu atau tambahkan catatan baru.',
        actionLabel: 'Tambah Catatan',
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
        mainAxisExtent: 245,
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
                      'Status "${log.coffeeTitle}" diubah ke ${updated.isTried ? "Favorite" : "Belum Dicoba"}',
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
