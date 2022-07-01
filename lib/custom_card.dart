import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'colors.dart';

// ignore: must_be_immutable
class CustomCard extends StatefulWidget {
  CustomCard({
    Key? key,
    required this.height,
    required this.customColor,
    required this.customImage,
    required this.customButtonColor,
    required this.fruitName,
    required this.fruitUnit,
    required this.fruitPrice,
  }) : super(key: key);

  double height;
  Color customColor;
  String customImage;
  Color customButtonColor;
  IconData? plusIcon = FontAwesomeIcons.plus;
  IconData? checkIcon = FontAwesomeIcons.check;
  String fruitName;
  String fruitUnit;
  String fruitPrice;

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
              Text(
                widget.fruitName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainTextColor,
                ),
              ),
              Expanded(
                child: Container(),
              ),
              FaIcon(
                FontAwesomeIcons.ellipsisVertical,
                color: widget.customButtonColor,
                size: 20.0,
              ),
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
              widget.fruitUnit,
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
              widget.fruitPrice,
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
            child: Image.network(
              widget.customImage,
              width: 140,
            ),
          ),
          // const SizedBox(
          //   height: 10.0,
          // ),
          // Expanded(
          //   child: Align(
          //     alignment: Alignment.bottomRight,
          //     child: GestureDetector(
          //       onTap: () {
          //         setState(() {
          //           selectedContainerColor = widget.customButtonColor;
          //           selectedIcon = widget.checkIcon;
          //           selectedIconColor = widget.customColor;
          //         });
          //       },
          //       child: Container(
          //         width: 50.0,
          //         height: 40.0,
          //         decoration: BoxDecoration(
          //           color: selectedContainerColor == widget.customButtonColor
          //               ? widget.customButtonColor
          //               : widget.customColor,
          //           borderRadius: const BorderRadius.only(
          //             topLeft: Radius.circular(
          //               30.0,
          //             ),
          //             bottomRight: Radius.circular(15.0),
          //           ),
          //         ),
          //         child: Icon(
          //           selectedIcon == widget.checkIcon
          //               ? widget.checkIcon
          //               : widget.plusIcon,
          //           size: 15.0,
          //           color: selectedIconColor == widget.customColor
          //               ? widget.customColor
          //               : widget.customButtonColor,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
