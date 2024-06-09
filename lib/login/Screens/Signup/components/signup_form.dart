import 'dart:io';
import 'package:flutter/services.dart'; // Add this line
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tender_touch/Doctors/ui/screens/home_page.dart';
import 'dart:convert';
import '../../../components/already_have_an_account_acheck.dart';
import '../../Login/login_screen.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Add this line

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _gender = 'Male'; // Default gender
  File? _userImage;
  String userimage = 'images/home_images/male_avatar.jpg'; // Default to male avatar URL

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _userImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      var uri = Uri.parse('http://localhost:7000/v1/auth/signup');
      var request = http.MultipartRequest('POST', uri)
        ..fields['email'] = _email
        ..fields['password'] = _password
        ..fields['fullName'] = _fullName
        ..fields['gender'] = _gender;

      if (_userImage != null) {
        print('User picked an image from the gallery');
        print('Image path: ${_userImage!.path}');

        request.files.add(
          await http.MultipartFile.fromPath('user_image', _userImage!.path),
        );
        print('MultipartFile added to request');
      } else {
        // Send the default avatar as a file
        print('User selected a default avatar');
        String avatarPath;
        if (_gender == 'Male') {
          avatarPath = 'images/home_images/male_avatar.jpg'; // Replace with the appropriate path
        } else {
          avatarPath = 'images/home_images/female_avatar.jpg'; // Replace with the appropriate path
        }
        print('Avatar path: $avatarPath');

        final avatarBytes = await rootBundle.load(avatarPath);
        final mimeType = lookupMimeType(avatarPath); // Get the MIME type of the avatar image
        final avatarFile = http.MultipartFile.fromBytes(
          'user_image',
          avatarBytes.buffer.asUint8List(),
          filename: avatarPath.split('/').last,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null, // Parse the MIME type to MediaType
        );
        request.files.add(avatarFile);
        print('MultipartFile added to request');
      }

      try {
        print('Sending request to server...');
        var streamedResponse = await request.send();
        print('Received response from server');
        var response = await http.Response.fromStream(streamedResponse);
        print('Response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          try {
            var responseData = jsonDecode(response.body);
            print('Response data: $responseData');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(destinationRoute: '/'), // Update with correct destination
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration Successful')),
            );
          } catch (e) {
            _showErrorDialog('Failed to parse response: $e');
          }
        } else {
          _showErrorDialog('Error ${response.statusCode}: ${response.reasonPhrase}');
        }
      } catch (e) {
        _showErrorDialog('Failed to connect to the server. Error: $e');
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
        title: const Text('Registration Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _setDefaultAvatar(String avatarUrl) {
    setState(() {
      userimage = avatarUrl; // Adjust to your actual accessible URL path
      _userImage = null; // Reset the picked image
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + defaultPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Pick from Gallery'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _pickImage();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Male Avatar'),
                              onTap: () {
                                _setDefaultAvatar('images/home_images/male_avatar.jpg');
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Female Avatar'),
                              onTap: () {
                                _setDefaultAvatar('images/home_images/female_avatar.jpg');
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: _userImage != null
                      ? FileImage(_userImage!)
                      : AssetImage(userimage) as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _email = value!,
                validator: (value) => value == null || !value.endsWith('@gmail.com') ? 'Email must end with @gmail.com' : null,
                decoration: InputDecoration(
                  hintText: "Your email",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.email),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  obscureText: !_passwordVisible,
                  onSaved: (value) => _password = value!,
                  validator: (value) => value == null || value.length <= 5 ? 'Password must be at least 6 characters' : null,
                  decoration: InputDecoration(
                    hintText: "Your password",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Icon(Icons.lock),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                cursorColor: kPrimaryColor,
                onSaved: (value) => _fullName = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                decoration: InputDecoration(
                  hintText: "Full name",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.badge),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                child: DropdownButtonFormField(
                  value: _gender,
                  items: ['Male', 'Female']
                      .map((label) => DropdownMenuItem(
                    child: Text(label),
                    value: label,
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "Select your gender",
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Icon(Icons.transgender),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      )),
                ),
              ),
              SizedBox(height: defaultPadding / 2),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("Sign Up".toUpperCase()),
              ),
              const SizedBox(height: defaultPadding),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(destinationRoute: '/'), // Update with correct destination
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
