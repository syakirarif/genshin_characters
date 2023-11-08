import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genshin_characters/getx/controllers/detail_controller.dart';
import 'package:genshin_characters/model/char_model.dart';
import 'package:genshin_characters/utils/constants.dart' as constants;
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/colors.dart';

class CharDetailScreen extends StatefulWidget {
  const CharDetailScreen(
      {Key? key, required this.charModel, required this.backgroundColor})
      : super(key: key);

  final Color backgroundColor;

  final CharModel charModel;

  @override
  State<StatefulWidget> createState() => _CharsDetail();
}

class _CharsDetail extends State<CharDetailScreen> {
  bool isAdBannerSuccess = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextStyle _textStyle() {
    return TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 16.0,
      color: AppColor.mainTextColor,
    );
  }

  TextStyle _textStyleTitle() {
    return TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: AppColor.mainTextColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DetailController controller = Get.put(DetailController());

    final BannerAd myBanner = BannerAd(
      // adUnitId: adUnitIdBanner,
      adUnitId: constants_key.adUnitIdBannerCharsDetail,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          setState(() {
            isAdBannerSuccess = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          setState(() {
            isAdBannerSuccess = false;
          });
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

    myBanner.load();

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    String imgRarity = "";

    if (widget.charModel.rarity == 5) {
      imgRarity = constants.imgRarity5;
    } else {
      imgRarity = constants.imgRarity4;
    }
    return Scaffold(
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
                        imageUrl: widget.charModel.imageWish ?? '',
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
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
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            widget.charModel.name ?? '',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: AppColor.mainTextColor,
                            ),
                          ),
                          Row(
                            children: [
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
                                errorWidget: (context, url, error) =>
                                    const Image(
                                  image:
                                      AssetImage('assets/img_placeholder.png'),
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                              Expanded(child: Container()),
                              Container(
                                alignment: AlignmentDirectional.center,
                                width: 100.0,
                                height: 50.0,
                                child: Row(children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/icons/elements/${widget.charModel.vision?.toLowerCase()}.webp'),
                                    height: 20.0,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.charModel.vision ?? '',
                                    style: _textStyle(),
                                  ),
                                ]),
                              )
                            ],
                          ),
                          Text(
                            widget.charModel.gender ?? '',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 20.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Birthday', style: _textStyleTitle()),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                    Text('${widget.charModel.birthday}',
                                        style: _textStyle()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nation', style: _textStyleTitle()),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                    Text('${widget.charModel.nation}',
                                        style: _textStyle()),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Title', style: _textStyleTitle()),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                    Text('${widget.charModel.title}',
                                        style: _textStyle()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Constellation',
                                        style: _textStyleTitle()),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                    Text('${widget.charModel.constellation}',
                                        style: _textStyle()),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          Text(
                            "Character Description",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: AppColor.mainTextColor,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.006,
                          ),
                          Text(
                            widget.charModel.description ?? '',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              height: 1.4,
                              fontSize: 16.0,
                              color: AppColor.mainTextColor,
                            ),
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          Text(
                            "Obtain Via",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: AppColor.mainTextColor,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.006,
                          ),
                          Text(
                            widget.charModel.obtain ?? '',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              height: 1.4,
                              fontSize: 16.0,
                              color: AppColor.mainTextColor,
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
      bottomNavigationBar: isAdBannerSuccess ? adContainer : null,
    );
  }
}
