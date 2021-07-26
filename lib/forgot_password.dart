import 'package:flutter/material.dart';
import 'package:myuseum/Utils/getAPI.dart';
import 'package:myuseum/Utils/userInfo.dart';

class ForgotPasswordRoute extends StatefulWidget {
  @override
  _ForgotPasswordRouteState createState() => _ForgotPasswordRouteState();
}

class _ForgotPasswordRouteState extends State<ForgotPasswordRoute> {
  String _output = "";
  String _email = "";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),

      body: Center(
          child:
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child:
                Column(
                  children: [
                    TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (text) {
                        _email = text;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child:
                        SizedBox(
                          width: double.infinity,
                          child:
                          ElevatedButton(
                            onPressed: _forgotPassword,
                            child:
                            Text('Submit'),
                          ),
                        ),
                    ),
                    Text('$_output'),
                  ]
                ),
            ),
      ),
    );
    //return Container();
  }

  void _forgotPassword() {
    setState(() {
      _output = "Sending...";
    });
    String content = '{"email": "' + _email + '"';
    String registerURL = urlBase + "/users/forgotPassword";
    Register.postRegisterGetStatusCode(registerURL, content).then((value) {
      if(value.compareTo("200") == 0) {
        setState(() {
          _output = 'Email sent';
        });
      }
      else if(value.compareTo("400") == 0) {
        setState(() {
          _output = 'Email required';
        });
      }
      else if(value.compareTo("404") == 0) {
        setState(() {
          _output = 'Email does not exist';
        });
      }
      else if(value.compareTo("503") == 0) {
        setState(() {
          _output = 'Email failed to send';
        });
      }
      else
      {
        setState(() {
          _output = 'Error ' + value;
        });
      }
    });
  }
}