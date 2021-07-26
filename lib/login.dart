import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myuseum/Utils/getAPI.dart';
import 'package:myuseum/main.dart';
import 'package:myuseum/rooms.dart';
import 'package:myuseum/Utils/userInfo.dart';
import 'package:myuseum/register.dart';
import 'package:myuseum/forgot_password.dart';
import 'package:flutter/services.dart'; //for removing the toolbar

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  String _email = "";
  String _password = "";
  String _loginStatus = "";

  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
                child: Image.asset(
                  "assets/images/logo.png",
                  scale: 2,
                ),
              ),
              TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  onChanged: (text) {
                    _email = text;
                  }),
              TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  onChanged: (text) {
                    _password = text;
                  }),
              Text(
                '$_loginStatus',
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Login'),
                  onPressed: () {
                    _login(context);
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Register'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterRoute()),
                    );
                  },
                ),
              ),
              Spacer(),
              TextButton(
                child: Text('Forgot Password',
                    style: TextStyle(color: colorScheme.primaryVariant)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordRoute()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    //return Container();
  }

  void _login(BuildContext context) {
    setState(() {
      _loginStatus = 'Logging in';
    });
    String registerURL = urlBase + "/users/login";
    String content =
        '{"email": "' + _email + '","password": "' + _password + '"}';
    Register.postRegisterGetStatusCode(registerURL, content).then((value) {
      if (value.compareTo('200') == 0) {
        Register.postRegisterGetBody(registerURL, content).then((value) {
          parseLogin(value);
        }).whenComplete(() => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RoomsRoute()),
            ));
      } else if (value.compareTo('400') == 0) {
        setState(() {
          _loginStatus = 'Wrong password or email';
        });
      } else {
        setState(() {
          _loginStatus = 'error: ' + value;
        });
      }
    });
  }

  void parseLogin(String responseBody) {
    Login.fromJson(jsonDecode(responseBody));
  }
}

class Login {
  String accessToken = "", id = "", email = "";
  Login(String newAccessToken, String newId, String newEmail) {
    setAccessToken(newAccessToken);
    setId(newId);
    setEmail(newEmail);
  }

  Login.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'] as String;
    id = json['id'] as String;
    email = json['email'] as String;
    Login(json['accessToken'] as String, json['id'] as String,
        json['email'] as String);
  }
}
