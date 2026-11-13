import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../models/coffee_log.dart';
import '../providers/log_provider.dart';

/// Screen 4: Add / Create Coffee Log Screen
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

  String _selectedCategory = 'Coffee';
  String _selectedSweetness = 'Less Sweet';
  int _selectedRating = 5;
  bool _isFavorite = true; // true = Favorite, false = Belum Dicoba

  static const List<String> _categories = [
    'Coffee',
    'Non-Coffee',
    'Mocktail',
  ];

  static const List<String> _sweetnessOptions = [
    'No Sugar',
    'Less Sweet',
    'Normal',
    'Extra Sweet',
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
          ? 'Komposisi: ${coffee.ingredients.join(", ")}. Catatan tambahan: '
          : '',
    );
    if (coffee != null && _categories.contains(coffee.category)) {
      _selectedCategory = coffee.category;
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
      isTried: _isFavorite,
      createdAt: DateTime.now(),
    );

    final success = await logProvider.addCoffeeLog(newLog);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${newLog.coffeeTitle}" berhasil disimpan'),
          backgroundColor: AppTheme.primaryEspresso,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            logProvider.errorMessage ?? 'Gagal menyimpan catatan',
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
          'Tambah Catatan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Minuman',
                          hintText: 'Contoh: Caramel Latte / Berry Cooler',
                          prefixIcon: Icon(Icons.local_cafe_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama minuman wajib diisi';
                          }
                          if (value.trim().length < 3) {
                            return 'Minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kategori
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
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

                      // Status: Favorite vs Belum Dicoba
                      const Text(
                        'Status Catatan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            icon: Icon(Icons.favorite_border_rounded),
                            label: Text('Favorite'),
                          ),
                          ButtonSegment(
                            value: false,
                            icon: Icon(Icons.schedule_rounded),
                            label: Text('Belum Dicoba'),
                          ),
                        ],
                        selected: {_isFavorite},
                        onSelectionChanged: (sel) {
                          setState(() => _isFavorite = sel.first);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Rating Bintang
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppTheme.primaryEspresso,
                        ),
                      ),
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
                              size: 30,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),

                      // Catatan
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Racikan / Rasa',
                          hintText: 'Tulis catatan rasa atau takaran...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Catatan wajib diisi';
                          }
                          if (value.trim().length < 5) {
                            return 'Minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      ElevatedButton(
                        onPressed: isSubmitting ? null : _submitForm,
                        child: Text(
                          isSubmitting ? 'Menyimpan...' : 'Simpan Catatan',
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
