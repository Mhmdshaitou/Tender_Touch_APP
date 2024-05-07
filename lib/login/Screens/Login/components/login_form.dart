import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../Doctors/ui/root_page.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../Signup/signup_screen.dart';
import 'package:tender_touch/HomePage/homepage.dart';

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        var response = await http.post(
          Uri.parse('http://localhost:7000/v1/auth/login'),
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

          // Print a success message with the token
          print('Login successful, token: $_token');

          Navigator.pushReplacement(
            context,
            PageTransition(
              child: HomePage(), // Pass token to HomePage or other methods
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

  Future<void> fetchUserData() async {
    if (_token == null) {
      _showErrorDialog('No token found, please login again.');
      return;
    }

    try {
      var response = await http.get(
        Uri.parse('http://localhost:7000/v1/user/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token', // Add the token here
        },
      );

      if (response.statusCode == 200) {
        print('Data: ${response.body}');
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
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
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
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
                  validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
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
