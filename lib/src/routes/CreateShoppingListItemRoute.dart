import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:shopper/src/models/Category.dart';
import 'package:shopper/src/models/ShoppingList.dart';
import 'package:shopper/src/services/DatabaseService.dart';
import 'package:shopper/src/widgets/ShopperAppBar.dart';

class CreateShoppingListItemRoute extends StatelessWidget {
  final DatabaseService _db = DatabaseService();
  final ShoppingList shoppingList;

  CreateShoppingListItemRoute({
    Key key,
    @required this.shoppingList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseUser user = Provider.of<FirebaseUser>(context);

    return StreamProvider<List<Category>>.value(
      value: _db.streamCategories(user),
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final List<Category> categories = Provider.of<List<Category>>(context);

    bool isLoading = categories == null;

    Widget body;
    if (isLoading) {
      body = Center(child: CircularProgressIndicator());
    } else {
      body = _buildForm(context);
    }

    return Scaffold(
      appBar: ShopperAppBar(
        title: 'create shopping list item',
      ),
      body: body,
    );
  }

  Widget _buildForm(BuildContext context) {
    final FirebaseUser user = Provider.of<FirebaseUser>(context);
    final List<Category> categories = Provider.of<List<Category>>(context);
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: <Widget>[
          FormBuilder(
            key: _fbKey,
            child: Column(
              children: <Widget>[
                FormBuilderTypeAhead(
                  attribute: 'category',
                  decoration: const InputDecoration(labelText: 'Category'),
                  itemBuilder: (_, String category) {
                    return ListTile(
                      title: Text(category),
                    );
                  },
                  suggestionsCallback: (pattern) {
                    if (pattern.isNotEmpty) {
                      return categories
                          .where(_compare(pattern))
                          .map((category) => category.name)
                          .toList();
                    }

                    return categories.map((category) => category.name).toList();
                  },
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(256),
                  ],
                ),
                FormBuilderTextField(
                  attribute: 'name',
                  decoration: const InputDecoration(labelText: 'Name'),
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(256),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 32),
              RaisedButton(
                child: Text('Save'),
                onPressed: () async {
                  if (_fbKey.currentState.saveAndValidate()) {
                    final String name =
                        _fbKey.currentState.value['name'].trim();
                    final String category =
                        _fbKey.currentState.value['category'].trim();
                    final bool isCategoryExists =
                        categories.where(_equals(category)).isNotEmpty;

                    await _db.createShoppingListItem(
                      name,
                      category,
                      shoppingList,
                    );

                    if (!isCategoryExists) {
                      await _db.createCategory(category, user);
                    }

                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool Function(Category category) _compare(String pattern) {
    return (category) {
      return category.name.toLowerCase().contains(pattern.toLowerCase());
    };
  }

  bool Function(Category category) _equals(String pattern) {
    return (category) {
      return category.name.toLowerCase() == pattern.toLowerCase();
    };
  }
}
