import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genshin_characters/utils/constants.dart' as constants;
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'utils/colors.dart';

class CharsDetail extends StatefulWidget {
  const CharsDetail(
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
      required this.title,
      required this.backgroundColor})
      : super(key: key);

  final String name;
  final String vision;
  final String weapon;
  final String nation;
  final String affiliation;
  final int rarity;
  final String constellation;
  final String birthday;
  final String description;
  final String obtain;
  final String gender;
  final String imagePortrait;
  final String imageCard;
  final String imageWish;
  final String title;
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() => _CharsDetail();
}

class _CharsDetail extends State<CharsDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd myBanner = BannerAd(
      // adUnitId: adUnitIdBanner,
      adUnitId: constants_key.adUnitIdBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => {},
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          //print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => {
          //print('Ad opened.')
        },
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => {
          //print('Ad closed.')
        },
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => {
          // print('Ad impression.')
        },
      ),
    );

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    myBanner.load();

    String imgRarity = "";

    if (widget.rarity == 5) {
      imgRarity = constants.imgRarity5;
    } else {
      imgRarity = constants.imgRarity4;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      color: widget.backgroundColor,
                      child: Center(
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.height * 0.4,
                          imageUrl: widget.imageWish,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white)),
                          ),
                          errorWidget: (context, url, error) => const Image(
                            image: AssetImage('assets/img_placeholder.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20.0,
                    left: 20.0,
                    right: 20.0,
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
                    top: MediaQuery.of(context).size.height * 0.36,
                    bottom: 0.0,
                    right: 0.0,
                    left: 0.0,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 20.0,
                        right: 20.0,
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
                      child: SingleChildScrollView(
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
                              height:
                                  MediaQuery.of(context).size.height * 0.006,
                            ),
                            CachedNetworkImage(
                              width: 90.0,
                              height: 30.0,
                              imageUrl: imgRarity,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                              ),
                              errorWidget: (context, url, error) => const Image(
                                image: AssetImage('assets/img_placeholder.png'),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.006,
                            ),
                            Text(
                              widget.gender,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: AppColor.secondTextColor,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.006,
                            ),
                            Text(
                              "Birthday: ${widget.birthday}",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: AppColor.mainTextColor,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.006,
                            ),
                            Text(
                              "Constellation: ${widget.constellation}",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: AppColor.mainTextColor,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.006,
                            ),
                            Text(
                              "Title: ${widget.title}",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: AppColor.mainTextColor,
                              ),
                            ),
                            const SizedBox(
                              height: 25.0,
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
                                          : widget.vision == "Dendro"
                                              ? Colors.green
                                              : widget.vision == "Hydro"
                                                  ? Colors.lightBlueAccent
                                                  : widget.vision == "Geo"
                                                      ? Colors.amberAccent
                                                      : widget.vision ==
                                                              "Electro"
                                                          ? Colors.purpleAccent
                                                          : widget.vision ==
                                                                  "Pyro"
                                                              ? Colors.redAccent
                                                              : widget.vision ==
                                                                      "Cryo"
                                                                  ? Colors
                                                                      .cyanAccent
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
                              height:
                                  MediaQuery.of(context).size.height * 0.006,
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
                              height: 25.0,
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
                              height:
                                  MediaQuery.of(context).size.height * 0.006,
                            ),
                            Text(
                              widget.obtain,
                              style: TextStyle(
                                height: 1.4,
                                fontSize: 18.0,
                                color: AppColor.mainTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
        bottomNavigationBar: adContainer,
      ),
    );
  }
}
