import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../models/coffee_log.dart';
import '../providers/coffee_provider.dart';
import '../providers/log_provider.dart';

/// Screen 4: Add / Create Coffee Log Screen
/// Otomatis mengisi Resep Bawaan dari menu yang dipilih (dan bisa diedit/dikustomisasi oleh user),
/// serta menyediakan kolom Catatan Pribadi.
class AddLogScreen extends StatefulWidget {
  final CoffeeItem? initialCoffee;

  const AddLogScreen({super.key, this.initialCoffee});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _recipeController;
  late final TextEditingController _noteController;

  CoffeeItem? _selectedCoffee;
  String _servingTemp = 'Hot'; // 'Hot' atau 'Ice'
  String _selectedSweetness = 'Less Sweet';
  int _selectedRating = 5;
  bool _isFavorite = true; // true = Favorite, false = Belum Dicoba

  static const List<String> _sweetnessOptions = [
    'No Sugar',
    'Less Sweet',
    'Normal',
    'Extra Sweet',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCoffee = widget.initialCoffee;
    _recipeController = TextEditingController(
      text: _selectedCoffee != null
          ? _selectedCoffee!.ingredients.join(', ')
          : '',
    );
    _noteController = TextEditingController();
    _applyDefaultServing(_selectedCoffee);
  }

  void _applyDefaultServing(CoffeeItem? coffee) {
    if (coffee != null) {
      final lowerTitle = coffee.title.toLowerCase();
      if (coffee.category == 'Mocktail' || lowerTitle.contains('iced')) {
        _servingTemp = 'Ice';
      } else {
        _servingTemp = 'Hot';
      }
    }
  }

  @override
  void dispose() {
    _recipeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_selectedCoffee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih menu minuman terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final coffee = _selectedCoffee!;
    final logProvider = context.read<LogProvider>();
    final combinedNote = CoffeeLog.encodeRecipeAndNote(
      recipe: _recipeController.text,
      note: _noteController.text,
    );

    final newLog = CoffeeLog(
      coffeeId: coffee.id,
      coffeeTitle: coffee.title,
      coffeeImage: coffee.image,
      category: _servingTemp,
      sweetnessLevel: _selectedSweetness,
      customNote: combinedNote,
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
    final menuItems = context.watch<CoffeeProvider>().allItems;
    if (_selectedCoffee == null && menuItems.isNotEmpty) {
      _selectedCoffee = menuItems.first;
      _recipeController.text = _selectedCoffee!.ingredients.join(', ');
    }
    final coffee = _selectedCoffee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah ke Brew Log',
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
                      // Jika dibuka tanpa memilih dari menu, sediakan pemilih menu
                      if (widget.initialCoffee == null &&
                          menuItems.isNotEmpty) ...[
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: coffee?.id,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Menu',
                            prefixIcon: Icon(Icons.local_cafe_outlined),
                          ),
                          items: menuItems
                              .map(
                                (item) => DropdownMenuItem<int>(
                                  value: item.id,
                                  child: Text(
                                    '${item.title} (${item.category})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (selectedId) {
                            if (selectedId == null) return;
                            final found = menuItems.firstWhere(
                              (e) => e.id == selectedId,
                              orElse: () => menuItems.first,
                            );
                            setState(() {
                              _selectedCoffee = found;
                              _recipeController.text =
                                  found.ingredients.join(', ');
                              _applyDefaultServing(found);
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Kartu Info Menu yang Sudah Fix (Nama & Jenis)
                      if (coffee != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.creamBackground,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  coffee.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 60,
                                    height: 60,
                                    color: AppTheme.softLatte,
                                    child: const Icon(Icons.local_cafe_rounded),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.softLatte,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        coffee.category,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentRoast,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      coffee.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryEspresso,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Penyajian: Hot atau Ice
                      const Text(
                        'Penyajian',
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
                            icon: Icon(Icons.local_fire_department_outlined),
                            label: Text('Hot'),
                          ),
                          ButtonSegment(
                            value: 'Ice',
                            icon: Icon(Icons.ac_unit_rounded),
                            label: Text('Ice'),
                          ),
                        ],
                        selected: {_servingTemp},
                        onSelectionChanged: (sel) {
                          setState(() => _servingTemp = sel.first);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tingkat Kemanisan
                      DropdownButtonFormField<String>(
                        isExpanded: true,
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

                      // Resep Menu (Otomatis terisi dari menu, dan bisa diedit user)
                      TextFormField(
                        controller: _recipeController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Resep / Takaran Racikan (Bisa Diedit)',
                          hintText:
                              'Contoh: Double Espresso, Oat Milk, Vanilla Syrup',
                          prefixIcon: Icon(Icons.science_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Resep racikan wajib diisi';
                          }
                          return null;
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

                      // Catatan Pribadi
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Pribadi',
                          hintText: 'Tulis kesan rasa atau catatan tambahan...',
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
                        onPressed: isSubmitting ? null : _submitForm,
                        child: Text(
                          isSubmitting ? 'Menyimpan...' : 'Simpan ke Brew Log',
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
