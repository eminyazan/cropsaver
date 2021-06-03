import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../bases/weather_bases/alerts_base.dart';
import '../common/text_widget_for_translation.dart';

class AlertsScreen extends StatefulWidget {
  final List<WeatherAlerts> alerts;

  const AlertsScreen({Key key, @required this.alerts}) : super(key: key);

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String startTime, endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          leading: GestureDetector(
            onTap: ()=>Get.back(),
            child: Icon(
              Icons.arrow_back_sharp,
              color: Colors.white,
            ),
          ),
          title: TranslateTextWidget(
            jsonCode: "national_alerts",
            text: "",
          ),
          centerTitle: false,
        ),
        body: ListView.builder(
          itemCount: widget.alerts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AutoSizeText(
                          widget.alerts[index].event,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TranslateTextWidget(
                              jsonCode: "starts",
                              text: convertDateTime(widget.alerts[index].start)),
                          SizedBox(),
                          TranslateTextWidget(
                              jsonCode: "ends",
                              text: convertDateTime(widget.alerts[index].end)),
                        ],
                      ),
                      widget.alerts[index].description != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(widget.alerts[index].description),
                            )
                          : SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TranslateTextWidget(
                            jsonCode: "sender",
                              text: widget.alerts[index].senderName),
                      ),
                    ],
                  ),),
            );
          },
        ),);
  }

  String convertDateTime(int datetime) {
    var date = DateTime.fromMillisecondsSinceEpoch(datetime * 1000, isUtc: false);
    String lastDate = date.toString();
    lastDate = lastDate.substring(0, 16);
    return lastDate;
  }
}
