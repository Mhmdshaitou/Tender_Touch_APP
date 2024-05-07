import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF0681A8);
const double defaultPadding = 16.0;

class AddThreadPage extends StatefulWidget {
  @override
  _AddThreadPageState createState() => _AddThreadPageState();
}

class _AddThreadPageState extends State<AddThreadPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Thread',
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
              'Title',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              validator: (value) => value!.isEmpty ? 'Please write the Thread Title!' : null,
              decoration: InputDecoration(
                hintText: "Thread Title",
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
            Text(
              'Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
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
                  // Implement logic to create a new thread
                  final title = _titleController.text;
                  final content = _contentController.text;
                  // TODO: Create a new thread with the entered data
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