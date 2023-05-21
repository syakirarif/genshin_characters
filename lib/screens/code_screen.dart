import 'package:flutter/material.dart';
import 'package:genshin_characters/components/app_bar.dart';
import 'package:genshin_characters/model/code_model.dart';
import 'package:genshin_characters/screens/web_view_screen.dart';
import 'package:genshin_characters/services/data_code_service.dart';
import 'package:genshin_characters/widgets/item_code.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({Key? key}) : super(key: key);

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  List<CodeModel> codeDatas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FRAppBar.defaultAppBar(context, title: 'Redeem Codes', actions: [
        IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            size: 32,
          ),
          onPressed: () {},
        ),
      ]),
      body: _mainDataBody(),
    );
  }

  Widget _mainDataBody() {
    const padding = EdgeInsets.fromLTRB(24, 24, 24, 0);
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
                    FilledButton.tonal(
                        onPressed: () {
                          if (data.code != null) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) =>
                                    WebViewScreen(redeemCode: data.code!)));
                          }
                        },
                        child: const Text('REDEEM NOW'))
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
