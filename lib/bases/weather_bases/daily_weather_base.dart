

class DailyWeather {
int dateTime,maxTemp,minTemp;
String iconCode;
DailyWeather.fomJson(Map json){
  this.dateTime=json["dt"];
  this.maxTemp=(json["temp"]["max"]).toInt();
  this.minTemp=(json["temp"]["min"]).toInt();
  this.iconCode=json["weather"][0]["icon"];
}
}