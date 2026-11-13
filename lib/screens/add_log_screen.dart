import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/coffee_item.dart';
import '../models/coffee_log.dart';
import '../providers/coffee_provider.dart';
import '../providers/log_provider.dart';

/// Screen 4: Add to Brew Log Screen (Full English)
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
  String _servingTemp = 'Hot'; // 'Hot' or 'Iced'
  String _selectedSweetness = 'Less Sweet';
  int _selectedRating = 5;
  bool _isFavorite = true; // true = Favorite, false = To Try

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
        _servingTemp = 'Iced';
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
          content: Text('Please select a drink first'),
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
          content: Text('"${newLog.coffeeTitle}" saved to Brew Log'),
          backgroundColor: AppTheme.primaryEspresso,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            logProvider.errorMessage ?? 'Failed to save log',
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
          'Add to Brew Log',
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
                      if (widget.initialCoffee == null &&
                          menuItems.isNotEmpty) ...[
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: coffee?.id,
                          decoration: const InputDecoration(
                            labelText: 'Select Drink',
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

                      const Text(
                        'Serving',
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
                            value: 'Iced',
                            icon: Icon(Icons.ac_unit_rounded),
                            label: Text('Iced'),
                          ),
                        ],
                        selected: {_servingTemp},
                        onSelectionChanged: (sel) {
                          setState(() => _servingTemp = sel.first);
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedSweetness,
                        decoration: const InputDecoration(
                          labelText: 'Sweetness Level',
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

                      TextFormField(
                        controller: _recipeController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Recipe / Ingredients (Editable)',
                          hintText: 'e.g. Double Espresso, Oat Milk, Vanilla',
                          prefixIcon: Icon(Icons.science_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Recipe is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Status',
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
                            label: Text('To Try'),
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
                          labelText: 'Personal Notes',
                          hintText: 'Write your tasting notes or adjustments...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Personal note is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      ElevatedButton(
                        onPressed: isSubmitting ? null : _submitForm,
                        child: Text(
                          isSubmitting ? 'Saving...' : 'Save to Brew Log',
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
