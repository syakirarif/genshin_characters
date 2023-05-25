import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genshin_characters/screens/char_screen.dart';
import 'package:genshin_characters/screens/code_screen.dart';
import 'package:genshin_characters/utils/image_loader.dart';
import 'package:genshin_characters/utils/size_config.dart';

class TabbarItem {
  final IconData lightIcon;
  final IconData boldIcon;
  final String label;

  TabbarItem({required this.lightIcon, required this.boldIcon, required this.label});

  BottomNavigationBarItem item(bool isBold) {
    return BottomNavigationBarItem(
        // icon: ImageLoader.imageAsset(isBold ? boldIcon : lightIcon),
        icon: ImageLoader.imageIcon(isBold ? boldIcon : lightIcon),
        label: label);
  }

  BottomNavigationBarItem get light => item(false);

  BottomNavigationBarItem get bold => item(true);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _select = 0;

  String? initialMessage;
  bool _resolved = false;

  final screens = [const CharScreen(), const CodeScreen()];

  // late AndroidNotificationChannel channel;

  final List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
        icon: Icon(Icons.group_outlined),
        activeIcon: Icon(Icons.group),
        label: 'Characters'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.redeem_outlined),
        activeIcon: Icon(Icons.redeem),
        label: 'Redeem Codes'),
  ];

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  bool _notificationsEnabled = false;
  bool _isAuthorized = false;
  bool isFlutterLocalNotificationsInitialized = false;

  late AndroidNotificationChannel channelGeneral;
  late AndroidNotificationChannel channelRedeemCode;

  @override
  void initState() {
    checkPermission();

    if (!_isAuthorized) {
      requestPermission();
    }

    // requestPermission();

    // await FirebaseMessaging.instance.requestPermission(
    //   announcement: true,
    //   carPlay: true,
    //   criticalAlert: true,
    // );

    // _isAndroidPermissionGranted();
    // _requestPermissions();

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
              // _resolved = true;
              initialMessage = value?.data.toString();
            },
          ),
        );

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      debugPrint('RemoteMessage Data: ${message.data}');
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });

    if (!kIsWeb) {
      setupFlutterNotifications();
    }

    super.initState();
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channelGeneral = const AndroidNotificationChannel(
      'general', // id
      'General Notifications', // title
      description:
          'This channel is used for general notifications.', // description
      importance: Importance.high,
    );

    channelRedeemCode = const AndroidNotificationChannel(
      'redeem_code', // id
      'Redeem Code Notifications', // title
      description:
          'This channel is used for redeem code notifications.', // description
      importance: Importance.high,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channelGeneral);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channelRedeemCode);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    const String groupKey = 'com.syakirarif.genshin_characters.REDEEM_CODE';

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelRedeemCode.id, channelRedeemCode.name,
            channelDescription: channelRedeemCode.description,
            // icon: 'ic_stat_extension',
            importance: Importance.max,
            priority: Priority.high,
            groupKey: groupKey);

    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: androidNotificationDetails,
        ),
      );
    }
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> checkPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    debugPrint(
        'AuthorizationStatus: ${settings.authorizationStatus.toString()}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      setState(() {
        _isAuthorized = false;
      });
    } else {
      setState(() {
        _isAuthorized = true;
      });
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

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
        _notificationsEnabled = granted ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('notifications enabled: $_notificationsEnabled');

    SizeConfig().init(context);
    return Scaffold(
      body: screens[_select],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        onTap: ((value) => setState(() => _select = value)),
        currentIndex: _select,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        showUnselectedLabels: true,
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
        selectedItemColor: const Color(0xFF212121),
        unselectedItemColor: const Color(0xFF9E9E9E),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _requestPermissions();
          },
          child: Text('test')),
    );
  }
}
