import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genshin_characters/screens/home_screen.dart';
import 'package:genshin_characters/utils/firebase_options.dart';
import 'package:genshin_characters/utils/theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    // For AdMobs test purpose
    MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: ['6B48649ED223FA9B879ED48941A6D133']));

    await Upgrader.clearSavedSettings();
  } else {
    MobileAds.instance.initialize();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: (Platform.isAndroid || Platform.isIOS)
            ? UpgradeAlert(
                upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.cupertino),
                child: const HomeScreen())
            : const HomeScreen());
  }
}
