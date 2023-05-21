import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genshin_characters/screens/home_screen.dart';
import 'package:genshin_characters/utils/firebase_options.dart';
import 'package:genshin_characters/utils/theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // For AdMobs test purpose
  // MobileAds.instance.updateRequestConfiguration(
  //     RequestConfiguration(testDeviceIds: ['6B48649ED223FA9B879ED48941A6D133']));

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
        home: const HomeScreen()
      // home: Scaffold(
      //   body: SafeArea(child: HomeScreen()),
      // ),
    );
  }
}
