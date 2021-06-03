import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cropreserve/bases/farmer_base.dart';
import 'package:cropreserve/common/loading_screen.dart';
import 'package:cropreserve/components/already_have_an_account_acheck.dart';
import 'package:cropreserve/components/rounded_button.dart';
import 'package:cropreserve/controller/auth_controller.dart';
import 'package:cropreserve/error_manager/errors.dart';
import '../../home_screen.dart';
import 'background.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final authController = AuthController();
  bool isLoading=false;
  final _formKey = GlobalKey<FormState>();
  String _email, _password, _passwordConfirm;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _mailController = TextEditingController();
  Farmer _farmer;

  var email = tr("email");
  var registerEmail = tr("register_with_email");
  var password = tr("password");
  var register = tr("register");
  var emptyPass = tr("empty_password");
  var emptyMail = tr("empty_mail");
  var shortPass = tr("short_password");
  var cancel=tr("cancel");
  var ok=tr("ok");
  var notMatch=tr("not_match_password");



  _formSubmit() async {

      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        var title=tr("welcome");
        var message=tr("successful_acc_created");
        setState(() {
          isLoading=true;
        });
        try {
          _farmer=await authController.createUserWithEmail(_email, _password);
          if ( _farmer!=null) {
            setState(() {
              isLoading=false;
            });
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
            Future.delayed(Duration(seconds: 4),(){
              Get.snackbar(title, message,snackPosition: SnackPosition.BOTTOM,duration:Duration(seconds: 3));
            });
          } else {
            print("farmer null");
            setState(() {
              isLoading=false;
            });
            return null;
          }
        } on FirebaseAuthException catch (e) {
          setState(() {
            isLoading=false;
          });
          CoolAlert.show(context: context, type: CoolAlertType.error,title: ErrorManager.show(e.code));
          print(e.code);

        }
      }
    }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return !isLoading?SafeArea(
      child: Background(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  registerEmail,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),
                SvgPicture.asset(
                  "assets/icons/farm.svg",
                  height: size.height * 0.27,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.shade100,
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: TextFormField(
                    controller: _mailController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return emptyMail;
                      } else {
                        if (!value.contains("@") ||
                            !value.contains(".")) {
                          return emptyMail;
                        } else {
                          return null;
                        }
                      }
                    },
                    onSaved: (inputMail) {
                      _email = inputMail;
                    },
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                      hintText: email,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.shade100,
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return emptyPass;
                      } else {
                        if (value.length < 7) {
                          return shortPass;
                        } else {
                          return null;
                        }
                      }
                    },
                    onSaved: (inputPass) {
                      _password = inputPass;
                    },
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                      hintText: password,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.shade100,
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: TextFormField(
                    controller: _passwordConfirmController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return emptyPass;
                      } else {
                        if (value.length >= 6) {
                          if (value == _passwordController.text) {
                            return null;
                          } else {
                            return notMatch;
                          }
                        } else {
                          return shortPass;
                        }
                      }
                    },
                    onSaved: (inputPass) {
                      _passwordConfirm = inputPass;
                    },
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                      hintText: password,
                      border: InputBorder.none,
                    ),
                  ),
                ),

                RoundedButton(
                  text: register,
                  press: () {
                    _formSubmit();
                  },
                ),
                SizedBox(height: size.height * 0.01),
                AlreadyHaveAnAccountCheck(
                  login: false,
                  press: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ):LoadingScreen();
  }
}
