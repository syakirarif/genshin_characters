import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genshin_characters/model/char_model.dart';
import 'package:genshin_characters/utils/colors.dart';

typedef CharOnTaped = void Function(CharModel data);

class CharsCard2 extends StatelessWidget {
  const CharsCard2({
    required this.data,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final CharModel data;
  final CharOnTaped? onTap;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(16));

    return InkWell(
      borderRadius: borderRadius,
      // onTap: () => onTap?.call(data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: data.rarity == 5 ? AppColor.rarity5 : AppColor.rarity4,
            ),
            child: Stack(
              children: [
                CachedNetworkImage(
                  width: 162,
                  height: 162,
                  imageUrl: data.imagePortrait ?? '',
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  ),
                  errorWidget: (context, url, error) => const Image(
                    image: AssetImage('assets/img_placeholder.png'),
                    fit: BoxFit.scaleDown,
                  ),
                ),
                // Image.asset(data.icon, width: 182, height: 182),
                // Positioned(
                //   top: 16,
                //   right: 16,
                //   child: Image.asset('assets/icons/not_collected@2x.png', width: 28, height: 28),
                // )
              ],
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              '${data.name}',
              style: const TextStyle(
                color: Color(0xFF212121),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _underTheName(),
          // const SizedBox(height: 10),
          // Text(
          //   '\$${data.price.toStringAsFixed(2)}',
          //   style: const TextStyle(
          //       fontSize: 18,
          //       fontWeight: FontWeight.bold,
          //       color: Color(0xFF212121)),
          // )
        ],
      ),
    );
  }

  Widget _underTheName() {
    return Row(
      children: [
        // Image.asset('assets/icons/start@2x.png', width: 20, height: 20),
        Icon(
          Icons.star,
          size: 20,
          color: Colors.yellow.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          '${data.rarity}',
          style: const TextStyle(
            color: Color(0xFF616161),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '|',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF616161),
              fontSize: 14),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: _elementColor(data.vision).withOpacity(0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            '${data.vision}',
            style: const TextStyle(
              color: Color(0xFF35383F),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Color _elementColor(String? vision) {
    return vision == "Anemo"
        ? Colors.greenAccent
        : vision == "Dendro"
            ? Colors.green
            : vision == "Hydro"
                ? Colors.lightBlueAccent
                : vision == "Geo"
                    ? Colors.amberAccent
                    : vision == "Electro"
                        ? Colors.purpleAccent
                        : vision == "Pyro"
                            ? Colors.redAccent
                            : vision == "Cryo"
                                ? Colors.cyanAccent
                                : AppColor.secondTextColor;
  }
}
