import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

enum _MenuOptions { navigationDelegate }

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({this.controller, required this.url, super.key});

  final InAppWebViewController? controller;

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
          // case _MenuOptions.userAgent:
          //   final userAgent = await widget.controller
          //       .runJavaScriptReturningResult('navigator.userAgent');
          //   if (!mounted) return;
          //   debugPrint('userAgent : $userAgent');
          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //     content: Text('$userAgent'),
          //   ));
          //   break;
        }
      },
      itemBuilder: (context) =>
      [
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.navigationDelegate,
          child: Text('Open in Browser'),
        ),
        // const PopupMenuItem<_MenuOptions>(
        //   value: _MenuOptions.userAgent,
        //   child: Text('Show user-agent'),
        // ),
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
