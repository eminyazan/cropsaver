import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../repository/local_base.dart';
import '../bases/hive_base.dart';
import '../db/database_base.dart';
import '../bases/farmer_base.dart';


class AuthController extends GetxController {
  final _firebaseAuth = FirebaseAuth.instance;
  Database _database = Database();
  Farmer _farmer;
  Box<HiveUser> _authUserBox = Hive.box<HiveUser>(localDB);
  HiveUser _hiveUser;

  Future<Farmer> checkUserAuthState() async {
    if (_firebaseAuth.currentUser == null) {
      print("current user null");
      return null;
    } else {
      _farmer = await _database.readUserDB(_firebaseAuth.currentUser.uid);
      return _farmer;
    }
  }

  Future<Farmer> loginWithEmail(String email, String password) async {
    UserCredential _userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    _farmer = await _database.readUserDB(_userCredential.user.uid);
    if (_farmer != null) {
      _hiveUser = HiveUser(
          uid: _farmer.uid,
          email: _farmer.email,
          username: _farmer.userName,
          profileUrl: _farmer.profileUrl);
      await _authUserBox.put(localDB, _hiveUser);
      return _farmer;
    } else {
      print("farmer null controller login");
      return null;
    }
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
    await _authUserBox.clear();
  }

  Future<Farmer> createUserWithEmail(String email, String password) async {
    UserCredential _userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    _farmer=_userFromFirebase(_userCredential.user);
    bool isCreated = await _database.createUserDB(_farmer);
    if (isCreated) {
      _farmer = await _database.readUserDB(_userCredential.user.uid);
      _hiveUser = HiveUser(
          uid: _farmer.uid,
          email: _farmer.email,
          username: _farmer.userName,
          profileUrl: _farmer.profileUrl);
      await _authUserBox.put(localDB, _hiveUser);
      return _farmer;
    } else {
      return null;
    }
  }

  Farmer _userFromFirebase(User user) {
    Farmer _farmer=Farmer(uid: user.uid, email: user.email);
    return _farmer;
  }
}
