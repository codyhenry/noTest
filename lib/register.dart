import 'package:flutter/material.dart';
import 'package:myuseum/Utils/getAPI.dart';
import 'package:myuseum/Utils/userInfo.dart';

class RegisterRoute extends StatefulWidget {
  @override
  _RegisterRouteState createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  RegistrationFormState createState() {
    return RegistrationFormState();
  }
}

class RegistrationFormState extends State<RegistrationForm>{
  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _firstName = "";
  String _lastName = "";
  String _password = "";
  String _output = "";

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter Email';
                  }
                  return null;
                },
                onChanged: (value) {
                  _email = value;
                },
                decoration: InputDecoration(labelText: 'Email',),
              ),
              TextFormField(
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter First Name';
                  }
                  return null;
                },
                onChanged: (value) {
                  _firstName = value;
                },
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter Last Name';
                  }
                  return null;
                },
                onChanged: (value) {
                  _lastName = value;
                },
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                obscureText: true,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter Password';
                  }
                  return null;
                },
                onChanged: (value) {
                  _password = value;
                },
                decoration: InputDecoration(labelText: 'Password'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()) {
                        _register();
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ),
              Text('$_output'),
            ],
          ),
        ),
      ),
    );
  }

  void _register() {
    //Updates the text to Regsitering to make sure there is some kind of feedback
    setState(() {
      _output = "Registering...";
    });

    int _emailCompare = _email.compareTo(""), _firstNameCompare = _firstName.compareTo(""), _lastNameCompare = _lastName.compareTo(""), _passwordCompare = _password.compareTo(""), multiple = 0;

    if(_emailCompare == 0 || _firstNameCompare == 0 || _lastNameCompare == 0 || _passwordCompare == 0)
    {
      setState(() {
        _output = "";
        if(_emailCompare == 0)
        {
          multiple++;
          _output += "Email";
        }
        if(_firstNameCompare == 0)
        {
          multiple++;
          if(multiple > 1)
            _output +=", ";
          _output += "First Name";
        }
        if(_lastNameCompare == 0)
        {
          multiple++;
          if(multiple > 1)
            _output +=", ";
          _output += "Last Name";
        }
        if(_passwordCompare == 0)
        {
          multiple++;
          if(multiple > 1)
            _output +=", ";
          _output += "Password";
        }
        if(multiple > 1)
        {
          _output += " are missing";
        }
        else
        {
          _output += " is missing";
        }
      });
      return;
    }
    //converts th email, firstname, etc. into JSON format
    String content = '{"email": "' + _email + '","firstName": "' +
        _firstName + '","lastName": "' + _lastName + '","password": "' +
        _password + '"}';
    //Updates the url to direct to the register function
    String registerURL = urlBase + "/users/register";
    //posts the request and updates the outpuut to read whether or not it was successful
    Register.postRegisterGetStatusCode(registerURL, content).then((value) {
      setState(() {
        if(value.compareTo("200") == 0)
          _output = "Account Created";
        else if(value.compareTo("409") == 0)
          _output = "Account already exists";
        else
          _output = "Error " + value;
      });
    });
  }

}