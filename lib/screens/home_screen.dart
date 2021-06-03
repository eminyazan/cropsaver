import 'dart:async';

import 'package:flutter/material.dart';

import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../bases/crop_base.dart';
import '../bases/location_base.dart';
import '../screens/no_internet_connection.dart';
import '../db/database_base.dart';
import '../error_manager/errors.dart';
import '../db/notification_services.dart';
import '../common/loading_screen.dart';
import '../screens/articles_screen.dart';
import '../screens/ask_expert_screen.dart';
import '../screens/profile_screen.dart';
import '../common/text_widget_for_translation.dart';
import '../repository/api_base.dart';
import 'Login/login_screen.dart';
import 'alerts_screen.dart';
import 'my_crops_screen.dart';
import 'search_screen.dart';
import '../bases/farmer_base.dart';
import '../bases/weather_bases/longtime_weather_base.dart';
import '../common/screen_sizes.dart';
import '../controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _countryCode;
  String _lanCode;
  bool _isCurrent = false;
  bool _cropAlert = false;
  String _locationName;

  final Connectivity _connectivity = Connectivity();

  ApiBase _apiBase = ApiBase();
  final _authController = Get.put(AuthController());
  Farmer _farmer;
  LongTimeWeather _currentLocationLongTimeWeather, _savedLocLongTimeWeather;

  var profile = tr("profile");

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _getLangCode();
    _getLocationAndData();
    _checkFarmer();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        Get.off(NoInternetScreen());
      } else {
        print("connected");
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
  }

  _getLangCode() {
    final List<Locale> systemLocales = WidgetsBinding.instance.window.locales;
    _lanCode = systemLocales.first.languageCode;
    print("LANCODE ----> " + _lanCode);
  }

  Future<Position> checkPermission() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permission = await Geolocator.requestPermission();
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      return null;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return position;
    }
  }

  Future _getLocationAndData() async {
    Position position = await checkPermission();
    if (position == null) {
      _locationName = "Kargalık";
      _countryCode = "TR";
      _currentLocationLongTimeWeather =
          await _apiBase.getLongTimeWeatherData(39.626360, 35.493925, _lanCode);
      if (_currentLocationLongTimeWeather != null) {
        setState(() {});
      } else {
        print("longtime null");
      }
    } else {
      double latitude = position.latitude;
      double longitude = position.longitude;
      _locationName =
          await _apiBase.getPlaceName(latitude, longitude, _lanCode);
      _countryCode =
          await _apiBase.getCountryName(latitude, longitude, _lanCode);
      if (_locationName != null) {
        _isCurrent = true;
        _currentLocationLongTimeWeather = await _apiBase.getLongTimeWeatherData(
            latitude, longitude, _lanCode);
        if (_currentLocationLongTimeWeather != null) {
          setState(() {});
        } else {
          print("longtime null");
        }
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _locationName != null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green.shade900,
              title: _customAppBar(),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //Middle Page
                      _middlePage(),

                      //Alerts Box
                      _currentLocationLongTimeWeather.alerts.isEmpty != true
                          ? _alertBox()
                          : SizedBox(),

                      //WeatherBox
                      _weatherBox(),

                      // Hourly
                      _hourlyWidgets(),

                      //Daily
                      _dailyWidgets(),

                      Wrap(
                        children: [
                          _myCrops(),
                          _askExpert(),
                          _articles(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        : LoadingScreen();
  }

  Widget _middlePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: AutoSizeText(
            _currentLocationLongTimeWeather.convertStringDateTime(
                _currentLocationLongTimeWeather.currentWeather.dateTime),
            style: TextStyle(fontSize: 15),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundImage: _apiBase.getWeatherIcon(
                    _currentLocationLongTimeWeather.currentWeather.iconCode),
                backgroundColor: Colors.lightBlueAccent.shade100),
            AutoSizeText(
              " " +
                  _currentLocationLongTimeWeather
                      .currentWeather.description.capitalize,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        AutoSizeText(
          _currentLocationLongTimeWeather.currentWeather.temp.toString() +
              " °C",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TranslateTextWidget(jsonCode: "feels_like", text: ""),
            AutoSizeText(
              " " +
                  _currentLocationLongTimeWeather.currentWeather.fellsLike
                      .toString() +
                  "°C",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Container(
        height: 70,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.greenAccent.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                TranslateTextWidget(
                  jsonCode: "wind",
                  text:
                      ": ${_currentLocationLongTimeWeather.currentWeather.windSpeed.toString()} m/s",
                ),
                TranslateTextWidget(
                  jsonCode: "humidity",
                  text:
                      ": ${_currentLocationLongTimeWeather.currentWeather.humidity.toString()}%",
                ),
                SizedBox()
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                TranslateTextWidget(
                  jsonCode: "pressure",
                  text:
                      ":${_currentLocationLongTimeWeather.currentWeather.pressure.toString()} hPa",
                ),
                TranslateTextWidget(
                  jsonCode: "visibility",
                  text:
                      ":${_currentLocationLongTimeWeather.currentWeather.visibility.toString()} m",
                ),
                SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _hourlyWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 5),
      child: SizedBox(
        height: 100.0,
        child: ListView.builder(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: _currentLocationLongTimeWeather.hourlyWeather.length,
          itemBuilder: (BuildContext ctx, int index) => Card(
            elevation: 10,
            child: Container(
              width: 70,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      _convertDtToHours(_currentLocationLongTimeWeather
                          .hourlyWeather[index].dateTime),
                      style: TextStyle(fontSize: 15),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.orangeAccent.shade100,
                      backgroundImage: _apiBase.getWeatherIcon(
                          _currentLocationLongTimeWeather
                              .hourlyWeather[index].iconCode),
                    ),
                    AutoSizeText(
                      (_currentLocationLongTimeWeather
                                  .hourlyWeather[index].temp)
                              .toInt()
                              .toString() +
                          "°C",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dailyWidgets() {
    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 80,
        initialPage: 1,
        enableInfiniteScroll: false,
      ),
      itemCount: _currentLocationLongTimeWeather.dailyWeather.length,
      itemBuilder: (BuildContext ctx, int index, int index2) => Card(
        color: Colors.blueAccent.shade100,
        elevation: 10,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(),
              AutoSizeText(
                _convertDt(_currentLocationLongTimeWeather
                    .dailyWeather[index].dateTime),
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(),
              AutoSizeText(
                (_currentLocationLongTimeWeather.dailyWeather[index].maxTemp)
                        .toInt()
                        .toString() +
                    " °C" +
                    " / " +
                    (_currentLocationLongTimeWeather
                            .dailyWeather[index].minTemp)
                        .toInt()
                        .toString() +
                    " °C",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white30,
                  backgroundImage: _apiBase.getWeatherIcon(
                      _currentLocationLongTimeWeather
                          .dailyWeather[index].iconCode),
                ),
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 0),
      child: InkWell(
        onTap: () => Get.to(
          AlertsScreen(
            alerts: _currentLocationLongTimeWeather.alerts,
          ),
        ),
        child: Container(
          height: 50,
          width: 180,
          decoration: BoxDecoration(
              color: Colors.orangeAccent.shade400,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                ),
                TranslateTextWidget(jsonCode: "national_alerts", text: ""),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customAppBar() {
    return GestureDetector(
      onTap: () {
        Get.to(
          SearchScreen(
            languageCode: _lanCode,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Icon(
                  Icons.search,
                  size: 35,
                ),
              ),
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: _apiBase.getFlag(_countryCode),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: AutoSizeText(
                  _locationName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _isCurrent == true
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 25,
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: TextButton.icon(
              onPressed: () => _checkAuthentication(
                ProfileScreen(
                  lanCode: _lanCode,
                  farmer: _farmer,
                ),
              ),
              icon: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 27,
              ),
              label: AutoSizeText(
                profile,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _convertDt(int dateTime) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(dateTime * 1000, isUtc: false);
    String lastDate = date.toString();
    lastDate = lastDate.substring(0, 10);
    return lastDate;
  }

  String _convertDtToHours(int dateTime) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(dateTime * 1000, isUtc: false);
    String lastDate = date.toString();
    lastDate = lastDate.substring(10, 16);
    if (lastDate.contains("00:00")) {
      lastDate = _convertDt(dateTime);
      lastDate = lastDate.substring(5, 10);
      return lastDate;
    } else {
      return lastDate;
    }
  }

  Widget _myCrops() {
    var crops = tr("crops");
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => _checkAuthentication(
              MyCrops(
                lanCode: _lanCode,
                farmer: _farmer,
                longTimeWeather: _savedLocLongTimeWeather,
              ),
            ),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      crops,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: pageHeight * 0.13,
                    width: pageWidth * 0.85,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/crops.jpg"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _cropAlert
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.red,
                  size: 45,
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget _askExpert() {
    var ask = tr("ask_expert");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => _checkAuthentication(AskExpert()),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  ask,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: pageHeight * 0.12,
                width: pageWidth * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/ask2.jpg"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _articles() {
    var articles = tr("articles");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Get.to(ArticlesScreen(
          lanCode: _lanCode,
        )),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  articles,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: pageHeight * 0.12,
                width: pageWidth * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/article.jpg"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _checkAuthentication(Widget page) async {
    var loginRequired = tr("login_required");
    var login = tr("login");
    var cancel = tr("cancel");
    var title = tr("title");
    if (_farmer == null) {
      await CoolAlert.show(
          context: context,
          type: CoolAlertType.info,
          title: title,
          text: loginRequired,
          confirmBtnText: login,
          cancelBtnText: cancel,
          cancelBtnTextStyle: TextStyle(color: Colors.red),
          showCancelBtn: true,
          onConfirmBtnTap: () {
            Get.back();
            Get.to(LoginScreen());
          });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  _checkFarmer() async {
    _farmer = await _authController.checkUserAuthState();
    if (_farmer == null) {
      print("FARMER CHECKED NULL");
    } else {
      _checkLangCode();
      _checkDeviceToken();
      _checkPotentialDangers(_farmer.myCrops, _farmer.myLocation);
      print("farmer checked " + _farmer.email);
    }
  }

  void _checkDeviceToken() async {
    NotificationService _notify = NotificationService();
    String checkedToken = await _notify.getDeviceToken();
    if (_farmer.deviceToken != checkedToken) {
      _notify.saveNewDeviceToken(checkedToken, _farmer.uid);
    }
  }

  void _checkLangCode() async {
    Database _database = Database();
    var err = tr("error");
    var cancel = tr("cancel");
    var ok = tr("ok");
    if (_lanCode != _farmer.language) {
      try {
        await _database.updateLanguage(_farmer.uid, _lanCode);
      } on FirebaseException catch (e) {
        await CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            title: err,
            text: ErrorManager.show(e.code),
            confirmBtnText: ok,
            cancelBtnText: cancel,
            cancelBtnTextStyle: TextStyle(color: Colors.red),
            showCancelBtn: true,
            onConfirmBtnTap: () {
              Get.back();
            });
      }
    } else {
      print("default language code is en ");
    }
  }

  void _checkPotentialDangers(List<Crop> myCrops, Location myLocation) async {
    _savedLocLongTimeWeather = await _apiBase.getLongTimeWeatherData(
        myLocation.lat, myLocation.long, _lanCode);
    for (int i = 0; i < _savedLocLongTimeWeather.dailyWeather.length; i++) {
      for (int k = 0; k < myCrops.length; k++) {
        if (_savedLocLongTimeWeather.dailyWeather[i].minTemp <
            myCrops[k].minHeat) {
          _cropAlert = true;
          setState(() {});
        } else {
          print("Crops are safe");
        }
      }
    }
  }
}
