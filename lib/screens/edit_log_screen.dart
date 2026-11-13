import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_log.dart';
import '../providers/log_provider.dart';

/// Screen 5: Edit Coffee Log Screen
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
  late bool _isFavorite;

  static const List<String> _categories = [
    'Coffee',
    'Non-Coffee',
    'Mocktail',
    'Hot',
    'Iced',
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
    _titleController = TextEditingController(text: widget.log.coffeeTitle);
    _noteController = TextEditingController(text: widget.log.customNote);
    _selectedCategory = _categories.contains(widget.log.category)
        ? widget.log.category
        : 'Coffee';
    _selectedSweetness = _sweetnessOptions.contains(widget.log.sweetnessLevel)
        ? widget.log.sweetnessLevel
        : 'Normal';
    _selectedRating = widget.log.rating.clamp(1, 5);
    _isFavorite = widget.log.isTried;
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
      isTried: _isFavorite,
    );

    final success = await logProvider.updateCoffeeLog(updated);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${updated.coffeeTitle}" diperbarui'),
          backgroundColor: AppTheme.primaryEspresso,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            logProvider.errorMessage ?? 'Gagal memperbarui catatan',
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
          'Edit Catatan',
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
                          prefixIcon: Icon(Icons.local_cafe_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama minuman wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

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

                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Racikan / Rasa',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Catatan wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      ElevatedButton(
                        onPressed: isSubmitting ? null : _saveChanges,
                        child: Text(
                          isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan',
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
