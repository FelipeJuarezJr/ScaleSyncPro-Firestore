import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/theme.dart';

class AddExpenseModal extends StatefulWidget {
  final Expense? expense;

  const AddExpenseModal({super.key, this.expense});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _expenseService = ExpenseService();

  late String _selectedItemType;
  late String _selectedFoodState;
  late String _selectedAmountType;
  late TextEditingController _amountValueController;
  late TextEditingController _supplierController;
  late TextEditingController _costController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late String _selectedCurrency;
  
  bool _isSaving = false;

  final List<String> _itemTypes = [
    'Rats',
    'Mice',
    'Crickets',
    'Mealworms',
    'Roaches',
    'Bedding',
    'Supplements',
    'Medicine',
    'Equipment',
    'Other'
  ];

  final List<String> _foodStates = ['Dried', 'Fresh', 'Frozen', 'Live', 'N/A'];
  final List<String> _amountTypes = ['Quantity', 'Weight'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'CAD', 'MXN'];

  @override
  void initState() {
    super.initState();
    final exp = widget.expense;
    _selectedItemType = exp?.itemType ?? _itemTypes.first;
    _selectedFoodState = exp?.foodState ?? _foodStates.first;
    _selectedAmountType = exp?.amountType ?? _amountTypes.first;
    _amountValueController = TextEditingController(
      text: exp != null ? (exp.amountValue == exp.amountValue.toInt() ? exp.amountValue.toInt().toString() : exp.amountValue.toString()) : '',
    );
    _supplierController = TextEditingController(text: exp?.supplier ?? '');
    _costController = TextEditingController(
      text: exp != null ? (exp.cost == exp.cost.toInt() ? exp.cost.toInt().toString() : exp.cost.toString()) : '',
    );
    _descriptionController = TextEditingController(text: exp?.description ?? '');
    _notesController = TextEditingController(text: exp?.notes ?? '');
    _selectedCurrency = exp?.currency ?? _currencies.first;
  }

  @override
  void dispose() {
    _amountValueController.dispose();
    _supplierController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final amount = double.tryParse(_amountValueController.text) ?? 0.0;
      final cost = double.tryParse(_costController.text) ?? 0.0;

      final expense = Expense(
        id: widget.expense?.id,
        itemType: _selectedItemType,
        foodState: _selectedFoodState,
        amountType: _selectedAmountType,
        amountValue: amount,
        supplier: _supplierController.text.trim(),
        cost: cost,
        currency: _selectedCurrency,
        date: widget.expense?.date ?? DateTime.now(),
        description: _selectedItemType == 'Other' ? _descriptionController.text.trim() : '',
        notes: _notesController.text.trim(),
      );

      if (widget.expense != null) {
        await _expenseService.updateExpense(widget.expense!.id!, expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _expenseService.addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense logged successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving expense: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save expense: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteExpense() async {
    if (widget.expense?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.bgSecondary : Colors.white,
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense record? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _expenseService.deleteExpense(widget.expense!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete expense: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerBgColor = isDark ? const Color(0xFF0F5132) : const Color(0xFF2C5530);
    const headerTextColor = Colors.white;

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        side: isDark ? const BorderSide(color: AppTheme.borderColor) : BorderSide.none,
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar matching user's reference
            Container(
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusLg),
                  topRight: Radius.circular(AppTheme.borderRadiusLg),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.expense != null ? 'Edit food/expense' : 'Add food',
                      style: const TextStyle(
                        color: headerTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: headerTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: headerTextColor),
                    onPressed: _isSaving ? null : _saveExpense,
                  ),
                ],
              ),
            ),

            // Form Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type of food Dropdown
                      const Text(
                        'Type of food / supply',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedItemType,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _itemTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedItemType = val;
                              // Auto N/A for non-food items
                              if (val == 'Bedding' || val == 'Equipment' || val == 'Medicine') {
                                _selectedFoodState = 'N/A';
                              } else if (_selectedFoodState == 'N/A') {
                                _selectedFoodState = 'Dried';
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      if (_selectedItemType == 'Other') ...[
                        const Text(
                          'Items purchased / description',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Enter description of items purchased...',
                          ),
                          validator: (val) {
                            if (_selectedItemType == 'Other' && (val == null || val.trim().isEmpty)) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Food state Selector
                      const Text(
                        'Food state',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _foodStates.map((state) {
                          final isSelected = _selectedFoodState == state;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(state),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedFoodState = state;
                                  });
                                }
                              },
                              selectedColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Keep track of the amount by
                      const Text(
                        'Keep track of the amount by',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _amountTypes.map((type) {
                          final isSelected = _selectedAmountType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedAmountType = type;
                                  });
                                }
                              },
                              selectedColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Quantity/Weight Input Field
                      Text(
                        _selectedAmountType == 'Quantity' ? 'Quantity' : 'Weight',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _amountValueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: _selectedAmountType == 'Quantity' ? 'Enter quantity...' : 'Enter weight in grams...',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          if (double.tryParse(val) == null || double.parse(val) <= 0) {
                            return 'Enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Supplier Field
                      const Text(
                        'Supplier',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _supplierController,
                        decoration: const InputDecoration(
                          hintText: 'Enter supplier name...',
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Costs Field
                      const Text(
                        'Costs',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _costController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Enter cost amount...',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Cost is required';
                                }
                                if (double.tryParse(val) == null || double.parse(val) < 0) {
                                  return 'Enter a valid cost';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _currencies.map((currency) {
                                return DropdownMenuItem(value: currency, child: Text(currency));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCurrency = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Notes Field
                      const Text(
                        'Notes',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Enter any notes about this purchase...',
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  if (widget.expense != null)
                    TextButton.icon(
                      onPressed: _isSaving ? null : _deleteExpense,
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                      side: BorderSide(
                        color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
