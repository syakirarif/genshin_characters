// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:fruits_ui/single_fruit.dart';
//
// import 'colors.dart';
// import 'custom_card.dart';
// import 'dart:convert';
//
// class CharListPage extends StatefulWidget {
//   const CharListPage({
//     Key key,
//   }) : super(key: key);
//
//   @override
//   State<CharListPage> createState() => _CharListPageState();
// }
//
// class _CharListPageState extends State<CharListPage> {
//
//   List data;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Genshin Characters"),
//       ),
//       body: Container(
//         child: Expanded(
//           child: FutureBuilder(
//             future: DefaultAssetBundle.of(context).loadString(
//                 'data_repo/characters_list.json'),
//             builder: (context, snapshot) {
//               var new_data = json.decode(snapshot.data.toString());
//
//               return MasonryGridView(
//                   mainAxisSpacing: 15.0,
//                   crossAxisSpacing: 15.0,
//                   gridDelegate:
//                   const SliverSimpleGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                   ),
//                 children:
//               )
//             },
//           ),
//         ),
//       ),
//     )
//   }
// }
