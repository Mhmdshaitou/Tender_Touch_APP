import 'package:flutter/material.dart';
import 'package:tender_touch/Doctors/constants.dart';
import 'package:tender_touch/Doctors/models/doctor.dart';
import 'package:tender_touch/Doctors/ui/screens/widgets/doctor_widget.dart';
import 'package:tender_touch/Doctors/apifetch.dart';


class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key, required List<Doctor> favoriteddoctors}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Doctor>> _futureFavoritedDoctors;

  @override
  void initState() {
    super.initState();
    // Fetch favorited doctors from the API
    _futureFavoritedDoctors = fetchFavoritedDoctorsFromApi();
  }

  Future<List<Doctor>> fetchFavoritedDoctorsFromApi() async {
    // Fetch the list of doctors
    List<Doctor> doctors = await fetchDoctorsFromApi();

    // Filter for favorited doctors
    return doctors.where((doctor) => doctor.isFavorite).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder<List<Doctor>>(
        future: _futureFavoritedDoctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: Image.asset('images/home_images/favorited.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No favorited doctors',
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          List<Doctor> favoritedDoctors = snapshot.data!;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
            height: size.height * .5,
            child: ListView.builder(
              itemCount: favoritedDoctors.length,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return DoctorWidget(
                  index: index,
                  doctorList: favoritedDoctors,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
