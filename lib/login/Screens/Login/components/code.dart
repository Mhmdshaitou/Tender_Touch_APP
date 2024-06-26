import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tender_touch/login/Screens/Login/components/resetpage.dart';
import '../../../components/background.dart';

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class CodeVerificationPage extends StatefulWidget {
  static const String routeName = '/code_verification';

  @override
  _CodeVerificationPageState createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());

  Future<void> _verifyCode(BuildContext context) async {
    final String code = _codeControllers.map((controller) => controller.text).join();
    if (code.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://touchtender-web.onrender.com/v1/auth/verify/ResetCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, PasswordResetPage.routeName);
      } else {
        String message;
        try {
          final responseBody = jsonDecode(response.body);
          message = responseBody['message'] ?? 'Invalid code. Please try again.';
        } catch (e) {
          message = response.body;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $message')),
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
              SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  'Please enter the 6-digit code sent to your email.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 40,
                      height: 40,
                      child: TextField(
                        controller: _codeControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
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
                    );
                  }),
                ),
              ),
              SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: () => _verifyCode(context),
                child: Text("Submit".toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
