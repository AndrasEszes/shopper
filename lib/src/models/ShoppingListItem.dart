import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String id;
  final String name;
  final String link;
  final bool purchased;
  final String category;

  ShoppingListItem({
    this.id,
    this.name,
    this.link,
    this.category,
    this.purchased,
  });

  factory ShoppingListItem.fromFirestore(DocumentSnapshot doc) {
    return ShoppingListItem(
      id: doc.documentID,
      name: doc.data['name'] ?? '',
      link: doc.data['link'] ?? '',
      category: doc.data['category'] ?? '',
      purchased: doc.data['purchased'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name ?? '',
      'link': this.link ?? '',
      'category': this.category ?? '',
      'purchased': this.purchased ?? false,
    };
  }
}
