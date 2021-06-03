import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TranslateTextWidget extends StatelessWidget {
  final String jsonCode,text;


  const TranslateTextWidget({Key key, @required this.jsonCode, @required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(jsonCode).tr(),
        AutoSizeText(text),
      ],
    );
  }
}
