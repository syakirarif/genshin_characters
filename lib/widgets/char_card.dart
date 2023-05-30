import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genshin_characters/model/char_model.dart';
import 'package:genshin_characters/utils/colors.dart';

typedef CharOnTaped = void Function(CharModel data);

class CharCard extends StatelessWidget {
  const CharCard({
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
                    width: 162,
                    height: 162,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
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
        ],
      ),
    );
  }

  Widget _underTheName() {
    return Row(
      children: [
        // Image.asset('assets/icons/start@2x.png', width: 20, height: 20),
        const Image(
          image: AssetImage('assets/icons/elements/star.webp'),
          height: 20.0,
        ),
        const SizedBox(width: 8),
        Text(
          '${data.rarity}',
          style: const TextStyle(
            color: Color(0xFF101010),
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
          padding: const EdgeInsets.all(0),
          child: Row(children: [
            Image(
              image: AssetImage(
                  'assets/icons/elements/${data.vision?.toLowerCase()}.webp'),
              height: 20.0,
            ),
            const SizedBox(width: 8),
            Text(
              '${data.vision}',
              style: const TextStyle(
                color: Color(0xFF35383F),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
