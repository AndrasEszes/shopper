import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String user;

  Category({
    this.id,
    this.name,
    this.user,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    return Category(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      user: doc.data['user'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name ?? '',
      'user': this.user ?? '',
    };
  }
}
