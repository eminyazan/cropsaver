import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';

import '../bases/crop_weather_alert_base.dart';
import '../common/screen_sizes.dart';

class CropAlertScreen extends StatefulWidget {
  final List<CropWeatherAlert> cropAlerts;

  const CropAlertScreen({Key key,@required this.cropAlerts}) : super(key: key);
  @override
  _CropAlertScreenState createState() => _CropAlertScreenState();
}

var head = tr("crop_alert_head");
var alert = tr("freeze_alert");

class _CropAlertScreenState extends State<CropAlertScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(head),
        centerTitle: true,
        backgroundColor: Colors.redAccent.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.cropAlerts.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      elevation: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: pageHeight * 0.1,
                            width: pageWidth * 0.25,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                      widget.cropAlerts[index].cropUrl),
                                  fit: BoxFit.fill),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: pageWidth *0.5,
                              child: Column(
                                children: [
                                  AutoSizeText(alert,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                                  AutoSizeText(widget.cropAlerts[index].cropName,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15),),
                                  AutoSizeText(_convertDt(widget.cropAlerts[index].dateTime),style: TextStyle(fontWeight: FontWeight.w300,fontSize: 13),),
                                ],
                              )
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
}
