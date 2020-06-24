import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingList {
  final String id;
  final String name;
  final int totalItems;
  final int purchasedItems;
  final String dynamicLink;
  final List<String> users;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingList({
    this.id,
    this.name,
    this.users,
    this.totalItems,
    this.dynamicLink,
    this.purchasedItems,
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    return ShoppingList(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      totalItems: doc.data['totalItems'] ?? 0,
      dynamicLink: doc.data['dynamicLink'] ?? '',
      purchasedItems: doc.data['purchasedItems'] ?? 0,
      users: List<String>.from(doc.data['users'] ?? []),
      createdAt:
          (doc.data['createdAt'] as Timestamp)?.toDate() ?? DateTime.now(),
      updatedAt:
          (doc.data['updatedAt'] as Timestamp)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name ?? '',
      'users': this.users ?? [],
      'totalItems': this.totalItems ?? 0,
      'dynamicLink': this.dynamicLink ?? '',
      'purchasedItems': this.purchasedItems ?? 0,
      'createdAt': this.createdAt != null
          ? Timestamp.fromDate(this.createdAt)
          : FieldValue.serverTimestamp(),
      'updatedAt': this.updatedAt != null
          ? Timestamp.fromDate(this.updatedAt)
          : FieldValue.serverTimestamp(),
    };
  }
}
