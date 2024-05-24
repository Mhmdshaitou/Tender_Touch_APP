import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final _phoneController = TextEditingController(text: "+96181607875");  // Replace with your actual phone number
  final _emailController = TextEditingController(text: "support@tendertouch.com");  // Replace with your support email

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Color(0xFF93DBFF), // Adjust the color to fit your theme
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Get in Touch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'For any questions or issues, please contact us using the information below or send us a message directly through these links!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Divider(),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text(_emailController.text),
              onTap: () => _launchUrl("mailto:${_emailController.text}"),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Call Us'),
              subtitle: Text(_phoneController.text),
              onTap: () => _launchUrl("tel:${_phoneController.text}"),
            ),
          ],
        ),
      ),
    );
  }
}
