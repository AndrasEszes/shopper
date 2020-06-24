import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopperAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const ShopperAppBar({Key key, this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this._appBar;
  }

  @override
  Size get preferredSize => this._appBar.preferredSize;

  AppBar get _appBar {
    return AppBar(
      title: Text(
        this.title,
        style: GoogleFonts.dancingScript().copyWith(
          fontSize: 32,
        ),
      ),
      actions: actions,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }
}
