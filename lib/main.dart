import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'colors.dart';
import 'custom_card.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late List data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Genshin Characters"),
      ),
      body: Container(
        child: Center(
          child: FutureBuilder(
            future: DefaultAssetBundle.of(context)
                .loadString('data_repo/characters_list.json'),
            builder: (context, snapshot) {
              var new_data = json.decode(snapshot.data.toString());

              return MasonryGridView.count(
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: 2,
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
                          onTap: () {},
                          child: CustomCard(
                            height: 250,
                            customColor: AppColor.peachCardColor,
                            customImage: new_data[index]['image_portrait'],
                            customButtonColor: AppColor.peachButtonColor,
                            fruitName: new_data[index]['name'],
                            fruitUnit: new_data[index]['vision'],
                            fruitPrice: new_data[index]['nation'],
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
      ),
    );
  }
}
