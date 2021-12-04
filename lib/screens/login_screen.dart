import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cuestionario_final/helpers/api_helper.dart';
import 'package:cuestionario_final/helpers/constans.dart';
import 'package:cuestionario_final/models/responses.dart';
import 'package:cuestionario_final/models/token.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _showButtom(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _showButtom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
            child: Text('Iniciar sesión con google'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                return Color(0xFF9347);
              }),
            ),
            onPressed: () => _login()),
      ],
    );
  }

  void _login() async {
    var googleSign = GoogleSignIn();
    await googleSign.signOut();
    var user = await googleSign.signIn();
    print(user);
    Map<String, dynamic> request = {
      'email': user?.email,
      'id': user?.id,
      'logerType': 1,
      'fullName': user?.displayName,
      'photoURL': user?.photoUrl,
    };
    await _socialLogin(request);
  }

  Future _socialLogin(Map<String, dynamic> request) async {
    var url = Uri.parse('${Constans.apiUrl}/api/Account/SocialLogin');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    if (response.statusCode >= 400) {
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: 'El usuario ya inicio previamente con otra red social',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar')
        ],
      );
      print(response.statusCode);
      return;
    }

    var body = response.body;

    var decodejson = jsonDecode(body);
    var token = Token.fromJson(decodejson);
    print(token.token);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
    );
  }
}
