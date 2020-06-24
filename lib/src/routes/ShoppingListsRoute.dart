import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shopper/src/models/ShoppingList.dart';
import 'package:shopper/src/routes/CreateShoppingListRoute.dart';
import 'package:shopper/src/routes/ShoppingListRoute.dart';
import 'package:shopper/src/services/DatabaseService.dart';
import 'package:shopper/src/widgets/ShopperAppBar.dart';

class ShoppingListsRoute extends StatelessWidget {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final FirebaseUser user = Provider.of<FirebaseUser>(context);

    return StreamProvider<List<ShoppingList>>.value(
      value: _db.streamShoppingLists(user),
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final shoppingLists = Provider.of<List<ShoppingList>>(context);

    bool isLoading = shoppingLists == null;
    bool isEmpty = !isLoading && shoppingLists.isEmpty;

    Widget body;
    if (isLoading) {
      body = Center(child: CircularProgressIndicator());
    } else if (isEmpty) {
      body = _buildEmptyState(context);
    } else {
      body = _buildShoppingList(context);
    }

    Widget floatingActionButton;
    if (!isEmpty) {
      floatingActionButton = _buildFloatingActionButton(context);
    }

    return Scaffold(
      body: body,
      resizeToAvoidBottomInset: false,
      appBar: ShopperAppBar(title: 'shopper'),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildShoppingList(BuildContext context) {
    final shoppingLists = Provider.of<List<ShoppingList>>(context);

    return ListView.separated(
      itemCount: shoppingLists.length,
      separatorBuilder: (_, i) => Divider(key: Key('divider-$i')),
      itemBuilder: (context, i) => _buildShoppingListTile(
        context,
        shoppingLists[i],
      ),
    );
  }

  Widget _buildShoppingListTile(
    BuildContext context,
    ShoppingList shoppingList,
  ) {
    return Dismissible(
      key: Key(shoppingList.id),
      direction: DismissDirection.endToStart,
      child: ListTile(
        title: Text(shoppingList.name),
        subtitle: Text(
          '${shoppingList.purchasedItems}/${shoppingList.totalItems} purchased',
        ),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ShoppingListRoute(
                shoppingList: shoppingList,
              ),
            ),
          );
        },
      ),
      background: Container(
        color: Colors.redAccent[400],
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.delete_forever, color: Colors.white),
      ),
      onDismissed: (_) {
        _db.deleteShoppingList(shoppingList.id);
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateShoppingListRoute(),
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          SvgPicture.asset(
            'images/empty.svg',
            height: 224,
          ),
          Text(
            'You don\'t have a\nshopping list yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.headline5,
          ),
          SizedBox(height: 36),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateShoppingListRoute(),
                ),
              );
            },
            child: Text('Create shopping list'),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
