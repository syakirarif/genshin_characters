import 'package:flutter/material.dart';

class FilterCategory {
  final String category;
  final String id;
  final String? imgPath;

  FilterCategory({this.category = '', this.id = '', this.imgPath});
}

final homePopularCategories = [
  FilterCategory(category: 'All', id: 'all', imgPath: null),
  FilterCategory(category: '5', id: '5', imgPath: 'star'),
  FilterCategory(category: '4', id: '4', imgPath: 'star'),
  FilterCategory(category: 'Anemo', id: 'anemo', imgPath: 'anemo'),
  FilterCategory(category: 'Geo', id: 'geo', imgPath: 'geo'),
  FilterCategory(category: 'Electro', id: 'electro', imgPath: 'electro'),
  FilterCategory(category: 'Dendro', id: 'dendro', imgPath: 'dendro'),
  FilterCategory(category: 'Hydro', id: 'hydro', imgPath: 'hydro'),
  FilterCategory(category: 'Pyro', id: 'pyro', imgPath: 'pyro'),
  FilterCategory(category: 'Cryo', id: 'cryo', imgPath: 'cryo'),
  FilterCategory(category: 'Any', id: 'any', imgPath: 'any'),
];

class CharFilterCategory extends StatefulWidget {
  const CharFilterCategory({required this.onTapFunction, super.key});

  final Function(String idCategory) onTapFunction;

  @override
  State<CharFilterCategory> createState() => _CharFilterCategoryState();
}

class _CharFilterCategoryState extends State<CharFilterCategory> {
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
          return const SizedBox(width: 10);
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
          child: Row(
            children: [
              (data.imgPath != null)
                  ? Image(
                      image: AssetImage(
                          'assets/icons/elements/${data.imgPath!}.webp'),
                      height: 32.0,
                    )
                  : Container(),
              (data.imgPath != null) ? const SizedBox(width: 8) : Container(),
              Text(
                data.category,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF101010),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // user interact the item of special offers.
  void _onTapItem(int index) {
    widget.onTapFunction(datas[index].id);
    setState(() {
      _selectIndex = index;
    });
  }
}

// class MostPopularTitle extends StatelessWidget {
//   const MostPopularTitle({
//     Key? key,
//     required this.onTapseeAll,
//   }) : super(key: key);
//
//   final Function onTapseeAll;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text('Most Popular',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF212121))),
//         TextButton(
//           onPressed: () => onTapseeAll(),
//           child: const Text(
//             'See All',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: Color(0xFF212121),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
