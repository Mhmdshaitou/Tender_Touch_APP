import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tender_touch/Doctors/constants.dart';
import 'dart:convert';

import 'package:tender_touch/HomePage/homepage.dart';
import '../Chatbot/ChatApp.dart';

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
  String _gender = 'Male';
  String _age = '';
  String _diagnosis = '';
  String _medications = '';
  String _resources = '';
  String _interests = '';
  String _anything = '';
  String _apiResponse = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        var response = await http.post(
          Uri.parse('https://touchtender-web.onrender.com/v1/activity/createform'),
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
          setState(() {
            _apiResponse = response.body;
          });
          print('API Response: $_apiResponse');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Successful')),
          );
        } else {
          _showErrorDialog(jsonDecode(response.body)['message']);
        }
      } catch (e) {
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
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit".toUpperCase()),
              ),
              SizedBox(height: defaultPadding),
              if (_apiResponse.isNotEmpty)
                _buildActivitiesCarousel(_apiResponse)
              else
                Text(''),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildActivitiesCarousel(String apiResponse) {
  final activities = parseApiResponse(apiResponse);
  if (activities.isEmpty) {
    return Text('No activities found');
  }
  return ActivitiesCarousel(activities: activities);
}

Map<String, List<String>> parseApiResponse(String response) {
  Map<String, List<String>> activities = {};

  try {
    final jsonResponse = jsonDecode(response);
    final generatedText = jsonResponse['generatedText'];

    if (generatedText == null || generatedText.isEmpty) {
      return activities;
    }

    generatedText.forEach((key, value) {
      List<String> activityList = value.map<String>((activity) => activity.toString()).toList();
      activities[key] = activityList;
    });
  } catch (e) {
    print('Error parsing API response: $e');
  }

  return activities;
}

class ActivitiesCarousel extends StatefulWidget {
  final Map<String, List<String>> activities;

  ActivitiesCarousel({Key? key, required this.activities}) : super(key: key);

  @override
  _ActivitiesCarouselState createState() => _ActivitiesCarouselState();
}

class _ActivitiesCarouselState extends State<ActivitiesCarousel> {
  int _currentIndex = 0;

  void _showChoiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Great choice!'),
          content: Text('If you want more information about this activity, chat with our chatbot.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: Text('Leave to Home Page'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatBotPage(), // Replace with actual chatbot page
                  ),
                );
              },
              child: Text('Chat with Chatbot'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityDetails = widget.activities.values.expand((x) => x).toList();
    return Column(
      children: [
        CarouselSlider(
          items: activityDetails.map((activityDetail) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activityDetail,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: _showChoiceDialog,
                        child: Text('Choose'),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.6,
            initialPage: 0,
            enableInfiniteScroll: false,
            reverse: false,
            autoPlay: false,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Text('${_currentIndex + 1}/${activityDetails.length}'),
      ],
    );
  }
}

