import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:shopper/src/services/DatabaseService.dart';
import 'package:shopper/src/widgets/ShopperAppBar.dart';

class CreateShoppingListRoute extends StatelessWidget {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final FirebaseUser user = Provider.of<FirebaseUser>(context);
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: ShopperAppBar(
        title: 'create shopping list',
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              child: FormBuilderTextField(
                attribute: 'name',
                decoration: const InputDecoration(labelText: 'Name'),
                validators: [
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(256),
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
                      final String name = _fbKey.currentState.value['name'];

                      await _db.createShoppingList(name, user);

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
