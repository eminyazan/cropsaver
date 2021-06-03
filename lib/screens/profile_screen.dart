import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../common/loading_screen.dart';
import '../bases/weather_bases/query_weather_base.dart';
import '../repository/api_base.dart';
import '../screens/query_detail_page.dart';
import '../bases/farmer_base.dart';
import '../bases/hive_base.dart';
import '../common/custom_button.dart';
import '../controller/auth_controller.dart';
import '../db/database_base.dart';
import '../error_manager/errors.dart';
import '../repository/local_base.dart';
import '../screens/home_screen.dart';
import '../bases/location_base.dart';
import '../common/screen_sizes.dart';
import '../screens/search_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String lanCode;
  final Farmer farmer;

  const ProfileScreen({Key key,this.farmer,@required this.lanCode}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File image;
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.put(AuthController());
  ApiBase _apiBase=ApiBase();
  Location _location;
  final ImagePicker picker = ImagePicker();
  TextEditingController _userNameController = TextEditingController();
  Box<HiveUser> _box;
  Database _database = Database();
  bool isLoggingOut = false;


  @override
  void initState() {
    super.initState();
    _box = Hive.box<HiveUser>(localDB);
  }

  var email = tr("email");
  var userName = tr("username");
  var longUserName = tr("long_username");
  var profile = tr("profile");
  var update = tr("update");
  var logout = tr("logout");
  var approve = tr("approve");
  var askLogout = tr("ask_logout");
  var stayLogged = tr("stay_logged");
  var chooseGallery = tr("choose_galley");
  var takePic = tr("pick_image");
  var shortUserName = tr("short_username");
  var emptyLocation = tr("empty_location");
  var cropLoc = tr("your_location");
  var lat = tr("lat");
  var long = tr("long");
  var edit = tr("edit_location");
  var look = tr("look_weather");

  @override
  Widget build(BuildContext context) {
    _userNameController.text = _box.get(localDB).username;
    return isLoggingOut == false?
    Scaffold(
            appBar: AppBar(
              title: Text(profile),
              backgroundColor: Colors.orange,
              actions: [
                FlatButton.icon(
                    onPressed: () => _logOutControl(),
                    icon: Icon(
                      Icons.login_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      logout,
                      style: TextStyle(color: Colors.white),
                    ),),
              ],
            ),
            body:StreamBuilder<DocumentSnapshot>(
                stream: _database.userStream(widget.farmer.uid),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    _location = Location.fromMap(snapshot.data["myLocation"]);
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                return showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: Get.mediaQuery.size.height * 0.15,
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(
                                                Icons.camera_alt,
                                              ),
                                              title: Text(takePic),
                                              onTap: () {
                                                _takePicFromCamera();
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.image),
                                              title: Text(chooseGallery),
                                              onTap: () {
                                                _chooseFromGallery();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Stack(
                                alignment: AlignmentDirectional.bottomEnd,
                                children: [
                                  CircleAvatar(
                                    radius: Get.mediaQuery.size.width * 0.13,
                                    backgroundImage: image == null
                                        ? NetworkImage(
                                      _box.get(localDB).profileUrl,
                                    )
                                        : FileImage(image),
                                  ),
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextFormField(
                                    initialValue: _box.get(localDB).email,
                                    readOnly: true,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: email,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextFormField(
                                    controller: _userNameController,
                                    autofocus: false,
                                    showCursor: true,
                                    enabled: true,
                                    validator: (value) {
                                      if (value.length > 15) {
                                        return longUserName;
                                      } else if (value.length < 4) {
                                        return shortUserName;
                                      } else {
                                        return null;
                                      }
                                    },
                                    onEditingComplete: () {
                                      if (_userNameController.text != "") {
                                        if (_userNameController.text !=
                                            _box.get(localDB).username) {
                                          print(_userNameController.text);
                                        }
                                      } else {}
                                    },
                                    readOnly: false,
                                    decoration: InputDecoration(
                                      labelText: userName,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(15, 25, 15, 15),
                                  child: CustomButton(
                                    buttonText: update,
                                    buttonIcon: Icon(
                                      Icons.send_sharp,
                                      color: Colors.white,
                                    ),
                                    buttonColor: Colors.orange.shade400,
                                    height: 40,
                                    onPressed: () => _updateProfile(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _location.name != null
                              ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 10,
                              color: Colors.greenAccent.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        cropLoc,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        _location.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          lat+_location.lat.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        Text(
                                          long+_location.long.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FlatButton.icon(onPressed: ()=>Get.to(
                                            SearchScreen(
                                              languageCode: widget.lanCode,
                                            ),
                                          ), icon: Icon(Icons.edit_outlined,color: Colors.green.shade900,), label: Text(edit,style: TextStyle(color: Colors.green.shade900),),),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FlatButton.icon(onPressed: ()=>_getLocationWeatherResponse(_location.name), icon: Icon(Icons.cloud_circle_rounded,color: Colors.orange.shade900,), label: Text(look,style: TextStyle(color: Colors.orange.shade900),),),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  SearchScreen(
                                    languageCode: widget.lanCode,
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        emptyLocation,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      "assets/images/location.svg",
                                      height: pageHeight * 0.18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }else{
                    return LoadingScreen();
                  }
                }),
          )
        : LoadingScreen();
  }

  _updateProfile() async {
    var sameInfo = tr("same_info");
    var nameUpdated = tr("username_updated");
    var success = tr("successful");
    var successPhoto = tr("photo_success");
    var nameError = tr("username_error");
    var photoError = tr("photo_error");
    var sending = tr("photo_sending");
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      HiveUser _hiveUser;
      if (image == null &&
          _userNameController.text == _box.get(localDB).username) {
        Get.snackbar("", sameInfo, duration: Duration(seconds: 3));
      } else {
        if (_box.get(localDB).username != _userNameController.text) {
          bool result = await _database.updateUserName(
              _box.get(localDB).uid, _userNameController.text);
          if (result) {
            _hiveUser = HiveUser(
              username: _userNameController.text,
              uid: _box.get(localDB).uid,
              email: _box.get(localDB).email,
              profileUrl: _box.get(localDB).profileUrl,
            );
            await _box.put(localDB, _hiveUser);
            Get.snackbar(success, nameUpdated,
                duration: Duration(seconds: 3),
                snackPosition: SnackPosition.BOTTOM);
          } else {
            Get.snackbar("", nameError,
                duration: Duration(seconds: 3),
                snackPosition: SnackPosition.BOTTOM);
          }
        }
        if (image != null) {
          Get.snackbar("", sending,
              showProgressIndicator: true,
              duration: Duration(seconds: 4),
              snackPosition: SnackPosition.BOTTOM);
          String url = await _database.updatePhotoURL(
              _box.get(localDB).uid, "profile_photo", image);
          if (url != null) {
            _hiveUser = HiveUser(
              username: _box.get(localDB).username,
              uid: _box.get(localDB).uid,
              email: _box.get(localDB).email,
              profileUrl: url,
            );
            await _box.put(localDB, _hiveUser);
            Get.snackbar(success, successPhoto);
          } else {
            Get.snackbar("", photoError);
          }
        }
      }
    }
  }

  Future _chooseFromGallery() async {
    final newImage =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {
      image = File(newImage.path);
    });
    Navigator.pop(context);
  }

  Future _takePicFromCamera() async {
    final newImage =
        await picker.getImage(source: ImageSource.camera, imageQuality: 100);
    setState(() {
      image = File(newImage.path);
    });
    Navigator.pop(context);
  }

  _logOut() async {
    try {
      setState(() {
        isLoggingOut = true;
      });
      await _authController.logOut();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoggingOut = false;
      });
      print(e.code);
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: ErrorManager.show(e.code));
    }
  }

  void _logOutControl() async {
    return showDialog(
      context: (context),
      child: AlertDialog(
        title: Text(approve),
        content: Text(askLogout),
        actions: [
          FlatButton(
            onPressed: () async {
              Navigator.of(
                context,
              ).pop();
              _logOut();
            },
            child: Text(logout),
          ),
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text(stayLogged),
          )
        ],
      ),
    );
  }

  _getLocationWeatherResponse(String name) async{
    QueryWeather _queryWeather=await _apiBase.getQueryWeatherData(name, widget.lanCode);
    if(_queryWeather!=null){
      Get.to(QueryDetailPage(lat: _queryWeather.lat, lon: _queryWeather.lon, lanCode: widget.lanCode, name: _queryWeather.name, country: _queryWeather.country,fromProfile: true,));
    }else{
      var err=tr("error");
      CoolAlert.show(context: context, type: CoolAlertType.error,title: err);
    }
  }


}
