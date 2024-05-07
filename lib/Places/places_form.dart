import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:tender_touch/HomePage/homepage.dart';

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class PlacesForm extends StatefulWidget {
  const PlacesForm({Key? key}) : super(key: key);

  @override
  State<PlacesForm> createState() => _PlacesFormState();
}

class _PlacesFormState extends State<PlacesForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _placeName = '';
  String _selectedClassification = '';
  String _region = '';
  String _city = '';
  List<String> _selectedServices = [];
  String _location = '';
  List<String> _imagePaths = [];

  final List<String> _classifications = [
    'Entertaining Cinema',
    'Inclusive Playground',
    'Specialized School',
    'Natural Garden',
    'Fancy Restaurant',

  ];

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        var response = await http.post(
          Uri.parse('http://localhost:7000/v1/place/createplace'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'placeName': _placeName,
            'classification': _selectedClassification,
            'region': _region,
            'city': _city,
            'services': _selectedServices,
            'location': _location,
            'imagePaths': _imagePaths,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Successful')),
          );
        } else {
          _showErrorDialog(context, jsonDecode(response.body)['message']);
        }
      } catch (e) {
        _showErrorDialog(context, 'Failed to connect to the server. Please try again later.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imagePaths.add(result.files.single.path!);
      });
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
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text('Request to add a new place!'),
              ),
              SizedBox(height: defaultPadding / 2),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _placeName = value!,
                validator: (value) => value!.isEmpty ? 'Please enter the place name' : null,
                decoration: InputDecoration(
                  hintText: "Name of Place",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.add_circle),
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
                onSaved: (value) => _placeName = value!,
                validator: (value) => value!.isEmpty ? 'Please Describe the place' : null,
                decoration: InputDecoration(
                  hintText: "Place Description",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.description),
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
                decoration: InputDecoration(
                  hintText: "Place Classification",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.class_),
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
                items: _classifications.map((classification) {
                  return DropdownMenuItem(
                    value: classification,
                    child: Text(classification),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassification = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a classification' : null,
              ),
              SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _region = value!,
                validator: (value) => value!.isEmpty ? 'Please enter the region' : null,
                decoration: InputDecoration(
                  hintText: "Region",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.location_on),
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
                onSaved: (value) => _city = value!,
                validator: (value) => value!.isEmpty ? 'Please enter the city' : null,
                decoration: InputDecoration(
                  hintText: "City",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.location_city),
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
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provided Services',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: defaultPadding / 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text('Sensory-Friendly Features'),
                          value: _selectedServices.contains('service1'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _selectedServices.add('service1');
                              } else {
                                _selectedServices.remove('service1');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Automatic Doors'),
                          value: _selectedServices.contains('service2'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _selectedServices.add('service2');
                              } else {
                                _selectedServices.remove('service2');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Ramps/Slopes'),
                          value: _selectedServices.contains('service3'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _selectedServices.add('service3');
                              } else {
                                _selectedServices.remove('service3');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          value: _selectedServices.contains('service4'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _selectedServices.add('service4');
                              } else {
                                _selectedServices.remove('service4');
                              }
                            });
                          },
                          title: Text('Elevators'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _location = value!,
                validator: (value) => value!.isEmpty ? 'Please enter the location' : null,
                decoration: InputDecoration(
                  hintText: "Location",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.map),
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
                onTap: _pickImage,
                readOnly: true,
                controller: TextEditingController(
                  text: _imagePaths.isNotEmpty ? _imagePaths.join(", ") : null,
                ),
                validator: (value) => value!.isEmpty ? 'Please upload an image' : null,
                decoration: InputDecoration(
                  hintText: "Upload Image",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.image),
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
                onPressed: _isLoading ? null : () => _register(context),
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Submit".toUpperCase()),
              ),
              SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
