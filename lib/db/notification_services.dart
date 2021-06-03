import 'package:firebase_messaging/firebase_messaging.dart';

import 'database_base.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging();
  Database _database = Database();


  Future<String> getDeviceToken() async {
    String token = await messaging.getToken();
    return token;
  }

  void saveNewDeviceToken(String token,String uid) async {
    if(uid!=null){
      _database.updateDeviceToken(token,uid);
    }else{
      print("farmer null");
    }

  }


}
