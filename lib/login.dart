import 'dart:convert';

import 'package:adhimedsvendor/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
   bool _isObscure = true;
 


  void _toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

 

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog('Error', 'Please fill all the fields.');
      return;
    }
  

    var url = Uri.https('baba.qa', '/adhimeds/api/v2/auth/login');
    var headers = {
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'System-Key': '\$2y\$10\$BO45zUbQshM6XXFcnVSlKuhPqqDTIu15JOAVlkxS/o6K8c32w6wPa'
    };
 
  
    var body = json.encode({
      "email": email,
      "password": password,
      "user_type": "seller",
      "identity_matrix": "ec669dad-9136-439d-b8f4-80298e7e6f37"
    });

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print(response.body);
        var responseData = json.decode(response.body);
        if (responseData['result'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('accessToken', responseData['access_token']);
          prefs.setInt('userId', responseData['user']['id']);
          prefs.setString('userName', responseData['user']['name']);
          prefs.setString('userEmail', responseData['user']['email']);
          prefs.setString('avatar', responseData['user']['avatar']);


          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          _showAlertDialog('Error', responseData['message']);
        }
      } else {
        _showAlertDialog('Error', 'Failed to connect to the server. Please try again later.');
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to connect to the server. Please check your internet connection.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK',style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
@override
void initState() {
  super.initState();

}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (BuildContext scaffoldContext) {
            return SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 70),
                  Container(
                    height: 180,
                    child: Image.asset(
                      'images/logoo.png',
                      fit: BoxFit.cover,
                    ),
                   ),

                  Text('Welcome Back!',style: TextStyle(fontSize: 20,color: Colors.green),),
                  Text('Sign in to your Account!',style: TextStyle(fontSize: 10,color: Colors.grey),),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                      
                        SizedBox(height: 30),
                        Container(
                          height: 43,
                          child: TextField(
                            controller: _emailController,
                            cursorColor: Colors.black,
                            cursorHeight: 23,
                            decoration: InputDecoration(
                              labelText: 'Email or Username',
                              labelStyle: TextStyle(color: Colors.grey, fontFamily: 'Neutraface'),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green, width: 0.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 43,
                          child: TextField(
                            controller: _passwordController,
                            cursorColor: Colors.black,
                               obscureText: _isObscure,
                            cursorHeight: 23,
                  
                            decoration: InputDecoration(
                               suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: _toggleObscure,
                        ),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey, fontFamily: 'Neutraface'),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green, width: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  InkWell(
                    onTap: _login,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 320,
                        child: Center(
                          child: Text(
                            'SIGN IN',
                            style: TextStyle(color: Colors.white, fontFamily: 'Neutraface'),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
