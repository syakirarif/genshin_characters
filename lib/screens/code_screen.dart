import 'package:flutter/material.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/screens/web_view_screen.dart';
import 'package:genshin_characters/widgets/item_code.dart';

class Product {
  final String title;
  final double star;
  final int sold;
  final double price;
  final String icon;
  final String id;

  Product(
      {this.title = '',
      this.star = 0.0,
      this.sold = 0,
      this.price = 0.0,
      this.icon = '',
      this.id = '0'});
}

final homePopularProducts = [
  Product(
    title: 'Foam Padded Chair',
    star: 4.5,
    sold: 8374,
    price: 120.00,
    icon: 'assets/icons/products/book_case@2x.png',
  ),
  Product(
    title: 'Small Bookcase',
    star: 4.7,
    sold: 7483,
    price: 145.40,
    icon: 'assets/icons/products/book_case@2x.png',
  ),
  Product(
    title: 'Glass Lamp',
    star: 4.3,
    sold: 6937,
    price: 40.00,
    icon: 'assets/icons/products/book_case@2x.png',
  ),
  Product(
    title: 'Glass Package',
    star: 4.9,
    sold: 8174,
    price: 55.00,
    icon: 'assets/icons/products/book_case@2x.png',
  ),
  Product(
    title: 'Plastic Chair',
    star: 4.6,
    sold: 6843,
    price: 65.00,
    icon: 'assets/icons/products/book_case@2x.png',
  ),
  Product(
    title: 'Wooden Chairs',
    star: 4.5,
    sold: 7758,
    price: 69.00,
    icon: 'assets/icons/products/book_case@2x.png',
  ),
];

class CodeScreen extends StatefulWidget {
  const CodeScreen({Key? key}) : super(key: key);

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  late final datas = homePopularProducts;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.fromLTRB(24, 24, 24, 0);
    return Scaffold(
      appBar: FRAppBar.defaultAppBar(context, title: 'Redeem Codes', actions: [
        IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            size: 32,
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (builder) => WebViewScreen()));
          },
        ),
      ]),
      body: CustomScrollView(
        slivers: [
          // SliverPadding(
          //   padding: padding,
          //   sliver: SliverList(
          //     delegate: SliverChildBuilderDelegate(
          //       ((context, index) => const MostPopularCategory()),
          //       childCount: 1,
          //     ),
          //   ),
          // ),
          SliverPadding(
            padding: padding,
            sliver: _buildPopulars(),
          ),
          const SliverAppBar(flexibleSpace: SizedBox(height: 24))
        ],
      ),
    );
  }

  Widget _buildPopulars() {
    return SliverList(
      // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      //   maxCrossAxisExtent: 185,
      //   mainAxisSpacing: 24,
      //   crossAxisSpacing: 16,
      //   mainAxisExtent: 285,
      // ),
      delegate: SliverChildBuilderDelegate(_buildPopularItem, childCount: 30),
    );
  }

  void showBottomSheet({required String email}) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
              padding: const EdgeInsets.all(22),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Input Data Redeem Code',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text('Expiration Time:',
                        style: TextStyle(fontSize: 12)),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget _buildPopularItem(BuildContext context, int index) {
    final data = datas[index % datas.length];
    return ItemCode(
      onClickItem: showBottomSheet,
    );
    // return ProductCard(
    //   data: data,
    // );
  }
}
