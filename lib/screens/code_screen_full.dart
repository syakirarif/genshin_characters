import 'package:flutter/material.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/screens/code_screen_main.dart';
import 'package:genshin_characters/screens/home_screen.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CodeScreenFull extends StatefulWidget {
  const CodeScreenFull({Key? key}) : super(key: key);

  @override
  State<CodeScreenFull> createState() => _CodeScreenFullState();
}

class _CodeScreenFullState extends State<CodeScreenFull>
    with WidgetsBindingObserver {
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
      adUnitId: constants_key.adUnitIdBannerCodes,
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

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
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

    return WillPopScope(
      onWillPop: () async {
        _navigateToHomeScreen();
        return false;
      },
      child: Scaffold(
        appBar: FRAppBar.appBarWithBack(onLeadingClicked: () {
          _navigateToHomeScreen();
        }, context, title: 'Genshin Codes'),
        body: const CodeScreenMain(),
        bottomNavigationBar:
            isAdBannerLoaded ? _createBannerAd(bannerAd) : null,
      ),
    );
  }
}
