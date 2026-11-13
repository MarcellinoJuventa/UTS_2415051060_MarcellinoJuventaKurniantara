import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_log.dart';
import '../providers/log_provider.dart';

/// Screen 5: Edit Coffee Log Screen
/// Menerima objek `CoffeeLog` melalui parameter konstruktor (passing data antar-screen)
/// dan memperbarui catatan di tabel `coffee_logs` Supabase (Operasi UPDATE).
class EditLogScreen extends StatefulWidget {
  final CoffeeLog log;

  const EditLogScreen({super.key, required this.log});

  @override
  State<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late String _selectedSweetness;
  late int _selectedRating;
  late bool _isTried;

  static const List<String> _sweetnessOptions = [
    'No Sugar (0%)',
    'Less Sweet (50%)',
    'Normal (100%)',
    'Extra Sweet (120%)',
    'No Sugar',
    'Less Sweet',
    'Normal',
    'Extra Sweet',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log.coffeeTitle);
    _noteController = TextEditingController(text: widget.log.customNote);
    _selectedCategory =
        widget.log.category.toLowerCase() == 'iced' ? 'Iced' : 'Hot';
    _selectedSweetness = _sweetnessOptions.contains(widget.log.sweetnessLevel)
        ? widget.log.sweetnessLevel
        : 'Normal (100%)';
    _selectedRating = widget.log.rating.clamp(1, 5);
    _isTried = widget.log.isTried;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final logProvider = context.read<LogProvider>();
    final updated = widget.log.copyWith(
      coffeeTitle: _titleController.text.trim(),
      category: _selectedCategory,
      sweetnessLevel: _selectedSweetness,
      customNote: _noteController.text.trim(),
      rating: _selectedRating,
      isTried: _isTried,
    );

    final success = await logProvider.updateCoffeeLog(updated);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perubahan pada "${updated.coffeeTitle}" berhasil disimpan ke Supabase!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            logProvider.errorMessage ?? 'Gagal memperbarui catatan di Supabase.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<LogProvider>().isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Catatan Racikan Kopi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.log.coffeeImage,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 64,
                                height: 64,
                                color: AppTheme.softLatte,
                                child: const Icon(
                                  Icons.coffee_rounded,
                                  color: AppTheme.primaryEspresso,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID Catatan Database: #${widget.log.id ?? "-"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Perbarui Detail Racikan & Evaluasi Rasa',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryEspresso,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),

                      // Nama Minuman
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Minuman Kopi *',
                          prefixIcon: Icon(Icons.coffee_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama minuman kopi tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama minuman minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kategori (Hot / Iced)
                      const Text(
                        'Kategori Penyajian',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'Hot',
                            icon: Icon(Icons.local_fire_department_rounded),
                            label: Text('Hot Coffee'),
                          ),
                          ButtonSegment(
                            value: 'Iced',
                            icon: Icon(Icons.ac_unit_rounded),
                            label: Text('Iced Coffee'),
                          ),
                        ],
                        selected: {_selectedCategory},
                        onSelectionChanged: (selection) {
                          setState(() => _selectedCategory = selection.first);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tingkat Kemanisan
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSweetness,
                        decoration: const InputDecoration(
                          labelText: 'Tingkat Kemanisan',
                          prefixIcon: Icon(Icons.water_drop_outlined),
                        ),
                        items: _sweetnessOptions
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt,
                                child: Text(opt),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSweetness = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Rating Bintang
                      const Text(
                        'Rating Karakter Rasa (1 - 5 Bintang)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return IconButton(
                            onPressed: () {
                              setState(() => _selectedRating = starValue);
                            },
                            icon: Icon(
                              starValue <= _selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber.shade700,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),

                      // Status
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.creamBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            _isTried
                                ? 'Status: Sudah Dicoba / Diracik'
                                : 'Status: Wishlist (Ingin Dicoba)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          value: _isTried,
                          activeThumbColor: AppTheme.primaryEspresso,
                          onChanged: (val) => setState(() => _isTried = val),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Catatan Racikan
                      TextFormField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Racikan / Tasting Note *',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Catatan racikan tidak boleh kosong';
                          }
                          if (value.trim().length < 10) {
                            return 'Catatan racikan minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _saveChanges,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          isSubmitting
                              ? 'Menyimpan Perubahan...'
                              : 'Simpan Perubahan (Update Supabase)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
