import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/screens/setting_screen.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({Key? key}) : super(key: key);

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen>
    with WidgetsBindingObserver {
  final GlobalKey webViewKey = GlobalKey();

  double progress = 0.0;

  InAppWebViewController? webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;

  bool isAdBannerLoaded = false;
  late BannerAd bannerAd;

  String url =
      'https://act.hoyolab.com/ys/event/signin-sea-v3/index.html?act_id=e202102251931481';

  // String webUrl = 'https://genshin.hoyoverse.com/en/gift';
  String webUrlHoyolabSecurityDone =
      'https://account.hoyolab.com/security.html?complete=1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bannerAd = _initBannerAd();
    bannerAd.load();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
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
      appBar: FRAppBar
          .defaultAppBar(context, title: 'HoYoLAB Daily Check-in', actions: [
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(url: Uri.parse(url)),
                    initialOptions: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {},
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      if (![
                        "http",
                        "https",
                        "file",
                        "chrome",
                        "data",
                        "javascript",
                        "about"
                      ].contains(uri.scheme)) {
                        if (await canLaunchUrl(Uri.parse(url))) {
                          // Launch the App
                          await launchUrl(
                            Uri.parse(url),
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      debugPrint('onLoadStop: $url');
                      pullToRefreshController.endRefreshing();

                      if (url.toString() == webUrlHoyolabSecurityDone) {
                        webViewController?.goBack();
                      }
                      // setState(() {
                      //   this.url = url.toString();
                      //   urlController.text = this.url;
                      // });
                    },
                    onLoadError: (controller, url, code, message) {
                      debugPrint('onLoadError: $url');
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress / 100;
                        // urlController.text = this.url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      debugPrint('onUpdateVisitedHistory: $url');
                      // setState(() {
                      //   this.url = url.toString();
                      //   urlController.text = this.url;
                      // });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      debugPrint('$consoleMessage');
                    },
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: isAdBannerLoaded ? _createBannerAd(bannerAd) : null,
    );
  }
}
