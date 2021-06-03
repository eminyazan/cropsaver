import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'crop_base.dart';
import 'location_base.dart';


class Farmer {
  String uid;
  String email;
  String profileUrl;
  String userName;
  String phoneNumber;
  String language;
  String deviceToken;
  List<Crop> myCrops;
  Location myLocation;
  DateTime createdAt;
  DateTime updatedAt;

  Farmer(
      {this.uid,
      this.email,
      this.userName,
      this.phoneNumber,
      this.profileUrl,
      this.myCrops,
      this.myLocation});

  Farmer.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        email = map['email'],
        userName = map['userName'],
        phoneNumber = map['phoneNumber'],
        deviceToken=map["deviceToken"],
        language=map["language"],
        myCrops = (map['myCrops'] ?? []).map((data) => Crop.fromMap(data)).toList().cast<Crop>(),
        profileUrl = map['profileUrl'],
        myLocation = Location.fromMap(map['myLocation']),
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate();

  Map<String, dynamic> toMap(){
    return {
      "uid": uid,
      "email": email,
      "deviceToken":deviceToken,
      "myCrops": myCrops,
      "language":language??"en",
      "myLocation":myLocation ?? {},
      "phoneNumber": phoneNumber,
      "userName": userName??_splitMailAddress(email),
      "profileUrl": profileUrl ?? "https://firebasestorage.googleapis.com/v0/b/cropreserveapp.appspot.com/o/default_photo%2Ffarmer.jpg?alt=media&token=be4ca471-98c3-4e2a-9e0e-9fcebb1cbfe7",
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
      "updatedAt": updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
  _splitMailAddress(String email) {
    int point = email.indexOf("@");
    String clean = email.substring(0, point);
    String defaultUsername = clean + randomNumberGenerate().toString();
    return defaultUsername;
  }

  int randomNumberGenerate() {
    Random number = Random();
    int random = number.nextInt(9999);
    return random;
  }

}
