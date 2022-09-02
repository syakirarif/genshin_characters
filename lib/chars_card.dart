import 'package:flutter/material.dart';

import 'colors.dart';

class CharsCard extends StatelessWidget {
  const CharsCard({
    Key? key,
    required this.height,
    required this.customColor,
    required this.customImage,
    required this.customButtonColor,
    required this.charName,
    required this.charVision,
    required this.charNation,
  }) : super(key: key);

  final double height;
  final Color customColor;
  final String customImage;
  final Color customButtonColor;
  final String charName;
  final String charVision;
  final String charNation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 20.0,
      ),
      width: 170.0,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          15.0,
        ),
        color: customColor,
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
                  charName,
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
              charVision,
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
              charNation,
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
            child: Image.network(customImage,
                width: 140, height: 140.0,
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
