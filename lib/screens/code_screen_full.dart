import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/model/code_claimed_model.dart';
import 'package:genshin_characters/model/code_model.dart';
import 'package:genshin_characters/screens/home_screen.dart';
import 'package:genshin_characters/screens/setting_screen.dart';
import 'package:genshin_characters/screens/web_view_screen.dart';
import 'package:genshin_characters/services/data_code_service.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:genshin_characters/widgets/item_code.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CodeScreenFull extends StatefulWidget {
  const CodeScreenFull({Key? key}) : super(key: key);

  @override
  State<CodeScreenFull> createState() => _CodeScreenFullState();
}

class _CodeScreenFullState extends State<CodeScreenFull>
    with WidgetsBindingObserver {
  List<CodeModel> codeDatas = [];

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  bool isAdBannerLoaded = false;
  bool isAdInterstitialLoaded = false;

  late BannerAd bannerAd;

  late User? user;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _createInterstitialAd();
    bannerAd = _initBannerAd();
    bannerAd.load();
    super.initState();
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

  BannerAd _initBannerAd() {
    return BannerAd(
      adUnitId: constants_key.adUnitIdBannerCodesBanner,
      size: AdSize.banner,
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

  void _createInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: constants_key.adUnitIdBannerCodesInterstitial,
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
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => WebViewScreen(redeemCode: data.code!)));
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('UID: ${user?.uid}');

    return WillPopScope(
      onWillPop: () async {
        _navigateToHomeScreen();
        return false;
      },
      child: Scaffold(
        appBar: FRAppBar.appBarWithBack(onLeadingClicked: () {
          _navigateToHomeScreen();
        }, context, title: 'Genshin Codes'),
        body: StreamBuilder(
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
            }),
        bottomNavigationBar:
            isAdBannerLoaded ? _createBannerAd(bannerAd) : null,
      ),
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
                    Text(
                      '${data.code}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('${data.codeDetail}',
                        style: const TextStyle(fontSize: 12)),
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
          child: FilledButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll<Color>(Colors.green.shade700),
              ),
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
                child: FilledButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.black45),
                    ),
                    onPressed: () async {
                      await DataCodeService().markCodeAsClaimed(
                          codeId: data.codeId!, uid: user!.uid);
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

  Widget _sliverListLogin(BuildContext context, int index) {
    return _streamListCode(context, index);
  }

  Widget _sliverListNotLogin(BuildContext context, int index) {
    return _itemCodeNoLogin(index);
  }

  // Widget _buildPopularItem(BuildContext context, int index, bool isLoggedIn) {
  //   if (isLoggedIn) {
  //     return _streamListCode(context, index);
  //   } else {
  //     return _itemCodeNoLogin(index);
  //   }
  //
  //   //   return StreamBuilder(
  //   //       stream: FirebaseAuth.instance.authStateChanges(),
  //   //       builder: (context, authSnapshot) {
  //   //         if (authSnapshot.data != null) {
  //   //           return _streamListCode(context, index);
  //   //         } else {
  //   //           return _itemCodeNoLogin(index);
  //   //         }
  //   //       });
  // }

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
