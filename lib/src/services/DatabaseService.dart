import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shopper/src/models/Category.dart';
import 'package:shopper/src/models/ShoppingList.dart';
import 'package:shopper/src/models/ShoppingListItem.dart';

class DatabaseService {
  final _db = Firestore.instance;

  Stream<List<Category>> streamCategories(
    FirebaseUser user,
  ) {
    return _categories()
        .where('user', isEqualTo: user.uid)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.documents.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Stream<List<ShoppingList>> streamShoppingLists(
    FirebaseUser user,
  ) {
    return _shoppingLists()
        .where('users', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.documents
            .map((doc) => ShoppingList.fromFirestore(doc))
            .toList());
  }

  Stream<List<ShoppingListItem>> streamShoppingListItems(
    ShoppingList shoppingList,
  ) {
    return _items(shoppingList.id)
        .orderBy('category')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.documents
            .map((doc) => ShoppingListItem.fromFirestore(doc))
            .toList());
  }

  Future<void> createCategory(
    String name,
    FirebaseUser user,
  ) async {
    await _categories().add(Category(
      name: name,
      user: user.uid,
    ).toMap());
  }

  Future<void> createShoppingList(
    String name,
    FirebaseUser user,
  ) async {
    final DocumentReference ref = await _shoppingLists().add(ShoppingList(
      name: name,
      users: [user.uid],
    ).toMap());

    final dynamicLink = await DynamicLinkParameters(
      uriPrefix: 'https://andraseszes.page.link',
      link: Uri.parse('https://andraseszes.page.link/${ref.documentID}'),
      androidParameters: AndroidParameters(
        packageName: 'com.andraseszes.shopper',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Someone shared their shopping list with you.',
        description: 'Please accept to see what to buy.',
      ),
    ).buildShortLink();

    await _shoppingList(ref.documentID).updateData({
      'dynamicLink': dynamicLink.shortUrl.toString(),
    });
  }

  Future<void> createShoppingListItem(
    String name,
    String category,
    ShoppingList shoppingList,
  ) async {
    await _items(shoppingList.id).add(ShoppingListItem(
      name: name,
      category: category,
    ).toMap());

    await _shoppingList(shoppingList.id).updateData({
      'totalItems': FieldValue.increment(1),
    });
  }

  Future<void> deleteShoppingList(String id) async {
    final batch = _db.batch();
    final items = await _items(id).getDocuments();

    items.documents.forEach((ref) {
      batch.delete(ref.reference);
    });

    batch.delete(_shoppingList(id));

    return batch.commit();
  }

  Future<void> deleteShoppingListItem(
    ShoppingList shoppingList,
    ShoppingListItem shoppingListItem,
  ) {
    final batch = _db.batch();
    final purchased = shoppingListItem.purchased;

    batch.delete(_item(shoppingList.id, shoppingListItem.id));
    batch.updateData(_shoppingList(shoppingList.id), {
      'totalItems': FieldValue.increment(-1),
      'purchasedItems': FieldValue.increment(purchased ? -1 : 0),
    });

    return batch.commit();
  }

  Future<void> updateCheckedStateOfShoppingListItem(
    String id,
    ShoppingList shoppingList,
    bool purchased,
  ) {
    final batch = _db.batch();

    batch.updateData(_item(shoppingList.id, id), {
      'purchased': purchased,
    });

    batch.updateData(_shoppingList(shoppingList.id), {
      'purchasedItems': FieldValue.increment(purchased ? 1 : -1),
    });

    return batch.commit();
  }

  Future<void> attachUserToShoppingList(FirebaseUser user, String id) {
    return _shoppingList(id).updateData({
      'users': FieldValue.arrayUnion([user.uid]),
    });
  }

  CollectionReference _items(String shoppingListId) {
    return _shoppingList(shoppingListId).collection('items');
  }

  CollectionReference _categories() {
    return _db.collection('categories');
  }

  CollectionReference _shoppingLists() {
    return _db.collection('shopping_lists');
  }

  DocumentReference _item(String shoppingListId, String id) {
    return _items(shoppingListId).document(id);
  }

  DocumentReference _category(String id) {
    return _categories().document(id);
  }

  DocumentReference _shoppingList(String id) {
    return _shoppingLists().document(id);
  }
}
