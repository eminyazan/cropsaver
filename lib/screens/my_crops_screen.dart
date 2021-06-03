import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';

import '../bases/crop_weather_alert_base.dart';
import '../bases/weather_bases/longtime_weather_base.dart';
import '../error_manager/errors.dart';
import '../screens/choose_from_crops.dart';
import '../bases/crop_base.dart';
import '../bases/farmer_base.dart';
import '../common/custom_button.dart';
import '../common/screen_sizes.dart';
import '../db/database_base.dart';
import 'crop_alert_screen.dart';

class MyCrops extends StatefulWidget {
  final String lanCode;
  final Farmer farmer;
  final LongTimeWeather longTimeWeather;

  const MyCrops(
      {Key key,
      @required this.longTimeWeather,
      @required this.farmer,
      @required this.lanCode})
      : super(key: key);

  @override
  _MyCropsState createState() => _MyCropsState();
}

class _MyCropsState extends State<MyCrops> {
  Database _database = Database();

  List<CropWeatherAlert> _cropAlert=[];

  var crops = tr("crops");
  var empty = tr("empty_crops");
  var add = tr("add_crop");
  var delete = tr("delete_crop");
  var critic = tr("critical_heat");
  var alert = tr("crop_weather_alert");
  var safe = tr("no_weather_alert");

  @override
  void initState() {
    super.initState();
    _checkCropCondition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crops),
        centerTitle: true,
        backgroundColor: Colors.lightGreen.shade700,
      ),
      body: StreamBuilder(
        stream: _database.userStream(widget.farmer.uid),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data["myCrops"]!=null?
                 _showList(snapshot)
                : _emptyList();
          } else {
            return _emptyList();
          }
        },
      ),
    );
  }

  Widget _emptyList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                      empty,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/images/empty.svg",
                    height: pageHeight * 0.25,
                  ),
                ],
              ),
            ),
          ),
          CustomButton(
            buttonText: add,
            height: 50,
            buttonColor: Colors.greenAccent.shade700,
            buttonIcon: Icon(
              Icons.saved_search,
              color: Colors.white,
            ),
            onPressed: () => Get.to(
                ChooseCrops(farmer: widget.farmer, lanCode: widget.lanCode)),
          ),
        ],
      ),
    );
  }

  Widget _showList(AsyncSnapshot<DocumentSnapshot> snapshot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _cropAlert!=null?_cropAlert.isNotEmpty?
          GestureDetector(
            onTap: () {
              Get.to(CropAlertScreen(cropAlerts: _cropAlert,),);
            },
            child: Card(
              elevation: 10,
              child: Container(
                height: pageHeight * 0.1,
                width: pageWidth,
                color: Colors.redAccent,
                child: Center(
                  child: Text(
                    alert,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ):
          Card(
            elevation: 10,
            child: Container(
              height: pageHeight * 0.1,
              width: pageWidth,
              color: Colors.green.shade400,
              child: Center(
                child: Text(
                  safe,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
          ):
          SizedBox(),
          Expanded(
            child: GridView.builder(
              itemCount: snapshot.data["myCrops"].length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemBuilder: (BuildContext ctx, int index) {
                return GestureDetector(
                  onTap: () {
                    return showDialog(
                      context: context,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: pageHeight * 0.3,
                            width: pageWidth * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                image: NetworkImage(
                                    snapshot.data["myCrops"][index]["url"]),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          AlertDialog(
                            title: widget.lanCode == "tr"
                                ? Text(snapshot.data["myCrops"][index]["tr"])
                                : Text(snapshot.data["myCrops"][index]["name"]),
                            content: Text(
                              critic +
                                  snapshot.data["myCrops"][index]["minHeat"]
                                      .toString() +
                                  " °C",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomButton(
                              buttonText: delete,
                              buttonIcon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              buttonColor: Colors.redAccent.shade200,
                              height: 45,
                              onPressed: () {
                                Crop crop = Crop.fromMap(
                                    snapshot.data["myCrops"][index]);
                                _deleteCrop(widget.farmer.uid, crop);
                                Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      elevation: 10,
                      child: Column(
                        children: [
                          widget.lanCode == "tr"
                              ? Text(
                                  snapshot.data["myCrops"][index]["tr"],
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(snapshot.data["myCrops"][index]["name"]),
                          Container(
                            height: pageHeight * 0.15,
                            width: pageWidth * 0.37,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    snapshot.data["myCrops"][index]["url"]),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          snapshot.data["myCrops"].length < 4
              ? CustomButton(
                  buttonText: add,
                  height: 50,
                  buttonColor: Colors.greenAccent.shade700,
                  buttonIcon: Icon(
                    Icons.saved_search,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.to(
                    ChooseCrops(farmer: widget.farmer, lanCode: widget.lanCode),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  void _checkCropCondition() async {
    if (widget.farmer.myLocation != null&&widget.farmer.myCrops!=null) {
      for (int i = 0; i < widget.longTimeWeather.dailyWeather.length; i++) {
        for (int k = 0; k < widget.farmer.myCrops.length; k++) {
          if (widget.longTimeWeather.dailyWeather[i].minTemp < widget.farmer.myCrops[k].minHeat) {
            if (widget.lanCode == "tr") {
              CropWeatherAlert _cropWeatherAlert = CropWeatherAlert(
                  cropName: widget.farmer.myCrops[k].tr,
                  minCropTemp: widget.farmer.myCrops[k].minHeat,
                  expectedTemp: widget.longTimeWeather.dailyWeather[i].minTemp,
                  cropUrl: widget.farmer.myCrops[k].url,
                  dateTime: widget.longTimeWeather.dailyWeather[i].dateTime);
              _cropAlert.add(_cropWeatherAlert);
            } else {
              CropWeatherAlert _cropWeatherAlert = CropWeatherAlert(
                  cropName: widget.farmer.myCrops[k].name,
                  minCropTemp: widget.farmer.myCrops[k].minHeat,
                  cropUrl: widget.farmer.myCrops[k].url,
                  expectedTemp: widget.longTimeWeather.dailyWeather[i].minTemp,
                  dateTime: widget.longTimeWeather.dailyWeather[i].dateTime);
              _cropAlert.add(_cropWeatherAlert);
            }
          }
        }
      }
      setState(() {});
    }else{
      _cropAlert= null;
      setState(() {});
    }
  }

  void _deleteCrop(String uid, Crop crop) async {
    try {
      bool deleted = await _database.deleteCrop(uid, crop);
      if (deleted) {
        var title = tr("successful");
        var message = tr("crop_deleted");
        Get.snackbar(title, message);
      }
    } on FirebaseException catch (e) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: ErrorManager.show(e.code));
    }
  }
}
