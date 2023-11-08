import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genshin_characters/model/code_claimed_model.dart';
import 'package:genshin_characters/model/code_model.dart';
import 'package:genshin_characters/screens/setting_screen.dart';
import 'package:genshin_characters/screens/web_view_screen.dart';
import 'package:genshin_characters/services/data_code_service.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:genshin_characters/utils/functions.dart';
import 'package:genshin_characters/widgets/item_code.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodeScreenMain extends StatefulWidget {
  const CodeScreenMain({Key? key}) : super(key: key);

  @override
  State<CodeScreenMain> createState() => _CodeScreenMainState();
}

class _CodeScreenMainState extends State<CodeScreenMain>
    with WidgetsBindingObserver {
  List<CodeModel> codeDatas = [];

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  bool isAdInterstitialLoaded = false;

  // bool _notificationsGranted = false;

  late User? user;

  void _createInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: constants_key.adUnitIdInterstitialCodes,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;

          setState(() {
            isAdInterstitialLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;

          setState(() {
            isAdInterstitialLoaded = false;
          });
        },
      ),
    );
  }

  void _showInterstitialAd({required CodeModel data}) {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        moveToRedeemPage(data: data);
        debugPrint('%ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        moveToRedeemPage(data: data);
      },
      onAdImpression: (InterstitialAd ad) =>
          debugPrint('$ad impression occurred.'),
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void moveToRedeemPage({required CodeModel data}) {
    Get.to(WebViewScreen(redeemCode: data.code!));
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (builder) => WebViewScreen(redeemCode: data.code!)));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _createInterstitialAd();
    _checkPermission();
    _checkSubscription();
    super.initState();
  }

  Future<void> _requestPermission() async {
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
      // setState(() {
      //   _notificationsGranted = granted ?? false;
      // });
    }
  }

  Future<void> _checkPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      await _requestPermission();
    }
  }

  Future<void> _checkSubscription() async {
    final Future<SharedPreferences> mPrefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await mPrefs;

    bool isSubscribedToRedeemGenshin =
        (prefs.getBool(constants_key.subsRedeemGenshin) ?? false);

    debugPrint('isSubscribedToRedeemGenshin => ${isSubscribedToRedeemGenshin}');

    if (!isSubscribedToRedeemGenshin) {
      await FirebaseMessaging.instance.subscribeToTopic('redeem-genshin');
      debugPrint('SUBSCIBED AUTOMATICALLY');
      prefs.setBool(constants_key.subsRedeemGenshin, true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _createInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.data != null) {
            user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              return _mainDataBody(true);
            } else {
              return _mainDataBody(false);
            }
          } else {
            return _mainDataBody(false);
          }
        });
  }

  Widget _mainDataBody(bool isLoggedIn) {
    const padding = EdgeInsets.fromLTRB(20, 20, 20, 0);
    return StreamBuilder(
      stream: DataCodeService().codes,
      builder: (context, AsyncSnapshot<List<CodeModel>> toDoSnapshot) {
        if (toDoSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (toDoSnapshot.hasError) {
          return Center(
            child: Text(toDoSnapshot.error.toString()),
          );
        }

        if (toDoSnapshot.data != null) {
          codeDatas = toDoSnapshot.data as List<CodeModel>;
          debugPrint('codeDatas: ${codeDatas.length}');
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: padding,
                sliver: _buildPopulars(isLoggedIn),
              ),
              const SliverAppBar(flexibleSpace: SizedBox(height: 24))
            ],
          );
        } else {
          return const Center(
            child: Text('No Data Available'),
          );
        }
      },
    );
  }

  Widget _buildPopulars(bool isLoggedIn) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
          isLoggedIn ? _sliverListLogin : _sliverListNotLogin,
          childCount: codeDatas.length),
    );
  }

  void _showBottomSheet(
      {required CodeModel data,
      required bool isLoggedIn,
      required bool isNotClaimed}) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
              padding: const EdgeInsets.all(22),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _codeDetail(data: data),
                    const SizedBox(
                      height: 10,
                    ),
                    _builderButtonRedeem(
                        data: data,
                        isLoggedIn: isLoggedIn,
                        isNotClaimed: isNotClaimed),
                  ],
                ),
              ),
            ));
  }

  Widget _codeDetail({required CodeModel data}) {
    String? expDate = data.expirationDate;

    if (expDate != null) {
      if (expDate != 'TBD' && expDate != 'Unknown' && expDate != 'Permanent') {
        DateTime temp = DateTime.parse(expDate);
        expDate = formatDateTime(temp.toLocal());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120.0,
                    height: 25.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(width: 1.0, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        '${data.codeSource}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _shareCode(data);
                      },
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.purple,
                      )),
                ])),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            '${data.code}',
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              codeDetailsWidget('Rewards', '${data.codeDetail}'),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 52.0),
                child: codeDetailsWidget('Expiration Date', '$expDate'),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 32,
        )
      ],
    );
  }

  void _shareCode(CodeModel data) {
    String sentence2 =
        'Hurry claim this ${data.gameName} redemption code!\n\nCode: ${data.code}\nRewards: ${data.codeDetail}\n\nInstall ${constants_key.appName} app and enjoy realtime redemption code information and faster redemption process!';
    Share.share(sentence2, subject: 'New ${data.gameName} Redemption Code!');
  }

  Widget codeDetailsWidget(String firstTitle, String firstDesc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  firstTitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    firstDesc,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _builderButtonRedeem(
      {required CodeModel data,
      required bool isLoggedIn,
      required bool isNotClaimed}) {
    if (isLoggedIn) {
      return _buttonRedeemLogin(data: data, isNotClaimed: isNotClaimed);
    } else {
      return _buttonRedeemNotLogin(data: data, isNotClaimed: isNotClaimed);
    }
  }

  Widget _buttonRedeemNotLogin(
      {required CodeModel data, required bool isNotClaimed}) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (builder) => const SettingScreen()));
              },
              child: const Text(
                'Login to Record Your History',
                textAlign: TextAlign.center,
              )),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: FilledButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (kIsWeb) {
                  moveToRedeemPage(data: data);
                } else {
                  if (Platform.isAndroid || Platform.isIOS) {
                    if (isAdInterstitialLoaded) {
                      _showInterstitialAd(data: data);
                    } else {
                      moveToRedeemPage(data: data);
                    }
                  } else {
                    moveToRedeemPage(data: data);
                  }
                }
              },
              child: const Text('REDEEM NOW')),
        )
      ],
    );
  }

  Widget _buttonRedeemLogin(
      {required CodeModel data, required bool isNotClaimed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        (isNotClaimed)
            ? Expanded(
                child: OutlinedButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (builder) => _confirmClaim(data));
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Mark as Claimed')),
              )
            : const Expanded(
                child: FilledButton(
                onPressed: null,
                child: Text('Already Claimed'),
              )),
        const SizedBox(width: 20),
        Expanded(
          child: FilledButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
              ),
              onPressed: () {
                if (kIsWeb) {
                  moveToRedeemPage(data: data);
                } else {
                  if (Platform.isAndroid || Platform.isIOS) {
                    if (isAdInterstitialLoaded) {
                      _showInterstitialAd(data: data);
                    } else {
                      moveToRedeemPage(data: data);
                    }
                  } else {
                    moveToRedeemPage(data: data);
                  }
                }
              },
              child: const Text('REDEEM NOW')),
        )
      ],
    );
  }

  AlertDialog _confirmClaim(CodeModel data) {
    return AlertDialog(
      title: const Text('Warning'),
      content: const Text('Mark as claimed? This is cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Maybe later')),
        TextButton(
            onPressed: () async {
              await DataCodeService().markCodeAsClaimed(
                  codeId: data.codeId!, uid: user!.uid, email: user!.email!);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Yes, I claimed it')),
      ],
    );
  }

  Widget _sliverListLogin(BuildContext context, int index) {
    return _streamListCode(context, index);
  }

  Widget _sliverListNotLogin(BuildContext context, int index) {
    return _itemCodeNoLogin(index);
  }

  Widget _streamListCode(BuildContext context, int index) {
    if (user != null) {
      return StreamBuilder(
          stream: DataCodeService().getClaimedCodes(uid: user!.uid),
          builder: (context, AsyncSnapshot<List<CodeClaimedModel>> snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const CircularProgressIndicator();
            // }

            if (snapshot.data != null) {
              final listClaimedCodes = snapshot.data as List<CodeClaimedModel>;
              final contain = listClaimedCodes.where(
                  (element) => element.codeId == codeDatas[index].codeId);
              final isNotClaimed = (contain.isEmpty) ? true : false;

              return GestureDetector(
                onTap: () {
                  _showBottomSheet(
                      data: codeDatas[index],
                      isLoggedIn: true,
                      isNotClaimed: isNotClaimed);
                },
                child: ItemCode(
                    dataModel: codeDatas[index], isNotClaimed: isNotClaimed),
              );
            } else {
              return _itemCodeNoLogin(index);
            }
          });
    } else {
      return _itemCodeNoLogin(index);
    }
  }

  Widget _itemCodeNoLogin(int index) {
    return GestureDetector(
      onTap: () {
        _showBottomSheet(
            data: codeDatas[index], isLoggedIn: false, isNotClaimed: true);
      },
      child: ItemCode(dataModel: codeDatas[index], isNotClaimed: true),
    );
  }
}
