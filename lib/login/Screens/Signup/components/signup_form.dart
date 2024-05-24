import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../Login/login_screen.dart';

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
  File? _userimage;
  String userimage = 'images/home_images/male_avatar.jpg';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      var uri = Uri.parse('https://touchtender-web.onrender.com/v1/auth/signup');
      var request = http.MultipartRequest('POST', uri)
        ..fields['email'] = _email
        ..fields['password'] = _password
        ..fields['fullName'] = _fullName
        ..fields['gender'] = _gender;

      if (_userimage != null && _userimage!.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('user_image', _userimage!.path));
      } else {
        // Changed to 'user_image' to match the expected API field name
        request.fields['user_image'] = userimage;
      }

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful')),
          );
        } else {
          var responseData = jsonDecode(response.body);
          _showErrorDialog(responseData['message'] ?? 'An error occurred');
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _userimage = File(pickedFile.path);
        userimage = pickedFile.path; // Assign file path to profile URL
      });
    }
  }

  void _setDefaultAvatar(String avatarUrl) {
    setState(() {
      _userimage = null;
      userimage = avatarUrl;
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
        title: const Text('Choose from Gallery'),
        onTap: () {
        _pickImage(ImageSource.gallery);
        Navigator.of(context).pop();
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
        Navigator.of(context). pop();
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
            backgroundImage: _userimage != null
                ? FileImage(_userimage!) as ImageProvider
                : AssetImage(userimage) as ImageProvider,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (value) => _email = value!,
            validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
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
          validator: (value) => value!.isEmpty || value.length < 6 ? 'Password must be at least 6 characters' : null,
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
          validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
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
                builder: (context) => const LoginScreen(),
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
