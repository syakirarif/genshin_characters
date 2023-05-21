import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
}

class NavigationMenu extends StatefulWidget {
  const NavigationMenu(
      {required this.controller, required this.url, super.key});

  final WebViewController controller;

  final String url;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
      onSelected: (value) async {
        switch (value) {
          case _MenuOptions.navigationDelegate:
            _launchURL();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.navigationDelegate,
          child: Text('Open in Browser'),
        ),
      ],
    );
  }

  _launchURL() async {
    final Uri url = Uri.parse(widget.url);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
