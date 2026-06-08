import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingLog {
  final String? id;
  final List<String> feedItems; // e.g. ["1 Mealworms, 3 gr", "2 Crickets"]
  final List<String> supplements; // e.g. ["Multivitamin", "Calcium"]
  final DateTime feedingDate;
  final String? notes;
  final double? quantity;
  final String? quantityUnit;

  FeedingLog({
    this.id,
    required this.feedItems,
    this.supplements = const [],
    required this.feedingDate,
    this.notes,
    this.quantity,
    this.quantityUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'feedItems': feedItems,
      'supplements': supplements,
      'feedingDate': Timestamp.fromDate(feedingDate),
      'notes': notes,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
    };
  }

  factory FeedingLog.fromMap(Map<String, dynamic> map, String id) {
    return FeedingLog(
      id: id,
      feedItems: List<String>.from(map['feedItems'] ?? []),
      supplements: List<String>.from(map['supplements'] ?? []),
      feedingDate: (map['feedingDate'] as Timestamp).toDate(),
      notes: map['notes'],
      quantity: (map['quantity'] as num?)?.toDouble(),
      quantityUnit: map['quantityUnit'],
    );
  }

  /// Returns a human-readable summary line, e.g. "1 Mealworms, 3 gr"
  String get summary {
    if (feedItems.isEmpty) return 'No items logged';
    return feedItems.join(', ');
  }
}
