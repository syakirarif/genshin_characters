import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as root_bundle;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshin_characters/model/char_model.dart';
import 'package:genshin_characters/utils/constants.dart' as constants;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'chars_card.dart';
import 'chars_detail.dart';
import 'utils/colors.dart';

class CharsList extends StatefulWidget {
  const CharsList({
    Key? key,
  }) : super(key: key);

  @override
  State<CharsList> createState() => _CharsList();
}

class _CharsList extends State<CharsList> {
  Widget appBarTitle = const Text("Genshin Characters",
      style: TextStyle(color: Colors.blue, fontSize: 22.0));
  Icon actionIcon = const Icon(Icons.search, color: Colors.blue);

  TextEditingController controller = TextEditingController();

  List<CharModel> charsData = [];
  List<CharModel> _filteredList = [];

  String filter = "";

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  bool isTimeToShow = true;

  @override
  void dispose() {
    controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
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
  Widget build(BuildContext context) {

    final BannerAd myBanner = BannerAd(
      adUnitId: constants.adUnitIdBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
      ),
    );

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    myBanner.load();

    final appTopAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Colors.white,
      title: appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (actionIcon.icon == Icons.search) {
                actionIcon = const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                );
                appBarTitle = TextField(
                  controller: controller,
                  decoration: const InputDecoration(
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
                    style: TextStyle(color: Colors.blue, fontSize: 22.0));
                _filteredList = charsData;
                controller.clear();
              }
            });
          },
        ),
      ],
    );

    if ((filter.isNotEmpty)) {
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

    if (filter.isNotEmpty && _filteredList.isEmpty) {
      return Scaffold(
        appBar: appTopAppBar,
        body: Center(
          child: Text("Character ${filter.toString()} is not found!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blue, fontSize: 22.0)),
        ),
      );
    } else {
      return Scaffold(
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
        bottomNavigationBar: adContainer,
      );
    }
  }

  Widget _generateContainer(int value) {


    void moveToCharsDetailPage(int index) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
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
        print('Warning: attempt to show interstitial before loaded.');
        return;
      }

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          moveToCharsDetailPage(index);
            print('%ad onAdShowedFullScreenContent.');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          moveToCharsDetailPage(index);
        },
        onAdImpression: (InterstitialAd ad) =>
            print('$ad impression occurred.'),
      );

      _interstitialAd!.show();
      _interstitialAd = null;
    }

    void _createInterstitialAd(int index) {
      InterstitialAd.load(
        adUnitId: constants.adUnitIdInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _showInterstitialAd(index);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd(index);
            } else {
              moveToCharsDetailPage(index);
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => HomeScreen()),
              //       (route) => false,
              // );
            }
          },
        ),
      );
    }

    Future<List<CharModel>> readJsonData() async {
      //read json file
      final jsondata = await root_bundle.rootBundle
          .loadString('assets/characters_list.json');
      //decode json data as list
      final list = json.decode(jsondata) as List<dynamic>;

      //map json and initialize using DataModel
      return list.map((e) => CharModel.fromJson(e)).toList();
    }

    showLoaderDialog(BuildContext context) {
      AlertDialog alert = AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(
                margin: const EdgeInsets.only(left: 7),
                child: const Text("Loading...")),
          ],
        ),
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

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

          if ((filter.isEmpty)) {
            _filteredList = charsData;
          }

          return MasonryGridView.count(
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            crossAxisCount: value,
            itemCount: _filteredList.length,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showLoaderDialog(context);
                        _createInterstitialAd(index);
                      },
                      child: CharsCard(
                        height: _filteredList[index].name.toString().length > 14
                            ? 270
                            : 250,
                        customColor: _filteredList[index].rarity == 5
                            ? AppColor.rarity5
                            : AppColor.rarity4,
                        customImage:
                            _filteredList[index].imagePortrait.toString(),
                        customButtonColor: AppColor.peachButtonColor,
                        charName: _filteredList[index].name.toString(),
                        charVision: _filteredList[index].vision.toString(),
                        charNation: _filteredList[index].nation.toString(),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
