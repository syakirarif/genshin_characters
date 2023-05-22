import 'package:flutter/material.dart';

class CharCategoryModel {
  final String category;
  final String id;

  CharCategoryModel({this.category = '', this.id = ''});
}

final charCategories = [
  CharCategoryModel(category: 'All', id: '0'),
  CharCategoryModel(category: 'Electro', id: '1'),
  CharCategoryModel(category: 'Anemo', id: '2'),
  CharCategoryModel(category: 'Pyro', id: '3'),
  CharCategoryModel(category: 'Dendro', id: '4'),
  CharCategoryModel(category: 'Geo', id: '5'),
];

typedef OnTapCharCategory = void Function({required String vision});

class CharCategory extends StatefulWidget {
  const CharCategory({this.onTap, Key? key}) : super(key: key);

  final OnTapCharCategory? onTap;

  @override
  State<CharCategory> createState() => _CharCategoryState();
}

class _CharCategoryState extends State<CharCategory> {
  late final datas = charCategories;

  int _selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBody(),
      ],
    );
  }

  Widget _buildBody() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        itemCount: datas.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: _buildItem,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 12);
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final data = datas[index];
    final isActive = _selectIndex == index;
    const radius = BorderRadius.all(Radius.circular(19));
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF101010), width: 2),
        color: isActive ? const Color(0xFF101010) : const Color(0xFFFFFFFF),
      ),
      alignment: Alignment.center,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _onTapItem(index, data.category),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          child: Text(
            data.category,
            style: TextStyle(
              color:
                  isActive ? const Color(0xFFFFFFFF) : const Color(0xFF101010),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // user interact the item of special offers.
  void _onTapItem(int index, String category) {
    // widget.onTap(vision: category);
    setState(() {
      _selectIndex = index;
    });
  }
}
