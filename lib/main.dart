import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genshin_characters/screens/code_screen_full.dart';
import 'package:genshin_characters/screens/home_screen.dart';
import 'package:genshin_characters/utils/firebase_options.dart';
import 'package:genshin_characters/utils/theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

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

// late AndroidNotificationChannel channelGeneral;
// late AndroidNotificationChannel channelRedeemCode;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

// bool isFlutterLocalNotificationsInitialized = false;

String? selectedNotificationPayload;

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

// Future<void> setupFlutterNotifications() async {
//   if (isFlutterLocalNotificationsInitialized) {
//     return;
//   }
//   channelGeneral = const AndroidNotificationChannel(
//     'general', // id
//     'General Notifications', // title
//     description:
//         'This channel is used for general notifications.', // description
//     importance: Importance.high,
//   );
//
//   channelRedeemCode = const AndroidNotificationChannel(
//     'redeem_code', // id
//     'Redeem Code Notifications', // title
//     description:
//         'This channel is used for redeem code notifications.', // description
//     importance: Importance.high,
//   );
//
//   /// Create an Android Notification Channel.
//   ///
//   /// We use this channel in the `AndroidManifest.xml` file to override the
//   /// default FCM channel to enable heads up notifications.
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channelGeneral);
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channelRedeemCode);
//
//   /// Update the iOS foreground notification presentation options to allow
//   /// heads up notifications.
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   isFlutterLocalNotificationsInitialized = true;
// }

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  // String initialRoute = HomeScreen.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    // initialRoute = SecondPage.routeName;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('assets/icons/app_icon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      final String? payload = notificationResponse.payload;
      if (notificationResponse.payload != null) {
        debugPrint('notification payload: $payload');
      }

      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  AndroidNotificationChannelGroup channelGroup =
      const AndroidNotificationChannelGroup(
          'com.syakirarif.genshin_characters.REDEEM_CODE', 'redeem_code');
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannelGroup(channelGroup);

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _configureSelectNotificationSubject();
    _configureDidReceiveLocalNotificationSubject();
    super.initState();
  }

  void _navigateToCodeFullScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CodeScreenFull(),
      ),
    );
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      debugPrint('selectNotificationStream.listen');
      // await Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (BuildContext context) => const CodeScreenFull(),
      // ));
      _navigateToCodeFullScreen();
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
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => CodeScreenFull(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

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
