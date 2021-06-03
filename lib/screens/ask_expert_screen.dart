import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/custom_button.dart';
import '../common/screen_sizes.dart';


class AskExpert extends StatelessWidget {
  var askExpert = tr("ask_expert");
  var attention = tr("mail_attention");
  var send = tr("send");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(askExpert),
        centerTitle: true,
        backgroundColor: Colors.greenAccent.shade400,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: pageHeight * 0.03),
              SvgPicture.asset(
                "assets/icons/ask.svg",
                height: pageHeight * 0.4,
              ),
              SizedBox(height: pageHeight * 0.03),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  attention,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  buttonText: send,
                  onPressed: () => _sentMail(),
                  height: 50,
                  buttonColor: Colors.green.shade900,
                  buttonIcon: Icon(Icons.done_outline_sharp,color: Colors.white,),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _sentMail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'yznmedia@gmail.com',
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
