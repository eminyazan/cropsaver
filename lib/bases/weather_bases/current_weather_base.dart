class CurrentWeather{
  int windSpeed,humidity,pressure,visibility,fellsLike,temp,dateTime;
  String iconCode, description;

  CurrentWeather.fromJson(Map json){
    this.dateTime=(json["current"]["dt"]).toInt();
    this.temp=(json["current"]["temp"]).toInt();
    this.fellsLike=(json["current"]["feels_like"]).toInt();
    this.pressure=json["current"]["pressure"];
    this.humidity=json["current"]["humidity"];
    this.visibility=json["current"]["visibility"];
    this.windSpeed=(json["current"]["wind_speed"]).toInt();
    this.description=(json["current"]["weather"][0]["description"]);
    this.iconCode=json["current"]["weather"][0]["icon"];
  }
}