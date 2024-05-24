import 'package:flutter/material.dart';

import '../login/Screens/Login/login_screen.dart';



class ForceloginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Required'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Assuming the user is navigating back to a previous page
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/home_images/forcelogin.png',
              width: 300,
              height: 300,
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'This content requires login. Please login to proceed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Lets Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                // Assuming the user is navigating back to a previous page
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

