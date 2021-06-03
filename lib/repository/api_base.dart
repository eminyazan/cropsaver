import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../bases/weather_bases/longtime_weather_base.dart';
import '../bases/weather_bases/query_weather_base.dart';

class ApiBase {
  final String _apiKey = "Your OpenWeather API";
  final String _googleMapApi = "Your Google Map API";

  ImageProvider getWeatherIcon(String iconCode) {
    return NetworkImage(
      "https://openweathermap.org/img/wn/$iconCode.png",
    );
  }

  ImageProvider getFlag(String flagCode) {
    return NetworkImage(
      "https://www.countryflags.io/$flagCode/shiny/64.png",
    );
  }

  Future<QueryWeather> getQueryWeatherData(String query, String languageCode) async {
    QueryWeather queryWeather;
    var url="https://api.openweathermap.org/data/2.5/weather?q=$query&appid=$_apiKey&units=metric&lang=$languageCode";
    print(url);
    var response = await http.get(url);
    var body = jsonDecode(response.body);
    if (body["cod"] == 200) {
       queryWeather=QueryWeather.fromJson(body);
      return queryWeather;
    } else if (body["cod"] == "404") {
       return null;
    } else {
      return null;
    }
  }
  Future<LongTimeWeather>getLongTimeWeatherData(double latitude, double longitude, String languageCode) async {
    var url = "https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=$languageCode&exclude=minutely";
    print(url);
    var response = await http.get(url);
    var body = jsonDecode(response.body);
    LongTimeWeather _longTimeWeather=LongTimeWeather.fromJson(body);
    return _longTimeWeather;
  }

  Future<String>getPlaceName(double latitude, double longitude, String languageCode) async {
    String placeName;
    var url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleMapApi&language=$languageCode";
    var response = await http.get(url);
    var body = jsonDecode(response.body);
    List addresses=body["results"][0]["address_components"];
    for(int i=0;i<addresses.length;i++){
      if(addresses[i]["types"][0]=="administrative_area_level_4"){
         placeName=addresses[i]["short_name"];
      }else if(placeName==null){
        if(addresses[i]["types"][0]=="administrative_area_level_1"){
          placeName=addresses[i]["short_name"];
          print("level 1"+placeName);
        }
      }
    }
    if(placeName!=null){
      return placeName;
    }else{
      return null;
    }
  }

  Future<String>getCountryName(double latitude, double longitude, String lanCode)async {
    String countryName;
    var url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleMapApi&language=$lanCode";
    var response = await http.get(url);
    var body = jsonDecode(response.body);
    List addresses=body["results"][0]["address_components"];
    for(int i=0;i<addresses.length;i++){
      if(addresses[i]["types"][0]=="country"){
        countryName=addresses[i]["short_name"];
      }
    }
    if(countryName!=null){
      return countryName;
    }else{
      return null;
    }
  }
}
