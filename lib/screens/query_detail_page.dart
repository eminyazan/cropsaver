import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import '../bases/location_base.dart';
import '../bases/weather_bases/longtime_weather_base.dart';
import '../common/custom_button.dart';
import '../common/loading_screen.dart';
import '../db/database_base.dart';
import '../common/text_widget_for_translation.dart';
import '../repository/api_base.dart';
import 'alerts_screen.dart';

class QueryDetailPage extends StatefulWidget {
  final double lat, lon;
  final String lanCode, name, country,uid;
  final bool fromProfile;

  const QueryDetailPage(
      {Key key,
      @required this.lat,
      @required this.lon,
      @required this.lanCode,
      @required this.name,
      @required this.country,
      @required this.fromProfile,
      this.uid
      })
      : super(key: key);

  @override
  _QueryDetailPageState createState() => _QueryDetailPageState();
}

class _QueryDetailPageState extends State<QueryDetailPage> {
  ApiBase _apiBase = ApiBase();
  Database _database=Database();
  LongTimeWeather _longTimeWeather;
  bool isSaved=false;

  var saveLoc = tr("save_location");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getWeatherData(widget.lat, widget.lon, widget.lanCode);
  }

  @override
  Widget build(BuildContext context) {
    return _longTimeWeather != null
        ? Scaffold(
            appBar: AppBar(
              title: _customAppBar(),
              backgroundColor: Colors.black54,
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
                      _longTimeWeather.alerts.isEmpty != true
                          ? _alertBox()
                          : SizedBox(),
                      SizedBox(
                        height: 20,
                      ),
                      //WeatherBox
                      _weatherBox(),
                      SizedBox(
                        height: 20,
                      ),
                      // Hourly
                      _hourlyWidgets(),
                      SizedBox(
                        height: 20,
                      ),
                      //Daily
                      _dailyWidgets(),
                      SizedBox(
                        height: 30,
                      ),
                      widget.fromProfile
                          ? SizedBox()
                          : isSaved==false?CustomButton(
                              buttonText: saveLoc,
                              height: 47,
                              onPressed: ()=>_saveLocation(),
                              buttonColor: Colors.cyanAccent.shade700,
                              buttonIcon: Icon(Icons.edit_location_outlined,color: Colors.white,size: 30,),
                            ):SizedBox()
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
          child: Text(
            _longTimeWeather.convertStringDateTime(
                _longTimeWeather.currentWeather.dateTime),
            style: TextStyle(fontSize: 15),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundImage: _apiBase
                    .getWeatherIcon(_longTimeWeather.currentWeather.iconCode),
                backgroundColor: Colors.lightBlueAccent.shade100),
            Text(
              " " + _longTimeWeather.currentWeather.description.capitalize,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          _longTimeWeather.currentWeather.temp.toString() + " °C",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TranslateTextWidget(jsonCode: "feels_like", text: ""),
            Text(
              " " + _longTimeWeather.currentWeather.fellsLike.toString() + "°C",
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
                      ": ${_longTimeWeather.currentWeather.windSpeed.toString()} m/s",
                ),
                TranslateTextWidget(
                  jsonCode: "humidity",
                  text:
                      ": ${_longTimeWeather.currentWeather.humidity.toString()}%",
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
                      ":${_longTimeWeather.currentWeather.pressure.toString()} hPa",
                ),
                TranslateTextWidget(
                  jsonCode: "visibility",
                  text:
                      ":${_longTimeWeather.currentWeather.visibility.toString()} m",
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
          itemCount: _longTimeWeather.hourlyWeather.length,
          itemBuilder: (BuildContext ctx, int index) => Card(
            elevation: 10,
            child: Container(
              width: 70,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _convertDtToHours(
                          _longTimeWeather.hourlyWeather[index].dateTime),
                      style: TextStyle(fontSize: 15),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.orangeAccent.shade100,
                      backgroundImage: _apiBase.getWeatherIcon(
                          _longTimeWeather.hourlyWeather[index].iconCode),
                    ),
                    Text(
                      (_longTimeWeather.hourlyWeather[index].temp)
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
          height: Get.mediaQuery.size.height * 0.13,
          initialPage: 1,
          enableInfiniteScroll: false,
          scrollDirection: Axis.horizontal),
      itemCount: _longTimeWeather.dailyWeather.length,
      itemBuilder: (BuildContext ctx, int index, int index2) => Card(
        color: Colors.deepOrange.shade100,
        elevation: 10,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(),
              Text(
                _convertDt(_longTimeWeather.dailyWeather[index].dateTime),
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(),
              Text(
                (_longTimeWeather.dailyWeather[index].maxTemp)
                        .toInt()
                        .toString() +
                    " °C" +
                    " / " +
                    (_longTimeWeather.dailyWeather[index].minTemp)
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
                      _longTimeWeather.dailyWeather[index].iconCode),
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
            alerts: _longTimeWeather.alerts,
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
        Get.back();
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
                    image: _apiBase.getFlag(widget.country),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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

  void _getWeatherData(double lat, double lon, String lanCode) async {
    _longTimeWeather = await _apiBase.getLongTimeWeatherData(lat, lon, lanCode);
    if (_longTimeWeather != null) {
      setState(() {});
    }
  }

  _saveLocation() async{
    Location _location=Location(lat: widget.lat, long: widget.lon, name: widget.name);
      try {
        bool isSaved=await  _database.updateLocation(_location,widget.uid);
        if(isSaved){
          var success = tr("successful");
          var updated = tr("updated_location");
          Get.snackbar(success, updated,backgroundColor: Colors.black,colorText: Colors.white);
          setState(() {
            isSaved=true;
          });
        }else{
          var error = tr("error");
          Get.snackbar("", error);
        }
      }on FirebaseException catch(e){
        print(e.code);
      }
    }
  }

