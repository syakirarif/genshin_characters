import 'package:flutter/material.dart';
import 'package:genshin_characters/utils/navigation_controls.dart';
import 'package:genshin_characters/utils/navigation_menu.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({required this.redeemCode, Key? key}) : super(key: key);

  final String redeemCode;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  late final PlatformWebViewControllerCreationParams params;

  String webUrl = '';
  String webUrlSecurityDone =
      'https://account.hoyoverse.com/security.html?complete=1';

  var loadingPercentage = 0;

  @override
  void initState() {
    webUrl = 'https://genshin.hoyoverse.com/en/gift?code=${widget.redeemCode}';

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
          if (url == webUrlSecurityDone) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          NavigationControls(controller: _controller),
          NavigationMenu(
            controller: _controller,
            url: webUrl,
          )
        ],
      ),
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
    );
  }
}
