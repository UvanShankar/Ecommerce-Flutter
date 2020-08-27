import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting, _obscureText = true;
  String _email, _password;

  Widget _showTitle() {
    return Text('Login', style: Theme.of(context).textTheme.headline);
  }

  Widget _showEmailInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _email = val,
            validator: (val) => !val.contains('@') ? 'Invalid Email' : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                hintText: 'Enter a valid email',
                icon: Icon(Icons.mail, color: Colors.grey))));
  }

  Widget _showPasswordInput() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _password = val,
            validator: (val) => val.length < 6 ? 'Username too short' : null,
            obscureText: _obscureText,
            decoration: InputDecoration(
                suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                    child: Icon(_obscureText
                        ? Icons.visibility
                        : Icons.visibility_off)),
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter password, min length 6',
                icon: Icon(Icons.lock, color: Colors.grey))));
  }

  Widget _showFormActions() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(children: [
          _isSubmitting == true
              ? CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).accentColor))
              : RaisedButton(
                  child: Text('Submit',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.black)),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  color: Theme.of(context).accentColor,
                  onPressed: _submit),
          FlatButton(
              child: Text('New user? Register'),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/register'))
        ]));
  }

  void _submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      _registerUser();
    }
  }

  void _registerUser() async {
    setState(() => _isSubmitting = true);

    String url =
        'https://ecommerce-app-flutter-mongo.herokuapp.com//authentication/login/';
    Map map = {"email": _email, "password": _password};
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(map)));
    HttpClientResponse response = await request.close();
    var responseData, contentss;

    response.transform(utf8.decoder).listen((contents) async {
      print(json.decode(contents));
      responseData = json.decode(contents);
      contentss = contents;
      ///////////////////
      if (response.statusCode == 200) {
        setState(() => _isSubmitting = false);
        print("prefffffffffffffffffffffffffffff");
        //_storeUserData(responseData);
        print("save1");
        final prefs = await SharedPreferences.getInstance();
        var abc = {"name": responseData['user'], "jwt": responseData['jwt']};
        prefs.setString('user', contentss);
        //prefs.setString('user', json.encode(abc));
        //print("val1" + json.encode(responseData['user']));
        prefs.setString('jwt', responseData['jwt']);
        //print("val2" + responseData['jwt']);
        //print("save2");
        final myString = prefs.getString('user') ?? '';
        final myString1 = prefs.getString('jwt') ?? '';
        //print("vallll1" + myString);
        //print(json.decode(myString));
        //print("vallll2" + myString1);
        //print("printover");
        //print("prefffffffffffffffffffffffffffff2");
        _showSuccessSnack();
        _redirectUser();
        print(responseData);
      } else {
        setState(() => _isSubmitting = false);
        final String errorMsg = responseData['message'];
        _showErrorSnack(errorMsg);
      }
      /////////////////////
    });

    //final responseData = json.decode(response.);
    /*
    if (response.statusCode == 200) {
      setState(() => _isSubmitting = false);
      print("prefffffffffffffffffffffffffffff");
      _storeUserData(responseData);
      print("prefffffffffffffffffffffffffffff");
      _showSuccessSnack();
      _redirectUser();
      print(responseData);
    } else {
      setState(() => _isSubmitting = false);
      final String errorMsg = responseData['message'];
      _showErrorSnack(errorMsg);
    }

    */
    /*
    http.Response response = await http.post(
        'https://ecommerce-app-flutter-mongo.herokuapp.com//authentication/login/',
        body: {"email": _email, "password": _password});
    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() => _isSubmitting = false);
      _storeUserData(responseData);
      _showSuccessSnack();
      _redirectUser();
      print(responseData);
    } else {
      setState(() => _isSubmitting = false);
      final String errorMsg = responseData['message'];
      _showErrorSnack(errorMsg);
    }
 */
  }

  void _storeUserData(responseData) async {
    // print("save1");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', responseData['user']);
    // print("val1" + responseData['user']);
    prefs.setString('jwt', responseData['jwt']);
    // print("val2" + responseData['jwt']);
    //print("save2");
    final myString = prefs.getString('user') ?? '';
    final myString1 = prefs.getString('jwt') ?? '';
    // print("vallll1" + myString);
    //print("vallll2" + myString1);
    //  print("printover");
  }

  void _showSuccessSnack() {
    final snackbar = SnackBar(
        content: Text('User successfully logged in!',
            style: TextStyle(color: Colors.green)));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    _formKey.currentState.reset();
  }

  void _showErrorSnack(String errorMsg) {
    final snackbar =
        SnackBar(content: Text(errorMsg, style: TextStyle(color: Colors.red)));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    throw Exception('Error logging in: $errorMsg');
  }

  void _redirectUser() {
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Login')),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
                child: SingleChildScrollView(
                    child: Form(
                        key: _formKey,
                        child: Column(children: [
                          _showTitle(),
                          _showEmailInput(),
                          _showPasswordInput(),
                          _showFormActions()
                        ]))))));
  }
}
