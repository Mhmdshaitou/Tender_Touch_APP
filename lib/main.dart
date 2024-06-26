import 'package:flutter/material.dart';
import 'package:tender_touch/Chatbot/ChatApp.dart';
import 'package:tender_touch/Doctors/ui/root_page.dart';
import 'package:tender_touch/Onbording/onbording.dart';
import 'package:tender_touch/HomePage/homepage.dart';
import 'package:tender_touch/login/screens/login/login_screen.dart';
import 'Activities/activities.dart';
import 'Appointment_System/appointmentmain.dart'; // Ensure this import is correct
import 'Community/community_home.dart';
import 'HomePage/forcelogin.dart';
import 'Places/MainPlaces.dart';
import 'Places/places_form.dart';
import 'Profile/profile_page.dart';
import 'login/Screens/Login/components/email_verification.dart'; // Import EmailVerificationPage
import 'login/Screens/Login/components/code.dart'; // Import CodeVerificationPage
import 'login/Screens/Login/components/login_form.dart';
import 'login/Screens/Login/components/resetpage.dart'; // Import PasswordResetPage

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => HomePage(),
        UserProfilePage.routeName: (context) => UserProfilePage(),
        ForceloginPage.routeName: (context) => ForceloginPage(destinationRoute: '/'),
        LoginForm.routeName: (context) => LoginForm(destinationRoute: '/'),
        ChatScreen.routeName: (context) => ChatScreen(),
        CommunityPage.routeName: (context) => CommunityPage(),
        'appointment_main': (context) => const AppointmentmainPage(), // Correct route
        EmailVerificationPage.routeName: (context) => EmailVerificationPage(),
        CodeVerificationPage.routeName: (context) => CodeVerificationPage(),
        PasswordResetPage.routeName: (context) => PasswordResetPage(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => UnknownPage(),
        );
      },
    );
  }
}

class UnknownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unknown Page'),
      ),
      body: Center(
        child: Text('404 - Page Not Found'),
      ),
    );
  }
}
