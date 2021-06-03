import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageBase {
  final FirebaseStorage _firebaseStorage=FirebaseStorage.instance;
  Future<String> uploadPhoto(String userID, String fileName, File image) async {
    String url;
    Reference _storageReference=_firebaseStorage.ref().child(userID).child(fileName).child("profile_photo.png");
    UploadTask _uploadTask= _storageReference.putFile(image,);

    await(await _uploadTask.whenComplete(() async {
      url =await  _storageReference.getDownloadURL();
      print("IMAGE URL  ---> "+url);
    }));
    return url;
  }
}