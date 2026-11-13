import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../models/coffee_log.dart';
import '../providers/log_provider.dart';

/// Screen 4: Add / Create Coffee Log Screen
/// Menampilkan Form dengan validasi untuk menyimpan racikan/catatan kopi baru
/// ke tabel `coffee_logs` di database Supabase (Operasi CREATE).
class AddLogScreen extends StatefulWidget {
  final CoffeeItem? initialCoffee;

  const AddLogScreen({super.key, this.initialCoffee});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _imageController;

  String _selectedCategory = 'Hot';
  String _selectedSweetness = 'Less Sweet';
  int _selectedRating = 5;
  bool _isTried = true;

  static const List<String> _sweetnessOptions = [
    'No Sugar (0%)',
    'Less Sweet (50%)',
    'Normal (100%)',
    'Extra Sweet (120%)',
  ];

  @override
  void initState() {
    super.initState();
    final coffee = widget.initialCoffee;
    _titleController = TextEditingController(text: coffee?.title ?? '');
    _imageController = TextEditingController(
      text: coffee?.image ??
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600',
    );
    _noteController = TextEditingController(
      text: coffee != null
          ? 'Komposisi dasar: ${coffee.ingredients.join(", ")}. Tambahan catatan barista: '
          : '',
    );
    if (coffee != null) {
      _selectedCategory =
          coffee.category.toLowerCase() == 'iced' ? 'Iced' : 'Hot';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi seluruh kolom form dengan benar.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final logProvider = context.read<LogProvider>();
    final newLog = CoffeeLog(
      coffeeId: widget.initialCoffee?.id ??
          DateTime.now().millisecondsSinceEpoch % 100000,
      coffeeTitle: _titleController.text.trim(),
      coffeeImage: _imageController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600'
          : _imageController.text.trim(),
      category: _selectedCategory,
      sweetnessLevel: _selectedSweetness,
      customNote: _noteController.text.trim(),
      rating: _selectedRating,
      isTried: _isTried,
      createdAt: DateTime.now(),
    );

    final success = await logProvider.addCoffeeLog(newLog);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil menyimpan "${newLog.coffeeTitle}" ke database Supabase!',
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
            logProvider.errorMessage ?? 'Gagal menyimpan data ke Supabase.',
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
          'Tambah Catatan Brew Log',
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
                      const Text(
                        'Form Racikan & Catatan Kopi Bar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Simpan resep kustom, tingkat kemanisan, dan evaluasi rasa ke Supabase.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Divider(height: 28),

                      // Nama Minuman Kopi
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Minuman Kopi *',
                          hintText: 'Contoh: North Oat Cortado / Iced Americano',
                          prefixIcon: Icon(Icons.coffee_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama minuman kopi wajib diisi';
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
                        'Kategori Penyajian Bar',
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
                          setState(() {
                            _selectedCategory = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tingkat Kemanisan (Dropdown)
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSweetness,
                        decoration: const InputDecoration(
                          labelText: 'Tingkat Kemanisan (Sweetness Level)',
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

                      // Rating Bintang (1 - 5)
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

                      // Status sudah dicoba / wishlist
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
                          subtitle: Text(
                            _isTried
                                ? 'Minuman ini sudah pernah Anda cicipi di bar'
                                : 'Disimpan sebagai daftar rencana kopi yang ingin dicoba',
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _isTried,
                          activeThumbColor: AppTheme.primaryEspresso,
                          onChanged: (val) => setState(() => _isTried = val),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Catatan Racikan Barista (Wajib & tervalidasi)
                      TextFormField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Racikan / Tasting Note *',
                          hintText:
                              'Tuliskan takaran shot espresso, jenis susu, atau kesan rasa...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Catatan racikan wajib diisi';
                          }
                          if (value.trim().length < 10) {
                            return 'Catatan racikan minimal 10 karakter agar informatif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // URL Gambar (Opsional)
                      TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'URL Foto Minuman (Opsional)',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Submit
                      ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _submitForm,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          isSubmitting
                              ? 'Menyimpan ke Supabase...'
                              : 'Simpan ke Brew Log (Supabase)',
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
