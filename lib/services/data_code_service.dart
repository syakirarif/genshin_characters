import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genshin_characters/model/code_model.dart';

class DataCodeService {
  final _collectionGenshinCodes = FirebaseFirestore.instance
      .collection('games')
      .doc('genshin')
      .collection('codes');

  List<CodeModel> _codeListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      return CodeModel(
          code: data['code'],
          codeId: data['code_id'],
          expirationDate: DateTime.parse(data['expiration_date']),
          gameId: data['game_id'],
          gameName: data['game_name'],
          codeDetail: data['code_detail'],
          codeSource: data['code_source'],
          isActive: data['is_active'],
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null);
    }).toList();
  }

  Stream<List<CodeModel>> get codes {
    return _collectionGenshinCodes.snapshots().map((event) {
      return _codeListFromSnapshot(event);
    });
  }
}
