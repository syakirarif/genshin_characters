import 'package:flutter/material.dart';
import 'package:genshin_characters/utils/navigation_controls.dart';
import 'package:genshin_characters/utils/navigation_menu.dart';
import 'package:genshin_characters/utils/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({required this.redeemCode, Key? key}) : super(key: key);

  final String redeemCode;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  String webUrl = '';

  @override
  void initState() {
    webUrl = 'https://genshin.hoyoverse.com/en/gift?code=${widget.redeemCode}';
    _controller = WebViewController()
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
      body: WebViewStack(
        controller: _controller,
      ),
      // body: WebViewWidget(
      //   controller: _controller,
      // ),
    );
  }
}
