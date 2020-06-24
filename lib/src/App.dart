import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shopper/src/routes/ShoppingListsRoute.dart';
import 'package:shopper/src/services/DatabaseService.dart';
import 'package:shopper/src/widgets/LoadingScreen.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  final _db = DatabaseService();
  final _auth = FirebaseAuth.instance;
  final _dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromRGBO(27, 105, 253, 1);

    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(value: _auth.onAuthStateChanged),
      ],
      child: MaterialApp(
        home: ShoppingListsRoute(),
        title: 'shopper',
        theme: ThemeData(
          textTheme: GoogleFonts.varelaRoundTextTheme(),
          buttonTheme: ButtonThemeData(
            buttonColor: primaryColor,
            textTheme: ButtonTextTheme.primary,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          primaryColor: primaryColor,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
          ),
          toggleableActiveColor: primaryColor,
        ),
        builder: (context, widget) {
          final FirebaseUser user = Provider.of<FirebaseUser>(context);

          if (user == null) {
            return LoadingScreen();
          }

          return widget;
        },
      ),
    );
  }

  void _initDynamicLinks() async {
    final authResult = await _auth.signInAnonymously();
    final dynamicLinkData = await _dynamicLinks.getInitialLink();

    if (dynamicLinkData != null) {
      final id = dynamicLinkData.link.path.replaceFirst('/', '');
      await _db.attachUserToShoppingList(authResult.user, id);
    }

    _dynamicLinks.onLink(onSuccess: (dynamicLink) async {
      if (dynamicLinkData != null) {
        final id = dynamicLinkData.link.path.replaceFirst('/', '');
        await _db.attachUserToShoppingList(authResult.user, id);
      }
    });
  }
}
