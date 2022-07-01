import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'chars_detail.dart';
import 'colors.dart';
import 'custom_card.dart';

class CharsList extends StatefulWidget {
  const CharsList({
    Key? key,
  }) : super(key: key);

  @override
  State<CharsList> createState() => _CharsList();
}

class _CharsList extends State<CharsList> {
  late List data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Genshin Characters",
            style: TextStyle(color: Colors.blue, fontSize: 22.0)),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if(constraints.maxWidth < 600) {
            return _generateContainer(2);
          } else if (constraints.maxWidth < 900) {
            return _generateContainer(4);
          } else {
            return _generateContainer(6);
          }
        },
      ),
    );
  }

  Widget _generateContainer(int value) {
    return Container(
      child: Center(
        child: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('data_repo/characters_list.json'),
          builder: (context, snapshot) {
            var new_data = json.decode(snapshot.data.toString());

            return MasonryGridView.count(
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              crossAxisCount: value,
              itemCount: new_data == null ? 0 : new_data.length,
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CharsDetail(
                                      name: new_data[index]['name'],
                                      vision: new_data[index]['vision'],
                                      weapon: new_data[index]['weapon'],
                                      nation: new_data[index]['nation'],
                                      affiliation: new_data[index]
                                      ['affiliation'],
                                      rarity: new_data[index]['rarity'],
                                      constellation: new_data[index]
                                      ['constellation'],
                                      birthday: new_data[index]['birthday'],
                                      description: new_data[index]
                                      ['description'],
                                      obtain: new_data[index]['obtain'],
                                      gender: new_data[index]['gender'],
                                      imagePortrait: new_data[index]
                                      ['image_portrait'],
                                      imageCard: new_data[index]
                                      ['image_card'],
                                      imageWish: new_data[index]
                                      ['image_wish'],
                                      backgroundColor:
                                      new_data[index]['rarity'] == 5
                                          ? AppColor.rarity5
                                          : AppColor.rarity4)));
                        },
                        child: CustomCard(
                          height:
                          new_data[index]['name'].length > 14 ? 270 : 250,
                          customColor: new_data[index]['rarity'] == 5
                              ? AppColor.rarity5
                              : AppColor.rarity4,
                          customImage: new_data[index]['image_portrait'],
                          customButtonColor: AppColor.peachButtonColor,
                          charName: new_data[index]['name'],
                          charVision: new_data[index]['vision'],
                          charNation: new_data[index]['nation'],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
