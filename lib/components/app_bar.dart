import 'package:flutter/material.dart';

typedef MenuOptionTap = void Function();

abstract class FRAppBar {
  static PreferredSizeWidget defaultAppBar(
    BuildContext context, {
    String title = '',
    List<Widget>? actions,
  }) {
    return AppBar(
      // leading: IconButton(
      //   onPressed: (() => Navigator.pop(context)),
      //   icon: Image.asset(
      //     'assets/icons/back@2x.png',
      //     scale: 2.0,
      //   ),
      // ),
      elevation: 0.5,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Color(0xFF212121),
        ),
      ),
      centerTitle: false,
      actions: actions,
    );
  }

  static PreferredSizeWidget appBarWithBack(BuildContext context,
      {String title = '',
      List<Widget>? actions,
      MenuOptionTap? onLeadingClicked}) {
    return AppBar(
      leading: IconButton(
        onPressed: (() => onLeadingClicked?.call()),
        icon: Image.asset(
          'assets/icons/back@2x.png',
          scale: 2.0,
        ),
      ),
      elevation: 0.5,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Color(0xFF212121),
        ),
      ),
      centerTitle: false,
      actions: actions,
    );
  }
}
