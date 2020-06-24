import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shopper/src/models/ShoppingList.dart';
import 'package:shopper/src/models/ShoppingListItem.dart';
import 'package:shopper/src/routes/CreateShoppingListItemRoute.dart';
import 'package:shopper/src/services/DatabaseService.dart';
import 'package:shopper/src/widgets/ShopperAppBar.dart';

class ShoppingListRoute extends StatelessWidget {
  final DatabaseService _db = DatabaseService();
  final ShoppingList shoppingList;

  ShoppingListRoute({
    Key key,
    @required this.shoppingList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<ShoppingListItem>>.value(
      value: _db.streamShoppingListItems(shoppingList),
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final List<ShoppingListItem> shoppingListItems =
        Provider.of<List<ShoppingListItem>>(context);

    bool isLoading = shoppingListItems == null;
    bool isEmpty = !isLoading && shoppingListItems.isEmpty;

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

    List<Widget> actions = [];
    if (shoppingList.dynamicLink.isNotEmpty) {
      actions.add(IconButton(
        icon: Icon(Icons.share),
        onPressed: () {
          final RenderBox box = context.findRenderObject();
          Share.share(
            shoppingList.dynamicLink,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          );
        },
      ));
    }

    return Scaffold(
      body: body,
      resizeToAvoidBottomInset: false,
      floatingActionButton: floatingActionButton,
      appBar: ShopperAppBar(
        actions: actions,
        title: shoppingList.name.toLowerCase(),
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context) {
    final List<ShoppingListItem> shoppingListItems =
        Provider.of<List<ShoppingListItem>>(context);

    return GroupedListView(
      elements: shoppingListItems,
      separator: Divider(height: 1),
      itemBuilder: _buildShoppingListTile,
      groupSeparatorBuilder: _buildGroupSeparator(context),
      groupBy: (ShoppingListItem shoppingListItem) =>
          shoppingListItem.category.trim(),
    );
  }

  Widget Function(String) _buildGroupSeparator(BuildContext context) {
    return (category) {
      final ThemeData theme = Theme.of(context);

      return Container(
        child: Text(
          category,
          style: theme.textTheme.headline6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        color: Colors.black12,
      );
    };
  }

  Widget _buildShoppingListTile(
    BuildContext context,
    ShoppingListItem shoppingListItem,
  ) {
    return Dismissible(
      key: Key(shoppingListItem.id),
      direction: DismissDirection.endToStart,
      child: CheckboxListTile(
        title: Text(shoppingListItem.name),
        value: shoppingListItem.purchased,
        onChanged: (purchased) {
          _db.updateCheckedStateOfShoppingListItem(
            shoppingListItem.id,
            shoppingList,
            purchased,
          );
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
      background: Container(
        color: Colors.redAccent[400],
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.delete_forever, color: Colors.white),
      ),
      onDismissed: (_) {
        _db.deleteShoppingListItem(shoppingList, shoppingListItem);
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateShoppingListItemRoute(
              shoppingList: shoppingList,
            ),
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
            'Your shopping list is empty',
            textAlign: TextAlign.center,
            style: theme.textTheme.headline5,
          ),
          SizedBox(height: 36),
          RaisedButton(
            child: Text('Create shopping list item'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateShoppingListItemRoute(
                    shoppingList: shoppingList,
                  ),
                ),
              );
            },
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
