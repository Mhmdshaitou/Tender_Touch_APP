import 'package:flutter/material.dart';
import '../../../components/background.dart';
import 'login_form.dart'; // Import the Background widget

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class PasswordResetPage extends StatefulWidget {
  static const String routeName = '/password_reset';

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  'Please enter your new password.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_passwordVisible,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    hintText: "New password",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_passwordVisible,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Confirm new password",
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
                onPressed: () {
                  Navigator.pushNamed(context, LoginForm.routeName);
                },
                child: Text("Reset Password".toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
