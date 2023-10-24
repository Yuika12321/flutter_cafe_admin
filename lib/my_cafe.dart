import 'package:cloud_firestore/cloud_firestore.dart';

class MyCafe {
  var db = FirebaseFirestore.instance;

  Future<bool> insert(
      {required String collectionName,
      required Map<String, dynamic> data}) async {
    try {
      var result = await db.collection(collectionName).add(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> get({
    required String collectionName,
    String? id,
    String? filedName,
    String? filedValue,
  }) async {
    try {
      // 전체 찾기
      if (id == null && filedName == null) {
        return await db.collection(collectionName).get();
      } else if (id != null) {
        // 고유 아이디로 찾아서 리턴
        return await db.collection(collectionName).doc(id).get();
      } else if (filedName != null) {
        // 필드값 갖고 찾기
        return db
            .collection(collectionName)
            .where(filedName, isEqualTo: filedValue)
            .get();
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> delete({required String collectionName, required id}) async {
    try {
      var result = db.collection(collectionName).doc(id).delete;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> update({
    required String collectionName,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await db.collection(collectionName).doc(id).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
