import 'package:flutter/material.dart';
import 'package:genshin_characters/utils/image_loader.dart';

class TabbarItem {
  final IconData lightIcon;
  final IconData boldIcon;
  final String label;

  TabbarItem(
      {required this.lightIcon, required this.boldIcon, required this.label});

  BottomNavigationBarItem item(bool isBold) {
    return BottomNavigationBarItem(
        // icon: ImageLoader.imageAsset(isBold ? boldIcon : lightIcon),
        icon: ImageLoader.imageIcon(isBold ? boldIcon : lightIcon),
        label: label);
  }

  BottomNavigationBarItem get light => item(false);

  BottomNavigationBarItem get bold => item(true);
}
