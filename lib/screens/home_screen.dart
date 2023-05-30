import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genshin_characters/model/received_notification.dart';
import 'package:genshin_characters/screens/char_screen.dart';
import 'package:genshin_characters/screens/code_screen.dart';
import 'package:genshin_characters/screens/code_screen_full.dart';
import 'package:genshin_characters/screens/daily_checkin_screen.dart';
import 'package:genshin_characters/utils/size_config.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

String? selectedNotificationPayload;

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

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

  final screens = [
    const CharScreen(),
    const CodeScreen(),
    const DailyCheckinScreen()
  ];

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
    const BottomNavigationBarItem(
        icon: Icon(Icons.check_circle_outline_rounded),
        activeIcon: Icon(Icons.check_circle),
        label: 'Daily Check-in'),
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
    // checkPermission();
    //
    // if (!_isAuthorized) {
    //   requestPermission();
    // }

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
          // _resolved = true;
          initialMessage = value?.data.toString();
        },
      ),
    );

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('A new onMessageOpenedApp event was published!');
      debugPrint('RemoteMessage Data: ${message.data}');
      await _navigateToCodeFullScreen();
    });

    if (!kIsWeb) {
      setupFlutterNotifications();
    }

    _configureSelectNotificationSubject();
    _configureDidReceiveLocalNotificationSubject();

    super.initState();
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  Future<void> _navigateToCodeFullScreen() async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CodeScreenFull(),
      ),
    );
  }

  void _configureSelectNotificationSubject() async {
    selectNotificationStream.stream.listen((String? payload) async {
      debugPrint('selectNotificationStream.listen');
      await _navigateToCodeFullScreen();
    });
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      debugPrint('didReceiveLocalNotificationStream.listen');
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await _navigateToCodeFullScreen();
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
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

  final String groupKey = 'com.syakirarif.genshin_characters.REDEEM_CODE';

  void showFlutterNotification(RemoteMessage message) async {
    List<ActiveNotification>? activeNotifications =
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();

    RemoteNotification? notification = message.notification;
    // AndroidNotification? android = message.notification?.android;

    if (activeNotifications != null && activeNotifications.isNotEmpty) {
      List<String> lines =
      activeNotifications.map((e) => e.title.toString()).toList();

      InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        lines,
        contentTitle: "${activeNotifications.length - 1} Updates",
        summaryText: "${activeNotifications.length - 1} Updates",
      );

      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          channelRedeemCode.id, channelRedeemCode.name,
          channelDescription: channelRedeemCode.description,
          styleInformation: inboxStyleInformation,
          icon: 'app_icon',
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey);

      NotificationDetails groupNotificationDetailsPlatformSpefics =
      NotificationDetails(android: androidNotificationDetails);

      if (notification != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          groupNotificationDetailsPlatformSpefics,
        );
      }
    } else {
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          channelRedeemCode.id, channelRedeemCode.name,
          channelDescription: channelRedeemCode.description,
          icon: 'app_icon',
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey);

      NotificationDetails groupNotificationDetailsPlatformSpefics =
      NotificationDetails(android: androidNotificationDetails);

      if (notification != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          groupNotificationDetailsPlatformSpefics,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
