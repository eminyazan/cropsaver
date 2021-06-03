import 'package:flutter/material.dart';

class Location{
  double lat;
  double long;
  String name;
  Location({@required this.lat,@required this.long, @required this.name});

  Location.fromMap(Map map){
    this.name=map["name"];
    this.lat =map["lat"];
    this.long=map["long"];
  }
}