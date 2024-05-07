import 'package:flutter/material.dart';
import 'package:tender_touch/Doctors/constants.dart';
import 'package:tender_touch/Doctors/models/doctor.dart';
import 'package:tender_touch/Doctors/ui/screens/home_page.dart';
import 'package:tender_touch/Doctors/ui/screens/favorite_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tender_touch/Doctors/apifetch.dart'; // Ensure this import exists

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Doctor> favorites = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // Fetch favorited doctors from the API
  Future<void> _fetchFavorites() async {
    try {
      List<Doctor> doctors = await fetchDoctorsFromApi();
      setState(() {
        favorites = doctors.where((doctor) => doctor.isFavorite).toList();
      });
    } catch (e) {
      // Handle error gracefully, such as showing a snackbar or logging the error
      print('Failed to load favorited doctors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Doctors', // Assuming 'Doctors' is the title for the Home Page
              style: TextStyle(
                color: Constants.blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: const HomePage(), // Directly display the Home Page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: FavoritePage(favoriteddoctors: favorites),
            ),
          );
        },
        child: const Icon(Icons.favorite, color: Colors.white),
        backgroundColor: Constants.blackColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
