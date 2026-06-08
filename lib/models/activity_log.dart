import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String? id;
  final String event; // e.g. "Took a bath", "Weight changed"
  final String? detail; // e.g. "12 gr → 14 gr"
  final String type; // 'manual', 'weight_change', 'length_change', 'feeding', 'note', 'photo'
  final DateTime logDate;

  ActivityLog({
    this.id,
    required this.event,
    this.detail,
    this.type = 'manual',
    required this.logDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'event': event,
      'detail': detail,
      'type': type,
      'logDate': Timestamp.fromDate(logDate),
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map, String id) {
    return ActivityLog(
      id: id,
      event: map['event'] ?? '',
      detail: map['detail'],
      type: map['type'] ?? 'manual',
      logDate: (map['logDate'] as Timestamp).toDate(),
    );
  }
}
