import 'package:flutter/material.dart';
import 'package:genshin_characters/chars_list.dart';
import 'package:genshin_characters/screens/code_screen.dart';
import 'package:genshin_characters/utils/image_loader.dart';
import 'package:genshin_characters/utils/size_config.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _select = 0;

  final screens = [const CharsList(), const CodeScreen()];

  final List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
        icon: Icon(Icons.group_outlined),
        activeIcon: Icon(Icons.group),
        label: 'Characters'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.redeem_outlined),
        activeIcon: Icon(Icons.redeem),
        label: 'Redeem Codes'),
  ];

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: screens[_select],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        onTap: ((value) => setState(() => _select = value)),
        currentIndex: _select,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        showUnselectedLabels: true,
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
        selectedItemColor: const Color(0xFF212121),
        unselectedItemColor: const Color(0xFF9E9E9E),
      ),
    );
  }
}
