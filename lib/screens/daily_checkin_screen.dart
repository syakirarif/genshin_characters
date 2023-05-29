import 'package:flutter/material.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({Key? key}) : super(key: key);

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen>
    with WidgetsBindingObserver {
  late final WebViewController _controller;

  bool isAdBannerLoaded = false;
  late BannerAd bannerAd;

  String webUrl =
      'https://act.hoyolab.com/ys/event/signin-sea-v3/index.html?act_id=e202102251931481';

  // String webUrl = 'https://genshin.hoyoverse.com/en/gift';
  String webUrlHoyolabSecurityDone =
      'https://account.hoyolab.com/security.html?complete=1';

  var loadingPercentage = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    bannerAd = _initBannerAd();
    bannerAd.load();
    _controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          debugPrint('onPageFinished: $url');
          if (url == webUrlHoyolabSecurityDone) {
            _controller.goBack();
          }
          setState(() {
            loadingPercentage = 100;
          });
        },
      ))
      // ..setUserAgent('Version/4.0')
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(webUrl),
      );
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  BannerAd _initBannerAd() {
    return BannerAd(
      adUnitId: constants_key.adUnitIdBannerCheckin,
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
    return Scaffold(
      appBar: FRAppBar.defaultAppBar(context, title: 'Daily Check-in'),
      // body: WebViewStack(
      //   controller: _controller,
      // ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
      bottomNavigationBar: isAdBannerLoaded ? _createBannerAd(bannerAd) : null,
    );
  }
}
