import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tender_touch/HomePage/homepage.dart';
import 'ActivitiesSuggestions.dart';

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class ActivitiesForm extends StatefulWidget {
  const ActivitiesForm({Key? key}) : super(key: key);

  @override
  State<ActivitiesForm> createState() => _ActivitiesFormState();
}

class _ActivitiesFormState extends State<ActivitiesForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _gender = 'Male'; // Default gender
  String _age = '';
  String _diagnosis = '';
  String _medications = '';
  String _resources = '';
  String _interests = '';
  String _anything = '';
  String _apiResponse = ''; // Store API response

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        var response = await http.post(
          Uri.parse('http://localhost:7000/v1/activity/createform'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'gender': _gender,
            'age': _age,
            'diagnosis': _diagnosis,
            'medications': _medications,
            'resources': _resources,
            'interests': _interests,
            'anything': _anything,
          }),
        );

        print('HTTP Response Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          // Registration successful, store API response
          setState(() {
            _apiResponse = jsonDecode(response.body)['generatedText'].toString();
          });
          // Show success message (optional)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Successful')),
          );
        } else {
          print('Error: ${jsonDecode(response.body)['message']}');
          _showErrorDialog(jsonDecode(response.body)['message']);
        }
      } catch (e) {
        print('Error: Failed to connect to the server. $e');
        _showErrorDialog('Failed to connect to the server. Please try again later.');
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
        title: Text('Registration Error'),
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
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text('Activities Form'),
              ),
              SizedBox(height: defaultPadding / 2),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _age = value!,
                validator: (value) => value!.isEmpty ? 'Please enter Age' : null,
                decoration: InputDecoration(
                  hintText: "Age",
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
              SizedBox(height: defaultPadding),
              DropdownButtonFormField(
                value: _gender,
                items: ['Male', 'Female']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value.toString();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Gender",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.transgender),
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
              SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _diagnosis = value!,
                validator: (value) => value!.isEmpty ? 'Please enter Diagnosis' : null,
                decoration: InputDecoration(
                  hintText: "Diagnosis",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.assignment),
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
              SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _medications = value!,
                validator: (value) => value!.isEmpty ? 'Please enter Medications' : null,
                decoration: InputDecoration(
                  hintText: "Medications",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.local_hospital),
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
              SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _resources = value!,
                validator: (value) => value!.isEmpty ? 'Please enter Interests' : null,
                decoration: InputDecoration(
                  hintText: "Child's Interests",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.interests),
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
              SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _interests = value!,
                validator: (value) => value!.isEmpty ? 'Please enter the last activities' : null,
                decoration: InputDecoration(
                  hintText: "Activities Tried Before",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.child_care),
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
              SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _anything = value!,
                decoration: InputDecoration(
                  hintText: "Additional Information",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.info),
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
              SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Submit".toUpperCase()),
              ),
              SizedBox(height: defaultPadding),
              if (_apiResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Text(
                    'API Response:\n$_apiResponse',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
