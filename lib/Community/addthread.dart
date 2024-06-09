import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tender_touch/Community/community_home.dart';

const kPrimaryColor = Color(0xFF0681A8);
const double defaultPadding = 16.0;

class AddThreadPage extends StatefulWidget {
  @override
  _AddThreadPageState createState() => _AddThreadPageState();
}

class _AddThreadPageState extends State<AddThreadPage> {
  final _contentController = TextEditingController();
  String? _selectedCategory;
  final storage = FlutterSecureStorage();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> submitThread(String content, String category) async {
    String? userId = await storage.read(key: 'user_id');
    String? token = await storage.read(key: 'auth_token');

    if (userId == null || token == null) {
      _showErrorDialog('No user ID or token found, please login again.');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://localhost:7000/v1/community/addcomment'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'userID': userId,
          'content': content,
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        print('Your Comment was added successfully');
        print('Response message: ${responseData['message']}');
        print('Comment details: ${responseData['comment']}');
        _showSuccessDialog('Thread submitted successfully.');
      } else {
        print('Failed to submit thread. Response body: ${response.body}');
        _showErrorDialog('Failed to submit thread. Please try again.', response.body);
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please check your network and try again.');
    }
  }

  void _showErrorDialog(String message, [String? errorMessage]) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: errorMessage != null
            ? Text('$message\n\nError message: $errorMessage')
            : Text(message),
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Dismiss the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityPage(),
                ),
              );
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
        title: Text(
          'Add Comment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text('Select a category'), // Added hint
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'ADHD',
                  child: Text('ADHD'),
                ),
                DropdownMenuItem(
                  value: 'Autism',
                  child: Text('Autism'),
                ),
                DropdownMenuItem(
                  value: 'Cerebral Palsy',
                  child: Text('Cerebral Palsy'),
                ),
                DropdownMenuItem(
                  value: 'Locomotor Disability',
                  child: Text('Locomotor Disability'),
                ),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorColor: kPrimaryColor,
              validator: (value) => value!.isEmpty ? 'Please write something here!' : null,
              decoration: InputDecoration(
                hintText: "Write here something...",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final content = _contentController.text;
                  final category = _selectedCategory;
                  if (content.isNotEmpty && category != null) {
                    submitThread(content, category);
                  } else {
                    _showErrorDialog('Please enter the content and select a category.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: Text('Create Thread'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
