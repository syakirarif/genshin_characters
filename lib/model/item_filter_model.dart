import 'package:flutter/material.dart';
import 'package:genshin_characters/utils/colors.dart';

class ItemFilter {
  String label;
  String value;
  Color color;
  bool isSelected;

  ItemFilter(this.label, this.value, this.color, this.isSelected);

  static List<ItemFilter> initVisionList() {
    return [
      ItemFilter("Dendro", "dendro", Colors.green, false),
      ItemFilter("Anemo", "anemo", Colors.blueGrey, false),
      ItemFilter("Cryo", "cryo", Colors.deepOrange, false),
      ItemFilter("Electro", "electro", Colors.cyan, false),
      ItemFilter("Pyro", "pyro", Colors.teal, false),
      ItemFilter("Any", "any", Colors.teal, false),
    ];
  }

  static List<ItemFilter> initRarityList() {
    return [
      ItemFilter("5 stars", "5", AppColor.rarity5, false),
      ItemFilter("4 stars", "4", AppColor.rarity4, false),
    ];
  }
}
