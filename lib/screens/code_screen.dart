import 'package:flutter/material.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/model/code_model.dart';
import 'package:genshin_characters/screens/profile_screen.dart';
import 'package:genshin_characters/screens/web_view_screen.dart';
import 'package:genshin_characters/services/data_code_service.dart';
import 'package:genshin_characters/utils/constants_key.dart' as constants_key;
import 'package:genshin_characters/widgets/item_code.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({Key? key}) : super(key: key);

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> with WidgetsBindingObserver {
  List<CodeModel> codeDatas = [];

  bool isAdBannerSuccess = false;

  BannerAd _bannerAd() {
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
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _bannerAd().load();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FRAppBar.defaultAppBar(context, title: 'Redeem Codes', actions: [
        IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            size: 32,
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (builder) => ProfileScreen()));
          },
        ),
      ]),
      body: _mainDataBody(),
      bottomNavigationBar:
          isAdBannerSuccess ? _createBannerAd(_bannerAd()) : null,
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

  Widget _mainDataBody() {
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
                sliver: _buildPopulars(),
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

  Widget _buildPopulars() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(_buildPopularItem,
          childCount: codeDatas.length),
    );
  }

  void _showBottomSheet({required CodeModel data}) {
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
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                          onPressed: () {
                            if (data.code != null) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (builder) =>
                                      WebViewScreen(redeemCode: data.code!)));
                            }
                          },
                          child: const Text('REDEEM NOW')),
                    )
                  ],
                ),
              ),
            ));
  }

  Widget _buildPopularItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showBottomSheet(data: codeDatas[index]);
      },
      child: ItemCode(
        dataModel: codeDatas[index],
      ),
    );
  }
}
