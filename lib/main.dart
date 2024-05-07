import 'package:flutter/material.dart';
import 'package:tender_touch/Doctors/ui/root_page.dart';
import 'package:tender_touch/Onbording/onbording.dart';
import 'package:tender_touch/HomePage/homepage.dart';
import 'package:tender_touch/login/screens/login/login_screen.dart';
import 'Activities/ActivitiesSuggestions.dart';
import 'Activities/activities.dart';
import 'Community/community_home.dart';
import 'Places/MainPlaces.dart';
import 'Places/places.dart';
import 'Places/places_form.dart';
void main()=> runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomePage(),
    );
  }
}