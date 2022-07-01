import 'package:flutter/material.dart';

import 'colors.dart';

// ignore: must_be_immutable
class CustomCard extends StatefulWidget {
  CustomCard({
    Key? key,
    required this.height,
    required this.customColor,
    required this.customImage,
    required this.customButtonColor,
    required this.charName,
    required this.charVision,
    required this.charNation,
  }) : super(key: key);

  double height;
  Color customColor;
  String customImage;
  Color customButtonColor;
  String charName;
  String charVision;
  String charNation;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  Color? selectedContainerColor;
  IconData? selectedIcon;
  Color? selectedIconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 20.0,
      ),
      width: 170.0,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          15.0,
        ),
        color: widget.customColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20.0,
              ),
              Flexible(
                  child: Container(
                padding: const EdgeInsets.only(right: 13.0),
                child: Text(
                  widget.charName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColor.mainTextColor,
                  ),
                ),
              )),
              const SizedBox(
                width: 20.0,
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 20.0,
            ),
            child: Text(
              widget.charVision,
              style: TextStyle(
                fontSize: 14.0,
                color: AppColor.mainTextColor,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 20.0,
            ),
            child: Text(
              widget.charNation,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: AppColor.mainTextColor,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Center(
            child: Image.network(widget.customImage, width: 140,
                loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
