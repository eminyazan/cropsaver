import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../bases/articles_base.dart';
import '../bases/crop_base.dart';
import '../bases/location_base.dart';
import '../repository/storage_base.dart';
import '../bases/farmer_base.dart';

class Database {
  final _fireStore = FirebaseFirestore.instance;
  Farmer _farmer;
  StorageBase _storageBase = StorageBase();

  Future<bool> createUserDB(Farmer farmer) async {
    await _fireStore.collection("farmers").doc(farmer.uid).set(farmer.toMap());
    return true;
  }

  Future<Farmer> readUserDB(String userId) async {
    DocumentSnapshot _snap = await _fireStore.collection("farmers").doc(userId).get();
    _farmer = Farmer.fromMap(_snap.data());
    return _farmer;
  }

  Future<bool> updateUserName(String uid, String userName) async {
    QuerySnapshot _snap = await _fireStore
        .collection("farmers")
        .where("username", isEqualTo: userName)
        .get();
    if (_snap.docs.length >= 1) {
      return false;
    } else {
      await _fireStore
          .collection("farmers")
          .doc(uid)
          .update({"userName": userName});
      await _logUpdatedAt(uid);
      return true;
    }
  }

  Future<String> updatePhotoURL(String uid, String fileName, File image) async {
    String url = await _storageBase.uploadPhoto(uid, fileName, image);
    if (url != null) {
      await _fireStore.collection("farmers").doc(uid).update({
        'profileUrl': url,
      });
      await _logUpdatedAt(uid);
      return url;
    } else {
      print("DATABASE UPDATE NULL");
      return null;
    }
  }

  Future updateLocation(Location location, String uid) async {
    await _fireStore.collection("farmers").doc(uid).update({
      "myLocation.lat": location.lat,
      "myLocation.long": location.long,
      "myLocation.name": location.name
    });
    return true;
  }

  Stream<DocumentSnapshot> userStream(String uid) {
    Stream<DocumentSnapshot> _stream =
        _fireStore.collection("farmers").doc(uid).snapshots();
    return _stream;
  }

  Future<List<Crop>> getCropList() async {
    List<Crop> crops = [];
    if (crops.isEmpty) {
      print("crops empty");
      QuerySnapshot snapshot =
          await _fireStore.collection("crop").orderBy("id").limit(15).get();
      for (QueryDocumentSnapshot snap in snapshot.docs) {
        Crop _crop = Crop.fromMap(snap.data());
        crops.add(_crop);
      }
      return crops;
    } else {
      print("crops isn't empty");
    }
    return crops;
  }

  Future<List<Crop>> loadMoreCrop(int lastId) async {
    List<Crop> crops = [];
    print("load more crop");
    QuerySnapshot snapshot = await _fireStore
        .collection("crop")
        .orderBy("id")
        .startAfter([lastId])
        .limit(15)
        .get();
    for (QueryDocumentSnapshot snap in snapshot.docs) {
      Crop _crop = Crop.fromMap(snap.data());
      crops.add(_crop);
    }
    return crops;
  }

  Future<bool> addToMyCrops(String uid, Crop crop) async {
    DocumentSnapshot snap=await _fireStore.collection("farmers").doc(uid).get();
    Farmer _farmer=Farmer.fromMap(snap.data());
    if(_farmer.myCrops.length<4){
      await _fireStore.collection("farmers").doc(uid).update({
        "myCrops": FieldValue.arrayUnion([{
          "minHeat": crop.minHeat,
          "name": crop.name,
          "id": crop.id,
          "url": crop.url,
          "tr":crop.tr
        }])
      });
      return true;
    }else{
      print("limited crop reached");
      return false;
    }

  }

  void _logUpdatedAt(String uid) async {
    await _fireStore
        .collection("farmers")
        .doc(uid)
        .update({"updatedAt": FieldValue.serverTimestamp()});
    print("updated at changed");
  }

  Future<bool> deleteCrop(String uid, Crop crop) async{
    await _fireStore.collection("farmers").doc(uid).update({
      "myCrops": FieldValue.arrayRemove([{
        "minHeat": crop.minHeat,
        "name": crop.name,
        "id": crop.id,
        "url": crop.url,
        "tr":crop.tr
      }])
    });
    return true;
  }

  Future<List<Article>> getArticles() async{
    List<Article>_articles=[];
    QuerySnapshot snap=await _fireStore.collection("articles").orderBy("id",descending: false).limit(5).get();
    snap.docs.forEach((element) {
      Article article=Article.fromMap(element.data());
      _articles.add(article);
    });
    return _articles;
  }

  Future<List<Article>> loadMoreArticle(int lastArticleId)async{
    List<Article>_moreArticle=[];
    QuerySnapshot snap= await _fireStore.collection("articles").orderBy("id").startAfter([lastArticleId]).limit(5).get();
    snap.docs.forEach((element) {
      Article article=Article.fromMap(element.data());
      _moreArticle.add(article);
    });
    return _moreArticle;
  }

  void updateDeviceToken(String token,String uid) async{
    await _fireStore.collection("farmers").doc(uid).update({
      'deviceToken': token,
    });
     _logUpdatedAt(uid);
  }

  Future<bool> updateLanguage(String uid, String lanCode)async {
    await _fireStore.collection("farmers").doc(uid).update({"language":lanCode});
    return true;
  }



}
