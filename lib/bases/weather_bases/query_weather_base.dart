class QueryWeather{
  double lat,lon;
  int temp;
  String country,name,iconCode;

  QueryWeather.fromJson(Map json){
    this.lon=(json["coord"]["lon"])is double?json["coord"]["lon"]:(json["coord"]["lon"]).toDouble();
    this.lat=(json["coord"]["lat"])is double?json["coord"]["lat"]:(json["coord"]["lat"]).toDouble();
    this.temp=(json["main"]["temp"]).toInt();
    this.iconCode=json["weather"][0]["icon"];
    this.country=json["sys"]["country"];
    this.name=json["name"];
  }
}