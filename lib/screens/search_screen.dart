import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import '../bases/farmer_base.dart';
import '../bases/location_base.dart';
import '../controller/auth_controller.dart';
import '../db/database_base.dart';
import '../bases/weather_bases/query_weather_base.dart';
import '../screens/query_detail_page.dart';
import '../repository/api_base.dart';

class SearchScreen extends StatefulWidget {
  final String languageCode;

  const SearchScreen({Key key, @required this.languageCode}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textEditingController = TextEditingController();
  bool _searched = false;
  ApiBase _apiBase = ApiBase();
  AuthController _authController = Get.find();
  Database _database = Database();
  Farmer _farmer;
  QueryWeather _queryWeather;
  var search = tr('search_city');
  var cityNotFound = tr("city_not_found");
  var error = tr("error");
  var emptyQuery = tr("empty_query");
  var shortQuery = tr("short_query");
  var save = tr("save");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                autofocus: true,
                controller: _textEditingController,
                validator: (query) {
                  if (query.length == 0) {
                    return emptyQuery;
                  } else if (query.length == 1) {
                    return shortQuery;
                  } else {
                    return null;
                  }
                },
                onFieldSubmitted: (value) {
                  if (value.length == 1 || value.length == 0) {
                    print("value is too short");
                  } else {
                    _getQueryWeatherData();
                  }
                },
                maxLines: 1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: search,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 35,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              _searched == false
                  ? SizedBox()
                  : _queryWeather != null
                  ? GestureDetector(
                onTap: () {
                  _textEditingController.clear();
                  Get.to(
                    QueryDetailPage(
                        lat: _queryWeather.lat,
                        lon: _queryWeather.lon,
                        lanCode: widget.languageCode,
                        name: _queryWeather.name,
                        country: _queryWeather.country,
                        fromProfile: false,
                      uid: _farmer.uid,
                    ),
                  );
                },
                child: Card(
                  elevation: 10,
                  shadowColor: Colors.grey,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 18.0),
                    child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 40,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: _apiBase
                                    .getFlag(_queryWeather.country),
                              ),
                            ),
                          ),
                          Text(
                            _queryWeather.name,
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(),
                          Text(
                            _queryWeather.temp.toString() + " °C",
                            style: TextStyle(fontSize: 15),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: _apiBase.getWeatherIcon(
                                    _queryWeather.iconCode),
                              ),
                            ),
                          ),
                          _farmer != null ? FlatButton.icon(
                            onPressed: () => _addMyLocation(),
                            icon: Icon(
                              Icons.add_location_alt_outlined,
                              size: 20,
                              color: Colors.greenAccent.shade400,
                            ),
                            label: Text(
                              "Save",
                              style: TextStyle(
                                  color: Colors.greenAccent.shade700),
                            ),
                          ) : SizedBox()
                        ]),
                  ),
                ),
              )
                  : Card(
                elevation: 10,
                shadowColor: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                        ),
                        Text(
                          cityNotFound,
                          style: TextStyle(fontSize: 13),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getQueryWeatherData() async {
    _queryWeather = await _apiBase.getQueryWeatherData(
        _textEditingController.text, widget.languageCode);
    _searched = true;
    setState(() {});
  }

  _addMyLocation() async {
    Location _location = Location(lat: _queryWeather.lat,
        long: _queryWeather.lon,
        name: _queryWeather.name);
    if (_farmer != null) {
      _farmer.myLocation = _location;
      try {
       bool isSaved=await  _database.updateLocation(_location, _farmer.uid);
       if(isSaved){
         var success = tr("successful");
         var updated = tr("updated_location");
         Get.snackbar(success, updated,backgroundColor: Colors.black,colorText: Colors.white);
       }else{
         var error = tr("error");
         Get.snackbar("", error);
       }
      }on FirebaseException catch(e){
        print(e.code);
      }
    }
  }

  void _checkUser() async {
    _farmer = await _authController.checkUserAuthState();
  }
}
