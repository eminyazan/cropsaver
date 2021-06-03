import 'package:hive/hive.dart';
part "hive_base.g.dart";
@HiveType(typeId: 0)
class HiveUser {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String username;


  @HiveField(2)
  String profileUrl;

  @HiveField(3)
  String email;

  HiveUser({this.uid,this.email,this.username,this.profileUrl});

}