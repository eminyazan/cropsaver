class Article {
  String head, trHead, body, trBody, url;
  int id;

  Article.fromMap(Map map) {
    this.head = map["head"];
    this.trHead = map["trHead"];
    this.body = map["body"];
    this.trBody = map["trBody"];
    this.url = map["url"];
    this.id = map["id"];
  }
}
