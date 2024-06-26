import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../Chatbot/ChatApp.dart';
import '../../../../Community/community_home.dart';
import '../../../../Doctors/ui/root_page.dart';
import '../../../../Profile/profile_page.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../Signup/signup_screen.dart';
import 'package:tender_touch/HomePage/homepage.dart';

import 'email_verification.dart';

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class LoginForm extends StatefulWidget {
  static const String routeName = '/login_form';
  final String destinationRoute;

  const LoginForm({Key? key, required this.destinationRoute}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String? _token;
  final storage = FlutterSecureStorage();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        var response = await http.post(
          Uri.parse('https://touchtender-web.onrender.com/v1/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _email,
            'password': _password,
          }),
        );

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          _token = responseBody['token'];

          // Decode the token to get the user ID
          Map<String, dynamic> payload = Jwt.parseJwt(_token!);
          String userId = payload['userId'].toString(); // Assuming the user ID is stored in the 'userId' claim

          // Store the user ID and token securely
          await storage.write(key: 'user_id', value: userId);
          await storage.write(key: 'auth_token', value: _token);

          print('Login successful, token: $_token, userId: $userId');

          Navigator.pushReplacement(
            context,
            PageTransition(
              child: _getDestinationPage(widget.destinationRoute), // Navigate to the destination page
              type: PageTransitionType.bottomToTop,
            ),
          );
        } else {
          _showErrorDialog('Login failed. Please try again.');
        }
      } catch (e) {
        _showErrorDialog('An error occurred. Please check your network and try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _getDestinationPage(String route) {
    switch (route) {
      case UserProfilePage.routeName:
        return UserProfilePage();
      case CommunityPage.routeName:
        return CommunityPage();
      case ChatScreen.routeName:
        return ChatScreen();
      default:
        return HomePage();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _email = value!,
                validator: _validateEmail,
                decoration: InputDecoration(
                  hintText: "Your email",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.person),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: defaultPadding),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  cursorColor: kPrimaryColor,
                  obscureText: !_passwordVisible,
                  onSaved: (value) => _password = value!,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: "Your password",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.lock),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: defaultPadding / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot your password? ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailVerificationPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Reset now',
                      style: TextStyle(
                        color: kPrimaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login".toUpperCase()),
              ),
              SizedBox(height: defaultPadding),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
