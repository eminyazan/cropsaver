import 'package:flutter/material.dart';

class Crop{
 int id;
 String name;
 String url;
 String  tr;
 int minHeat;

  Crop({@required this.id, @required this.name, @required this.url, @required this.tr, @required this.minHeat});

  Crop.fromMap(Map map){
    this.id=map["id"];
    this.name=map["name"];
    this.url=map["url"];
    this.tr=map["tr"];
    this.minHeat=map["minHeat"];
  }
}