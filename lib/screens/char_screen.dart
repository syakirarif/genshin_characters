import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as root_bundle;
import 'package:genshin_characters/chars_detail.dart';
import 'package:genshin_characters/model/char_model.dart';
import 'package:genshin_characters/model/item_model.dart';
import 'package:genshin_characters/utils/colors.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:genshin_characters/widgets/chars_card_2.dart';
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
    controller.dispose();
    _interstitialAd?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
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
      adUnitId: constants_key.adUnitIdBanner,
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
          setState(() {
            isAdBannerSuccess = false;
          });
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
        floatingActionButton: _myFab(),
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

  Widget _myFab() {
    return FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        label: const Text(
          'Filter',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.filter_alt_outlined,
          color: Colors.white,
        ),
        onPressed: () {
          _showBottomSheet();
        });
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

  bool selected = false;
  final List<ItemModel> _chipsList = [
    ItemModel("Android", Colors.green, false),
    ItemModel("Flutter", Colors.blueGrey, false),
    ItemModel("Ios", Colors.deepOrange, false),
    ItemModel("Python", Colors.cyan, false),
    ItemModel("React JS", Colors.teal, false),
  ];

  List<Widget> filterChipsList(Function newSetState) {
    List<Widget> chips = [];
    for (int i = 0; i < _chipsList.length; i++) {
      Widget item = Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: FilterChip(
          label: Text(_chipsList[i].label),
          labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
          backgroundColor: _chipsList[i].color,
          selected: _chipsList[i].isSelected,
          onSelected: (bool value) {
            newSetState(() {
              _chipsList[i].isSelected = value;
            });
          },
        ),
      );
      chips.add(item);
    }
    return chips;
  }

  void _showBottomSheet() {
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
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Filter',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Wrap(
                          spacing: 0,
                          direction: Axis.horizontal,
                          children: filterChipsList(setState),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Apply Filter')),
                        )
                      ],
                    );
                  },
                ),
              ),
            ));
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
        child: CharsCard2(data: _filteredList[index]));
  }

  void moveToCharsDetailPage(int index) {
    // Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CharsDetail(
            name: _filteredList[index].name.toString(),
            vision: _filteredList[index].vision.toString(),
            weapon: _filteredList[index].weapon.toString(),
            nation: _filteredList[index].nation.toString(),
            affiliation: _filteredList[index].affiliation.toString(),
            rarity: _filteredList[index].rarity!,
            constellation: _filteredList[index].constellation.toString(),
            birthday: _filteredList[index].birthday.toString(),
            description: _filteredList[index].description.toString(),
            obtain: _filteredList[index].obtain.toString(),
            gender: _filteredList[index].gender.toString(),
            imagePortrait: _filteredList[index].imagePortrait.toString(),
            imageCard: _filteredList[index].imageCard.toString(),
            imageWish: _filteredList[index].imageWish.toString(),
            title: _filteredList[index].title.toString(),
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
      adUnitId: constants_key.adUnitIdInterstitial,
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

          // if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
          //   _createInterstitialAd();
          // } else {
          //   setState(() {
          //     isAdInterstitialSuccess = false;
          //   });
          //   // moveToCharsDetailPage(index);
          //   // Navigator.pushAndRemoveUntil(
          //   //   context,
          //   //   MaterialPageRoute(builder: (context) => HomeScreen()),
          //   //       (route) => false,
          //   // );
          // }
        },
      ),
    );
  }

// showLoaderDialog(BuildContext context) {
//   AlertDialog alert = AlertDialog(
//     content: Row(
//       children: [
//         const CircularProgressIndicator(),
//         Container(
//             margin: const EdgeInsets.only(left: 7),
//             child: const Text("Loading...")),
//       ],
//     ),
//   );
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }
}
