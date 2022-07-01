import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'colors.dart';

class CharsDetail extends StatefulWidget {
  CharsDetail(
      {Key? key,
      required this.name,
      required this.vision,
      required this.weapon,
      required this.nation,
      required this.affiliation,
      required this.rarity,
      required this.constellation,
      required this.birthday,
      required this.description,
      required this.obtain,
      required this.gender,
      required this.imagePortrait,
      required this.imageCard,
      required this.imageWish,
      required this.backgroundColor})
      : super(key: key);

  String name;
  String vision;
  String weapon;
  String nation;
  String affiliation;
  int rarity;
  String constellation;
  String birthday;
  String description;
  String obtain;
  String gender;
  String imagePortrait;
  String imageCard;
  String imageWish;
  Color backgroundColor;

  @override
  State<StatefulWidget> createState() => _CharsDetail();
}

class _CharsDetail extends State<CharsDetail> {
  Color? selectedButtonColor;
  Color? selectedHeartIcon;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: widget.backgroundColor,
                    child: Center(
                      child: Image.network(
                        widget.imageWish,
                        height: MediaQuery.of(context).size.height * 0.4,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white)),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.0,
                  left: 30.0,
                  right: 30.0,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(
                            12.0,
                          ),
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: AppColor.cardGreyColor,
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.angleLeft,
                              color: AppColor.mainTextColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      SvgPicture.asset(
                        'img/svg/menu.svg',
                        height: 40,
                        width: 40,
                        color: AppColor.mainTextColor,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.37,
                  bottom: 0.0,
                  right: 0.0,
                  left: 0.0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 30.0,
                      right: 30.0,
                      bottom: 20.0,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35.0),
                        topRight: Radius.circular(35.0),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.006,
                        ),
                        Text(
                          widget.gender,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: AppColor.secondTextColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.006,
                        ),
                        Text(
                          "Birthday: ${widget.birthday}",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.006,
                        ),
                        Text(
                          "Constellation: ${widget.constellation}",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.006,
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.center,
                              width: 100.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: widget.vision == "Anemo"
                                      ? Colors.greenAccent
                                      : widget.vision == "Hydro"
                                          ? Colors.lightBlueAccent
                                          : widget.vision == "Geo"
                                              ? Colors.amberAccent
                                              : widget.vision == "Electro"
                                                  ? Colors.purpleAccent
                                                  : widget.vision == "Pyro"
                                                      ? Colors.redAccent
                                                      : widget.vision == "Cryo"
                                                          ? Colors.cyanAccent
                                                          : AppColor
                                                              .secondTextColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(
                                      10.0,
                                    ),
                                    topRight: Radius.circular(
                                      10.0,
                                    ),
                                    bottomLeft: Radius.circular(
                                      10.0,
                                    ),
                                    bottomRight: Radius.circular(
                                      10.0,
                                    ),
                                  )),
                              child: Text(
                                widget.vision,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nation:",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                                Text(
                                  widget.nation,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          "Character Description",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.006,
                        ),
                        Text(
                          widget.description,
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 18.0,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Obtain Via",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.006,
                        ),
                        Text(
                          widget.obtain,
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 18.0,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     GestureDetector(
                        //       onTap: () {
                        //         setState(() {
                        //           selectedButtonColor =
                        //               AppColor.yellowBigButtonColor;
                        //           selectedHeartIcon = AppColor.backgroundColor;
                        //         });
                        //       },
                        //       child: Container(
                        //         width: 80.0,
                        //         height: 80.0,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(
                        //             25.0,
                        //           ),
                        //           border: Border.all(
                        //             width: 2.0,
                        //             color: AppColor.yellowBigButtonColor,
                        //           ),
                        //           color: selectedButtonColor ==
                        //                   AppColor.yellowBigButtonColor
                        //               ? AppColor.yellowBigButtonColor
                        //               : AppColor.backgroundColor,
                        //         ),
                        //         child: Center(
                        //           child: FaIcon(
                        //             FontAwesomeIcons.solidHeart,
                        //             size: 40.0,
                        //             color: selectedHeartIcon ==
                        //                     AppColor.backgroundColor
                        //                 ? AppColor.backgroundColor
                        //                 : AppColor.yellowBigButtonColor,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(
                        //       width: 25.0,
                        //     ),
                        //     Expanded(
                        //       child: Container(
                        //         height: 80.0,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(
                        //             30.0,
                        //           ),
                        //           color: AppColor.yellowBigButtonColor,
                        //         ),
                        //         child: const Center(
                        //           child: Text(
                        //             "ADD TO CART",
                        //             style: TextStyle(
                        //               fontSize: 20.0,
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
