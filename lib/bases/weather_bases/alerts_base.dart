class WeatherAlerts {
  String event, description, senderName;
  int start, end;

  WeatherAlerts.fomJson(Map json) {
    this.senderName = json["sender_name"];
    this.start = json["start"];
    this.end = json["end"];
    this.event = json["event"];
    this.description = json["description"];
  }
}
