import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genshin_characters/model/code_claimed_model.dart';
import 'package:genshin_characters/model/code_model.dart';

class DataCodeService {
  final _collectionGenshinCodes = FirebaseFirestore.instance
      .collection('games')
      .doc('genshin')
      .collection('codes');

  final _collectionUsers = FirebaseFirestore.instance.collection('users');

  Future markCodeAsClaimed(
      {required String codeId, required String uid, required String email}) {
    return _collectionUsers
        .doc(uid)
        .collection('redeemed_codes')
        .doc(codeId)
        .set({
      'code_id': codeId,
      'uid': uid,
      'email': email,
      'is_claimed': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future deleteMarkAsClaimed({required String codeId, required String uid}) {
    return _collectionUsers
        .doc(uid)
        .collection('redeemed_codes')
        .doc(codeId)
        .delete();
  }

  List<CodeModel> _codeListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      return CodeModel(
          code: data['code'],
          codeId: data['code_id'],
          expirationDate: data['expiration_date'] ?? 'TBD',
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
    return _collectionGenshinCodes
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((event) {
      return _codeListFromSnapshot(event);
    });
  }

  List<CodeClaimedModel> _codeClaimedSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      return CodeClaimedModel(
          codeId: data['code_id'],
          isClaimed: data['is_claimed'],
          uid: data['uid']);
    }).toList();
  }

  Stream<List<CodeClaimedModel>> getClaimedCodes({required String uid}) {
    return _collectionUsers
        .doc(uid)
        .collection('redeemed_codes')
        .snapshots()
        .map((event) {
      return _codeClaimedSnapshot(event);
    });
  }
}
