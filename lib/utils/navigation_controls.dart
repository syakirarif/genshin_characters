import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls({this.controller, super.key});

  final InAppWebViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            if (controller != null) {
              if (await controller!.canGoBack()) {
                await controller!.goBack();
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
                return;
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            if (controller != null) {
              if (await controller!.canGoForward()) {
                await controller!.goForward();
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
                return;
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () {
            controller?.reload();
          },
        ),
      ],
    );
  }
}
