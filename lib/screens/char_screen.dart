import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as root_bundle;
import 'package:genshin_characters/model/char_model.dart';
import 'package:genshin_characters/screens/char_detail_screen.dart';
import 'package:genshin_characters/utils/colors.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:genshin_characters/widgets/char_card.dart';
import 'package:genshin_characters/widgets/filter_category.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CharScreen extends StatefulWidget {
  const CharScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CharScreen> createState() => _CharScreen();
}

class _CharScreen extends State<CharScreen> with WidgetsBindingObserver {
  Widget appBarTitle = const Text("Genshin Characters",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Color(0xFF212121),
      ));
  Icon actionIcon = const Icon(Icons.search);

  TextEditingController controller = TextEditingController();

  List<CharModel> charsData = [];
  List<CharModel> _filteredList = [];
  List<CharModel> filteredCharList = [];

  String filter = "";
  bool isFilterCategory = false;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  bool isTimeToShow = true;
  bool isAdBannerSuccess = false;
  bool isAdInterstitialSuccess = false;

  late BannerAd bannerAd;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    bannerAd = _initBannerAd();
    bannerAd.load();
    _createInterstitialAd();
    controller.addListener(() {
      if (controller.text.isEmpty) {
        setState(() {
          filter = "";
          _filteredList = charsData;
        });
      } else {
        setState(() {
          filter = controller.text;
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _createInterstitialAd();
    }
  }

  BannerAd _initBannerAd() {
    return BannerAd(
      adUnitId: constants_key.adUnitIdBannerChars,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          setState(() {
            isAdBannerSuccess = true;
          });
          // print('Ad loaded.')
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          // setState(() {
          //   isAdBannerSuccess = false;
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
    final appTopAppBar = AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      title: appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              isFilterCategory = false;
              if (actionIcon.icon == Icons.search) {
                actionIcon = const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                );
                appBarTitle = TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                    hintText: "Search Name...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 20.0),
                  ),
                  style: const TextStyle(color: Colors.blue, fontSize: 20.0),
                  autofocus: true,
                  cursorColor: Colors.black,
                );
              } else {
                actionIcon = const Icon(
                  Icons.search,
                  color: Colors.blue,
                );
                appBarTitle = const Text("Genshin Characters",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xFF212121),
                    ));
                _filteredList = charsData;
                controller.clear();
              }
            });
          },
        ),
      ],
    );

    if (filter.isNotEmpty && !isFilterCategory) {
      List<CharModel> tmpListChar = <CharModel>[];
      for (int i = 0; i < _filteredList.length; i++) {
        if (_filteredList[i]
            .name!
            .toLowerCase()
            .contains(filter.toLowerCase())) {
          tmpListChar.add(_filteredList[i]);
        }
      }
      _filteredList = tmpListChar;
    }

    if (isFilterCategory) {
      if (filteredCharList.isNotEmpty) {
        _filteredList = filteredCharList.toSet().toList();
      } else {
        _filteredList = charsData;
      }
    }

    if (filter.isNotEmpty && _filteredList.isEmpty && !isFilterCategory) {
      return Scaffold(
        appBar: appTopAppBar,
        body: Center(
          child: Text("Character ${filter.toString()} is not found!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blue, fontSize: 22.0)),
        ),
        bottomNavigationBar:
            isAdBannerSuccess ? _createBannerAd(bannerAd) : null,
      );
    } else {
      return Scaffold(
        // floatingActionButton: _myFab(),
        appBar: appTopAppBar,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 600) {
              return _generateContainer(2);
            } else if (constraints.maxWidth < 900) {
              return _generateContainer(4);
            } else {
              return _generateContainer(6);
            }
          },
        ),
        bottomNavigationBar:
            isAdBannerSuccess ? _createBannerAd(bannerAd) : null,
      );
    }
  }

  List<CharModel> getBasedOnRarity(List<CharModel> inputList, String rarity) {
    List<CharModel> outputList = inputList
        .where((element) => element.rarity.toString().toLowerCase() == rarity)
        .toList();
    return outputList;
  }

  List<CharModel> getBasedOnVision(List<CharModel> inputList, String vision) {
    List<CharModel> outputList = inputList
        .where((element) => element.vision.toString().toLowerCase() == vision)
        .toList();
    return outputList;
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

  void _onTapFilterCategory(String idCategory) {
    if (idCategory != 'all') {
      if (idCategory == '4' || idCategory == '5') {
        filteredCharList = getBasedOnRarity(charsData, idCategory);
      } else {
        filteredCharList = getBasedOnVision(charsData, idCategory);
      }
    } else {
      filteredCharList.clear();
    }

    setState(() {
      isFilterCategory = true;
    });
  }

  Widget _generateContainer(int value) {
    Future<List<CharModel>> readJsonData() async {
      //read json file
      final jsondata = await root_bundle.rootBundle
          .loadString('assets/characters_list.json');
      //decode json data as list
      final list = json.decode(jsondata) as List<dynamic>;

      //map json and initialize using DataModel
      return list.map((e) => CharModel.fromJson(e)).toList();
    }

    const padding = EdgeInsets.fromLTRB(24, 24, 24, 0);

    return Center(
      child: FutureBuilder(
        future: readJsonData(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            charsData = snapshot.data as List<CharModel>;
          } else {
            return const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            );
          }

          if (filter.isEmpty && !isFilterCategory) {
            _filteredList = charsData;
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 24, left: 12, right: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    ((context, index) => CharFilterCategory(
                          onTapFunction: _onTapFilterCategory,
                        )),
                    childCount: 1,
                  ),
                ),
              ),
              SliverPadding(
                padding: padding,
                sliver: _buildChars(_filteredList.length),
              ),
              const SliverAppBar(flexibleSpace: SizedBox(height: 24))
            ],
          );
        },
      ),
    );
  }

  Widget _buildChars(int count) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 185,
        mainAxisSpacing: 12,
        crossAxisSpacing: 16,
        mainAxisExtent: 260,
      ),
      delegate: SliverChildBuilderDelegate(_buildCharItem, childCount: count),
    );
  }

  Widget _buildCharItem(BuildContext context, int index) {
    return GestureDetector(
        onTap: () {
          // showLoaderDialog(context);
          if (kIsWeb) {
            moveToCharsDetailPage(index);
          } else {
            if (Platform.isAndroid || Platform.isIOS) {
              if (isAdInterstitialSuccess) {
                _showInterstitialAd(index);
              } else {
                moveToCharsDetailPage(index);
              }
              // await _createInterstitialAd(index);
            } else {
              moveToCharsDetailPage(index);
            }
          }
        },
        child: CharCard(data: _filteredList[index]));
  }

  void moveToCharsDetailPage(int index) {
    // Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CharDetailScreen(
            charModel: _filteredList[index],
            backgroundColor: _filteredList[index].rarity == 5
                ? AppColor.rarity5
                : AppColor.rarity4)));
  }

  void _showInterstitialAd(int index) {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        moveToCharsDetailPage(index);
        debugPrint('%ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        moveToCharsDetailPage(index);
      },
      onAdImpression: (InterstitialAd ad) =>
          debugPrint('$ad impression occurred.'),
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: constants_key.adUnitIdInterstitialChars,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;

          // _showInterstitialAd(index);
          setState(() {
            isAdInterstitialSuccess = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;

          setState(() {
            isAdInterstitialSuccess = false;
          });
        },
      ),
    );
  }
}
