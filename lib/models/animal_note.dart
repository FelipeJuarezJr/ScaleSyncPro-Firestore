import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalNote {
  final String? id;
  final String content;
  final DateTime createdAt;

  AnimalNote({
    this.id,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AnimalNote.fromMap(Map<String, dynamic> map, String id) {
    return AnimalNote(
      id: id,
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
