import 'package:flutter/material.dart';
import 'package:tender_touch/Chatbot/ChatApp.dart';
import 'package:tender_touch/Doctors/ui/root_page.dart';
import 'package:tender_touch/Onbording/onbording.dart';
import 'package:tender_touch/HomePage/homepage.dart';
import 'package:tender_touch/login/screens/login/login_screen.dart';
import 'Activities/activities.dart';
import 'Community/community_home.dart';
import 'HomePage/forcelogin.dart';
import 'Places/MainPlaces.dart';
import 'Places/places_form.dart';
import 'Profile/profile_page.dart';
import 'login/Screens/Login/components/login_form.dart';

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
        '/': (context) => Onboarding(),
        UserProfilePage.routeName: (context) => UserProfilePage(),
        ForceloginPage.routeName: (context) => ForceloginPage(destinationRoute: '/'),
        LoginForm.routeName: (context) => LoginForm(destinationRoute: '/'),
        ChatScreen.routeName: (context) => ChatScreen(),
        CommunityPage.routeName: (context) => CommunityPage(),
      },
    );
  }
}
