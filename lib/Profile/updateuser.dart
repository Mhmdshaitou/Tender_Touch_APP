import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const kPrimaryColor = Color(0xFF107153);
const double defaultPadding = 16.0;

class UserProfileUpdatePage extends StatefulWidget {
  @override
  _UserProfileUpdatePageState createState() => _UserProfileUpdatePageState();
}

class _UserProfileUpdatePageState extends State<UserProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  String _userId = '';
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  File? _userImage;
  String _imageUrl = 'images/home_images/male_avatar.jpg';
  final storage = FlutterSecureStorage(); // Secure storage instance

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _userImage = File(pickedFile.path);
        _imageUrl = pickedFile.path; // Update the _imageUrl with the new image path
      });
    }
  }

  void _setDefaultAvatar(String avatarUrl) {
    setState(() {
      _userImage = null; // Clear any previously picked user image
      _imageUrl = avatarUrl; // Set the avatar to the default URL passed as a parameter
    });
  }

  Future<void> _getUserData() async {
    String? token = await storage.read(key: 'auth_token');
    String? userId = await storage.read(key: 'user_id');

    if (token == null || userId == null) {
      _showErrorDialog('User not authenticated');
      return;
    }

    _userId = userId;
    String url = 'https://touchtender-web.onrender.com/v1/auth/user/$userId';
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body)['user'];
        setState(() {
          _fullNameController.text = userData['fullName'];
          _emailController.text = userData['email'];
          _passwordController.text = userData['password'];
          _imageUrl = 'https://touchtender-web.onrender.com${userData['image_url']}'; // Prepend localhost
        });
      } else {
        _showErrorDialog('Failed to fetch user data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to connect to the server. Error: $e');
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      String? token = await storage.read(key: 'auth_token');
      if (token == null) {
        _showErrorDialog('Authentication token not found');
        return;
      }

      try {
        http.Response response = await http.put(
          Uri.parse('https://touchtender-web.onrender.com/v1/auth/user/$_userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'fullName': _fullNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'image_url': _imageUrl  // Assuming the server handles image URLs as part of user data
          }),
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Success'),
              content: Text('User profile updated successfully!'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        } else {
          _showErrorDialog('Failed to update user data. Status Code: ${response.statusCode}');
        }
      } catch (e) {
        _showErrorDialog('Failed to connect to the server. Error: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: SingleChildScrollView(
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
                                leading: Icon(Icons.photo_library),
                                title: Text('Choose from Gallery'),
                                onTap: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Male Avatar'),
                                onTap: () {
                                  _setDefaultAvatar('images/home_images/male_avatar.jpg');
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.person_outline),
                                title: Text('Female Avatar'),
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
                        ? FileImage(_userImage!) as ImageProvider
                        : _imageUrl.startsWith('http')
                        ? NetworkImage(_imageUrl)
                        : AssetImage(_imageUrl) as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: TextFormField(
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
                    decoration: InputDecoration(
                      hintText: "Full name",
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Icon(Icons.badge),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
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
                SizedBox(height: defaultPadding / 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    cursorColor: kPrimaryColor,
                    obscureText: !_passwordVisible,
                    validator: (value) => value!.isEmpty || value.length < 6 ? 'Password must be at least 6 characters' : null,
                    decoration: InputDecoration(
                      hintText: "Your password",
                      prefixIcon: Padding(
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
                ElevatedButton(
                  onPressed: _updateUserData, // Enable update functionality
                  child: Text("Update Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
