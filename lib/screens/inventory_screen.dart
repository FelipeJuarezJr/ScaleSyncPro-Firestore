import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/add_expense_modal.dart';
import '../utils/theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ExpenseService _expenseService = ExpenseService();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddExpenseModal([Expense? expense]) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddExpenseModal(expense: expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgPrimary : AppTheme.lightBgPrimary,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddExpenseModal(),
              backgroundColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
              foregroundColor: isDark ? Colors.black : Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.watchExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Card(
                color: isDark ? AppTheme.bgSecondary : AppTheme.lightBgSecondary,
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Expenses',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final expenses = snapshot.data ?? [];
          final filteredExpenses = expenses.where((exp) {
            final query = _searchQuery.toLowerCase();
            return exp.itemType.toLowerCase().contains(query) ||
                exp.supplier.toLowerCase().contains(query) ||
                exp.foodState.toLowerCase().contains(query) ||
                exp.description.toLowerCase().contains(query) ||
                exp.notes.toLowerCase().contains(query);
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final padding = width > 600 ? 24.0 : 16.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Add Button Row
                  Padding(
                    padding: EdgeInsets.fromLTRB(padding, padding, padding, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inventory Expenses',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track food, bedding, and supply purchases',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (!isMobile)
                          ElevatedButton.icon(
                            onPressed: () => _showAddExpenseModal(),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add Expense'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search expenses by item type, supplier, state...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: filteredExpenses.isEmpty
                        ? _buildEmptyState(context, expenses.isEmpty)
                        : _buildGridView(context, filteredExpenses, width, padding),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isCollectionEmpty) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCollectionEmpty ? Icons.shopping_cart_outlined : Icons.search_off,
              size: 72,
              color: isDark ? AppTheme.textLight : AppTheme.lightTextLight,
            ),
            const SizedBox(height: 20),
            Text(
              isCollectionEmpty ? 'No expenses recorded' : 'No matching expenses found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isCollectionEmpty
                  ? 'Add your first food or supply expense to track costs.'
                  : 'Try adjusting your search criteria.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (isCollectionEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddExpenseModal(),
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Expense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<Expense> list, double width, double padding) {
    int crossAxisCount = 1;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 850) {
      crossAxisCount = 3;
    } else if (width > 550) {
      crossAxisCount = 2;
    }

    double childAspectRatio = 1.7;
    if (width > 1400) {
      childAspectRatio = 1.8;
    } else if (width > 1200) {
      childAspectRatio = 1.6;
    } else if (width > 850) {
      childAspectRatio = 1.7;
    } else if (width > 550) {
      childAspectRatio = 1.7;
    } else {
      childAspectRatio = 2.0;
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, padding + 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final expense = list[index];
        return _buildExpenseCard(context, expense);
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.bgSecondary : AppTheme.lightBgPrimary;

    IconData getExpenseIcon(String itemType) {
      switch (itemType) {
        case 'Rats':
        case 'Mice':
          return Icons.pets_outlined;
        case 'Crickets':
        case 'Mealworms':
        case 'Roaches':
          return Icons.bug_report_outlined;
        case 'Bedding':
          return Icons.layers_outlined;
        case 'Supplements':
          return Icons.opacity_outlined;
        case 'Medicine':
          return Icons.medical_services_outlined;
        case 'Equipment':
          return Icons.build_outlined;
        default:
          return Icons.shopping_basket_outlined;
      }
    }

    Color getExpenseIconColor(String itemType) {
      switch (itemType) {
        case 'Rats':
        case 'Mice':
          return Colors.brown;
        case 'Crickets':
        case 'Mealworms':
        case 'Roaches':
          return Colors.green;
        case 'Bedding':
          return Colors.amber;
        case 'Supplements':
          return Colors.teal;
        case 'Medicine':
          return Colors.red;
        case 'Equipment':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    final formattedCost = NumberFormat.currency(
      symbol: expense.currency == 'USD' ? '\$' : '${expense.currency} ',
      decimalDigits: 2,
    ).format(expense.cost);

    final amountText = expense.amountType == 'Quantity'
        ? '${expense.amountValue.toInt()} units'
        : '${expense.amountValue} g';

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        side: BorderSide(
          color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showAddExpenseModal(expense),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Icon + Title + Edit Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getExpenseIconColor(expense.itemType).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
                    ),
                    child: Icon(
                      getExpenseIcon(expense.itemType),
                      color: getExpenseIconColor(expense.itemType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.itemType == 'Other' && expense.description.isNotEmpty
                              ? expense.description
                              : expense.itemType,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (expense.itemType == 'Other' && expense.description.isNotEmpty)
                          Text(
                            'OTHER SUPPLY',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          )
                        else if (expense.foodState != 'N/A')
                          Text(
                            expense.foodState.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: isDark ? AppTheme.textLight : AppTheme.lightTextLight,
                  ),
                ],
              ),
              if (expense.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  expense.notes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),

              // Supplier & Quantity Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (expense.supplier.isNotEmpty)
                          Text(
                            expense.supplier,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'No supplier recorded',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.textLight : AppTheme.lightTextLight,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          amountText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.textLight : AppTheme.lightTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cost Display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedCost,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.successColor : const Color(0xFF2C5530),
                        ),
                      ),
                      Text(
                        DateFormat('dd-MM-yyyy').format(expense.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: isDark ? AppTheme.textLight : AppTheme.lightTextLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}