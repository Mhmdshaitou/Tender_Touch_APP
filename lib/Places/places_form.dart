import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:tender_touch/HomePage/homepage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_app_settings/open_app_settings.dart';
import '../Activities/background.dart';

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

  final List<String> _regions = [
    'Beirut',
    'Akkar',
    'Baalbeck-Hermel',
    'Bekaa',
    'Mount Lebanon',
    'North Lebanon',
    'Nabatiyeh',
    'South Lebanon'
  ];

  Map<String, List<String>> _citiesByRegion = {
    'Beirut': ['Beirut'],
    'Akkar': ['Akkar'],
    'Baalbeck-Hermel': ['Baalbek', 'Hermel'],
    'Bekaa': ['Zahle', 'Rashaya', 'El Bekaa'],
    'Mount Lebanon': ['Jounieh', 'Jbeil', 'Baabda', 'Aley', 'Matn', 'Chouf'],
    'North Lebanon': ['Tripoli', 'Miniyeh-Danniyeh', 'Zgharta', 'Bcharre', 'Koura', 'Batroun'],
    'Nabatiyeh': ['Nabatieh', 'Bint Jbeil', 'Hasbaya', 'Marjeyoun'],
    'South Lebanon': ['Saida', 'Tyre', 'Jezzine'],
  };

  List<String> _cities = [];

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        var response = await http.post(
          Uri.parse('https://touchtender-web.onrender.com/v1/place/createplace'),
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

  Future<void> _requestPermission() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      _pickImage();
    } else if (status.isDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Gallery Access Denied'),
            content: Text('Please grant access to your gallery to upload images.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Deny'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await openAppSettings();
                },
                child: Text('Allow'),
              ),
            ],
          );
        },
      );
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Gallery Access Permanently Denied'),
            content: Text('Please enable gallery access in settings.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await openAppSettings();
                },
                child: Text('Settings'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _imagePaths.addAll(result.paths.map((path) => path!).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick images: $e")),
      );
    }
  }

  void _removeImage(String path) {
    setState(() {
      _imagePaths.remove(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
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
                DropdownButtonFormField(
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
                  items: _regions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _region = value!;
                      // Update cities based on the selected region
                      _cities = _citiesByRegion[_region] ?? [];
                      _city = ''; // Reset city selection
                    });
                  },
                  validator: (value) => value == null ? 'Please select a region' : null,
                ),
                SizedBox(height: defaultPadding),
                DropdownButtonFormField(
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
                  items: _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _city = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a city' : null,
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
                  validator: (value) => value!.isEmpty ? 'Please enter the location URL' : null,
                  decoration: InputDecoration(
                    hintText: "Location URL",
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
                // Image upload and display section
                GestureDetector(
                  onTap: _requestPermission,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(8),
                    child: _imagePaths.isEmpty
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: Colors.grey),
                        SizedBox(width: 10, height: 100,),
                        Text('Select Images', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                        : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _imagePaths.map((path) {
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.file(
                                    File(path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => _removeImage(path),
                                  child: Icon(Icons.close, color: Colors.red, size: 24),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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
      ),
    );
  }
}
