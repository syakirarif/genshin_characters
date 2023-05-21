import 'package:flutter/material.dart';
import 'package:genshin_characters/utils/navigation_controls.dart';
import 'package:genshin_characters/utils/navigation_menu.dart';
import 'package:genshin_characters/utils/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  final String webUrl =
      'https://genshin.hoyoverse.com/en/gift?code=XT82F8JZS4TR';

  @override
  void initState() {
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
        title: const Text('WebView'),
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
