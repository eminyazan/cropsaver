import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final Function press;
   AlreadyHaveAnAccountCheck({
    Key key,
    this.login = true,
    this.press,
  }) : super(key: key);
  var askAcc = tr("ask_account");
  var askLog = tr("ask_login");
  var register = tr("register");
  var log = tr("login");

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? askAcc : askLog,
          style: TextStyle(color: Colors.black54,fontSize: 15),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? register : log,
            style: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 17
            ),
          ),
        )
      ],
    );
  }
}
