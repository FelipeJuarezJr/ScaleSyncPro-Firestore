import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('users').doc(_userId).collection('expenses');

  // Add a new expense record
  Future<String> addExpense(Expense expense) async {
    try {
      if (_userId.isEmpty) throw Exception('User not logged in');
      final docRef = await _expensesCollection.add(expense.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Update an existing expense record
  Future<void> updateExpense(String id, Expense expense) async {
    try {
      if (_userId.isEmpty) throw Exception('User not logged in');
      await _expensesCollection.doc(id).update(expense.toMap());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // Delete an expense record
  Future<void> deleteExpense(String id) async {
    try {
      if (_userId.isEmpty) throw Exception('User not logged in');
      await _expensesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  // Retrieve all expenses
  Future<List<Expense>> getExpenses() async {
    try {
      if (_userId.isEmpty) return [];
      final querySnapshot = await _expensesCollection.orderBy('date', descending: true).get();
      return querySnapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  // Stream expenses in real-time
  Stream<List<Expense>> watchExpenses() {
    if (_userId.isEmpty) return Stream.value([]);
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data(), doc.id))
            .toList());
  }
}
