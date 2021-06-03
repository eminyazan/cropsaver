import 'package:flutter/material.dart';

import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';

import '../../home_screen.dart';
import '../components/background.dart';
import 'package:cropreserve/bases/farmer_base.dart';
import 'package:cropreserve/common/loading_screen.dart';
import 'package:cropreserve/components/already_have_an_account_acheck.dart';
import 'package:cropreserve/components/rounded_button.dart';
import 'package:cropreserve/controller/auth_controller.dart';
import 'package:cropreserve/error_manager/errors.dart';
import 'package:cropreserve/screens/Signup/signup_screen.dart';
import 'background.dart';

class Body extends StatefulWidget {
  Body({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  var login = tr("login");
  var email = tr("email");
  var loginEmail = tr("login_with_email");
  var password = tr("password");
  var forgotPass = tr("forgot_password");
  var emptyPass = tr("empty_password");
  var emptyMail = tr("empty_mail");
  var shortPass = tr("short_password");
  AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _mailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _email, _password;
  bool _isLoading = false;
  Farmer _farmer;

  _formSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var title = tr("welcome");
      var message = tr("successful_login");
      setState(() {
        _isLoading = true;
      });
      try {
        _farmer = await _authController.loginWithEmail(_email, _password);
        if (_farmer != null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false);
          Future.delayed(Duration(seconds: 3), () {
            Get.snackbar(title, message,
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 3));
          });
        } else {
          print("farmer null");
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        CoolAlert.show(context: context, type: CoolAlertType.error,title: ErrorManager.show(e.code));
        print("login exception ${e.code}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _isLoading == false
        ? SafeArea(
          child: Background(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        loginEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      SvgPicture.asset(
                        "assets/icons/digital.svg",
                        height: size.height * 0.3,
                      ),
                      SizedBox(height: size.height * 0.03),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                            } else if(value.length<5){
                              return emptyMail;
                            }{
                              if (!value.contains("@") || !value.contains(".")) {
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                      RoundedButton(
                        text: login,
                        press: () {
                          _formSubmit();
                        },
                      ),
                      SizedBox(height: size.height * 0.03),
                      AlreadyHaveAnAccountCheck(
                        login: true,
                        press: () {
                          Get.to(SignUpScreen2());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        )
        : LoadingScreen();
  }
}
