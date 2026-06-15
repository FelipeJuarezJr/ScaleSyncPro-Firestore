import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String itemType;       // e.g., 'Rats', 'Mice', 'Crickets', etc.
  final String foodState;      // 'Dried', 'Fresh', 'Frozen', 'Live', 'N/A'
  final String amountType;     // 'Quantity', 'Weight'
  final double amountValue;    // The actual quantity/weight number
  final String supplier;
  final double cost;
  final String currency;       // e.g., 'USD', 'EUR'
  final DateTime date;
  final String description;    // For random items when itemType is 'Other'
  final String notes;          // General notes for the expense

  Expense({
    this.id,
    required this.itemType,
    required this.foodState,
    required this.amountType,
    required this.amountValue,
    required this.supplier,
    required this.cost,
    required this.currency,
    required this.date,
    this.description = '',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'itemType': itemType,
      'foodState': foodState,
      'amountType': amountType,
      'amountValue': amountValue,
      'supplier': supplier,
      'cost': cost,
      'currency': currency,
      'date': Timestamp.fromDate(date),
      'description': description,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Expense(
      id: documentId,
      itemType: map['itemType'] ?? '',
      foodState: map['foodState'] ?? 'N/A',
      amountType: map['amountType'] ?? 'Quantity',
      amountValue: (map['amountValue'] as num?)?.toDouble() ?? 0.0,
      supplier: map['supplier'] ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'USD',
      date: parsedDate,
      description: map['description'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Expense copyWith({
    String? id,
    String? itemType,
    String? foodState,
    String? amountType,
    double? amountValue,
    String? supplier,
    double? cost,
    String? currency,
    DateTime? date,
    String? description,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      foodState: foodState ?? this.foodState,
      amountType: amountType ?? this.amountType,
      amountValue: amountValue ?? this.amountValue,
      supplier: supplier ?? this.supplier,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }
}
