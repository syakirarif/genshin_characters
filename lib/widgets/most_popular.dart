import 'package:flutter/material.dart';

class PopularCategory {
  final String category;
  final String id;

  PopularCategory({this.category = '', this.id = ''});
}

final homePopularCategories = [
  PopularCategory(category: 'All', id: '1'),
  PopularCategory(category: 'Chair', id: '2'),
  PopularCategory(category: 'Kitchen', id: '3'),
  PopularCategory(category: 'Table', id: '4'),
  PopularCategory(category: 'Lamp', id: '5'),
  PopularCategory(category: 'Cupboard', id: '6'),
  PopularCategory(category: 'Vase', id: '7'),
  PopularCategory(category: 'Others', id: '8'),
];

class MostPopularCategory extends StatefulWidget {
  const MostPopularCategory({super.key});

  @override
  State<MostPopularCategory> createState() => _MostPopularCategoryState();
}

class _MostPopularCategoryState extends State<MostPopularCategory> {
  late final datas = homePopularCategories;

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
        onTap: () => _onTapItem(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          child: Text(
            data.category,
            style: TextStyle(
              color: isActive ? const Color(0xFFFFFFFF) : const Color(0xFF101010),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // user interact the item of special offers.
  void _onTapItem(int index) {
    setState(() {
      _selectIndex = index;
    });
  }
}

class MostPopularTitle extends StatelessWidget {
  const MostPopularTitle({
    Key? key,
    required this.onTapseeAll,
  }) : super(key: key);

  final Function onTapseeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Most Popular',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF212121))),
        TextButton(
          onPressed: () => onTapseeAll(),
          child: const Text(
            'See All',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }
}
