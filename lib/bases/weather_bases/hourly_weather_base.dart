class HourlyWeather {
  int dateTime,temp;
  String iconCode;
  HourlyWeather.fromJson(Map json){
    this.dateTime=json["dt"];
    this.temp=(json["temp"]).toInt();
    this.iconCode=json["weather"][0]["icon"];
  }
}
