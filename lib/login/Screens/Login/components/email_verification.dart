import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../components/background.dart';
import 'code.dart';

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class EmailVerificationPage extends StatelessWidget {
  static const String routeName = '/email_verification';

  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendEmail(BuildContext context) async {
    final String email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://touchtender-web.onrender.com/v1/auth/forgotPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // You can handle the success response if needed
      } else {
        String message;
        try {
          final responseBody = jsonDecode(response.body);
          message = responseBody['message'] ?? 'Failed to send verification email. Please try again.';
        } catch (e) {
          message = response.body;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send verification email: $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

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
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  'Please enter your email address to verify your account.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Your email",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.email),
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
                  Navigator.pushNamed(context, CodeVerificationPage.routeName);
                  _sendEmail(context);
                },
                child: Text("Verify".toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
