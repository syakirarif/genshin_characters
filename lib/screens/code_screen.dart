import 'package:flutter/material.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/screens/code_screen_main.dart';
import 'package:genshin_characters/screens/setting_screen.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({Key? key}) : super(key: key);

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> with WidgetsBindingObserver {
  bool isAdBannerLoaded = false;

  late BannerAd bannerAd;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    bannerAd = _initBannerAd();
    bannerAd.load();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  BannerAd _initBannerAd() {
    return BannerAd(
      adUnitId: constants_key.adUnitIdBannerCodesBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          setState(() {
            isAdBannerLoaded = true;
          });
          // print('Ad loaded.')
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          // setState(() {
          //   isAdBannerLoaded = false;
          // });
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
  }

  Widget _createBannerAd(BannerAd myBanner) {
    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    return adContainer;
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('UID: ${user?.uid}');

    return Scaffold(
      appBar: FRAppBar.defaultAppBar(context, title: 'Genshin Codes', actions: [
        IconButton(
          icon: const Icon(
            Icons.settings,
            size: 32,
          ),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (builder) => const SettingScreen()));
          },
        ),
      ]),
      body: const CodeScreenMain(),
      bottomNavigationBar: isAdBannerLoaded ? _createBannerAd(bannerAd) : null,
    );
  }
}
