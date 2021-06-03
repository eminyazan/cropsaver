import 'package:cropreserve/components/text_field_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
   RoundedPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);
  var password = tr("password");

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        onChanged: onChanged,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: password,
          icon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
