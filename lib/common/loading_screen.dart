import '../common/screen_sizes.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF39B6FE),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: pageHeight * 0.5,
            width: pageWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/logo.jpg"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "loading".tr(),
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
