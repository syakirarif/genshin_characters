import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/screens/profile_screen.dart';
import 'package:genshin_characters/services/authentication.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:genshin_characters/utils/functions.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

typedef ProfileOptionTap = void Function();

class ProfileOption {
  String title;
  String icon;
  Color? titleColor;

  ProfileOptionTap? onClick;
  Widget? trailing;

  ProfileOption({
    required this.title,
    required this.icon,
    this.onClick,
    this.titleColor,
    this.trailing,
  });

  ProfileOption.arrow({
    required this.title,
    required this.icon,
    this.onClick,
    this.titleColor = const Color(0xFF212121),
    this.trailing = const Image(
        image: AssetImage('assets/icons/profile/arrow_right@2x.png'),
        width: 24,
        height: 24),
  });
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static _profileIcon(String last) => 'assets/icons/profile/$last';

  bool _notificationsGranted = false;

  bool _isSigningOut = false;
  bool _isLoadingSubs = false;
  bool _isLoadingPermission = false;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isSubscribedToRedeemGenshin = false;

  bool isAdBannerLoaded = false;

  late BannerAd bannerAd;

  get datasLoggedIn => <ProfileOption>[
        _permissionOption(),
        _redeemNotif(),
        _shareApp(),
        _buttonLogout(),
      ];

  get datasNotLoggedIn => <ProfileOption>[
        _permissionOption(),
        _redeemNotif(),
        _shareApp(),
      ];

  _redeemNotif() => ProfileOption(
      title: 'Redeem Code Notification',
      icon: _profileIcon('info_square@2x.png'),
      trailing: _isLoadingSubs
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Switch(
              value: isSubscribedToRedeemGenshin,
              activeColor: const Color(0xFF212121),
              onChanged: (value) async {
                setState(() {
                  _isLoadingSubs = true;
                });

                final SharedPreferences prefs = await _prefs;
                if (!isSubscribedToRedeemGenshin) {
                  await FirebaseMessaging.instance
                      .subscribeToTopic('redeem-genshin');
                  prefs.setBool(constants_key.subsRedeemGenshin, true);
                  if (context.mounted) {
                    showSnackBar(
                        context, 'You will receive redeem codes notification.');
                  }
                } else {
                  await FirebaseMessaging.instance
                      .unsubscribeFromTopic('redeem-genshin');
                  prefs.setBool(constants_key.subsRedeemGenshin, false);
                  if (context.mounted) {
                    showSnackBar(context,
                        'You will not receive redeem codes notification anymore.');
                  }
                }

                setState(() {
                  isSubscribedToRedeemGenshin = !isSubscribedToRedeemGenshin;
                  _isLoadingSubs = false;
                });
              },
            ));

  _permissionOption() => ProfileOption(
      title: 'Notification Permission',
      icon: _profileIcon('notification@2x.png'),
      trailing: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _notificationsGranted
                ? const Text(
                    'Allowed',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.blue),
                  )
                : const Text(
                    'Disabled',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.redAccent),
                  ),
            const SizedBox(width: 16),
            _notificationsGranted
                ? Container()
                : Image.asset('assets/icons/profile/arrow_right@2x.png',
                    scale: 2)
          ],
        ),
      ),
      onClick: () async {
        // _notificationsGranted ? null : await _requestPermissions();
        await requestPermission();
      });

  _shareApp() => ProfileOption.arrow(
      title: 'Invite other to use ${constants_key.appName}',
      icon: _profileIcon('user@2x.png'),
      onClick: () {
        const String sentence2 =
            'Hey Travelers, never forget to daily check-in and never miss out claiming redemption codes anymore. Install ${constants_key.appName} app now!\n\nCheckout on Google Play Store: https://play.google.com/store/apps/details?id=com.syakirarif.genshin_characters';
        Share.share(sentence2,
            subject: 'I recommend ${constants_key.appName} app!');
      });

  _buttonLogout() => ProfileOption.arrow(
      title: 'Logout',
      icon: _profileIcon('logout@2x.png'),
      titleColor: const Color(0xFFF75555),
      onClick: () async {
        await showDialog(
            context: context, builder: (builder) => _confirmLogout());
      });

  AlertDialog _confirmLogout() {
    return AlertDialog(
      title: const Text('Logout Confirmation'),
      content: const Text('Are you sure to logout?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              setState(() {
                _isSigningOut = true;
              });
              await Authentication.signOut(context: context);
              setState(() {
                _isSigningOut = false;
              });
            },
            child: const Text('Logout')),
      ],
    );
  }

  @override
  void initState() {
    _checkPermission();
    _checkSubscription();
    bannerAd = _initBannerAd();
    bannerAd.load();
    super.initState();
  }

  Future<void> _checkSubscription() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      isSubscribedToRedeemGenshin =
          (prefs.getBool(constants_key.subsRedeemGenshin) ?? false);
    });
  }

  BannerAd _initBannerAd() {
    return BannerAd(
      adUnitId: constants_key.adUnitIdBannerSettingsBanner,
      size: AdSize.largeBanner,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FRAppBar.defaultAppBar(context, title: 'Settings'),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          bool isLogin = authSnapshot.data != null;

          return _isSigningOut
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.blue,
                ))
              : CustomScrollView(
                  slivers: [
                    const SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: ProfileScreen(),
                        ),
                      ]),
                    ),
                    _buildBody(isLogin),
                  ],
                );
        },
      ),
      bottomNavigationBar: isAdBannerLoaded ? _createBannerAd(bannerAd) : null,
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

  Widget _buildBody(bool isLoggedIn) {
    return SliverPadding(
      padding: const EdgeInsets.all(0),
      sliver: (isLoggedIn) ? _buildListLoggedIn() : _buildListNotLoggedIn(),
    );
  }

  Widget _buildListLoggedIn() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final data = datasLoggedIn[index];
          return _buildOption(context, index, data);
        },
        childCount: datasLoggedIn.length,
      ),
    );
  }

  Widget _buildListNotLoggedIn() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final data = datasNotLoggedIn[index];
          return _buildOption(context, index, data);
        },
        childCount: datasNotLoggedIn.length,
      ),
    );
  }

  Widget _buildOption(BuildContext context, int index, ProfileOption data) {
    return ListTile(
      leading: Image.asset(data.icon, scale: 2),
      title: Text(
        data.title,
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 18, color: data.titleColor),
      ),
      trailing: data.trailing,
      onTap: () {
        data.onClick?.call();
      },
    );
  }

  Future<void> requestPermission() async {
    setState(() {
      _isLoadingPermission = true;
    });

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    setState(() {
      _notificationsGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      _isLoadingPermission = false;
    });

    debugPrint('requestPermission: ${settings.authorizationStatus.toString()}');
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      setState(() {
        _notificationsGranted = granted ?? false;
      });
    }
  }

  Future<void> _checkPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (context.mounted) {
        showSnackBar(
            context, 'Please allow the permission to receive notifications.');
      }
      setState(() {
        _notificationsGranted = false;
      });
    } else {
      setState(() {
        _notificationsGranted = true;
      });
    }
  }
}
