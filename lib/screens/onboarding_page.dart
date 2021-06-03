import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../screens/home_screen.dart';


class OnBoardingPage extends StatefulWidget {
  final Box onBoardBox;

  const OnBoardingPage({Key key, this.onBoardBox}) : super(key: key);
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();


  void _onIntroEnd(context) {
    Get.off(HomeScreen());
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName.jpg', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.onBoardBox.put("onBoardBox", true);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "onboard_title_1".tr(),
          body:"onboard_body_1".tr(),
          image: _buildImage('farmer2'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "onboard_title_2".tr(),
          body: "onboard_body_2".tr(),
          image: _buildImage('preview'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "onboard_title_3".tr(),
          body:"onboard_body_3".tr(),
          image: _buildImage('search'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "onboard_title_4".tr(),
          body: "onboard_body_4".tr(),
          image: _buildImage('ask2'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "onboard_title_5".tr(),
          body: "onboard_body_5".tr(),
          image: _buildImage('mom'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip:  Text("skip".tr()),
      next:  Icon(Icons.arrow_forward),
      done:  Text("done".tr(), style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}