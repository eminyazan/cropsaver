import 'alerts_base.dart';
import 'current_weather_base.dart';
import 'daily_weather_base.dart';
import 'hourly_weather_base.dart';

class LongTimeWeather {
   CurrentWeather currentWeather;
   List<HourlyWeather> hourlyWeather;
   List<WeatherAlerts> alerts;
  List<DailyWeather> dailyWeather;


  LongTimeWeather.fromJson(Map<String, dynamic> json){
    this.currentWeather=CurrentWeather.fromJson(json);
    this.hourlyWeather = (json['hourly'] ?? []).map((data) => HourlyWeather.fromJson(data)).toList().cast<HourlyWeather>();
    this.dailyWeather = (json["daily"]??[]).map((data)=>DailyWeather.fomJson(data)).toList().cast<DailyWeather>();
    this.alerts = (json["alerts"]??[]).map((data)=>WeatherAlerts.fomJson(data)).toList().cast<WeatherAlerts>();
  }



  String convertStringDateTime(int dateTime) {
    var date = DateTime.fromMillisecondsSinceEpoch(dateTime * 1000,);
    String lastDate = date.toString();
    lastDate = lastDate.substring(0, 10);
    return lastDate;
  }

}
