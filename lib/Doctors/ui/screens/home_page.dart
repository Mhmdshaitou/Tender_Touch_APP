import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tender_touch/Doctors/constants.dart';
import 'package:tender_touch/Doctors/models/doctor.dart';
import 'package:tender_touch/Doctors/ui/screens/detail_page.dart';
import 'package:tender_touch/Doctors/ui/screens/widgets/doctor_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tender_touch/Doctors/apifetch.dart';
import 'package:tender_touch/Doctors/ui/screens/widgets/emergency.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  late Future<List<Doctor>> _futureDoctors;
  int selectedIndex = 0;
  String? selectedRegion;
  List<String> regions = [
    "All", "Beirut", "Tyre", "Bekaa", "Nabatieh", "Jounieh", "Jbeil", "Baabda", "Aley", "Matn", "Chouf", "Tripoli", "Akkar",
    "Miniyeh-Danniyeh", "Zgharta", "Bcharre", "Koura", "Batroun", "Zahle", "Baalbek",
    "Hermel", "Rashaya", "El Bekaa", "Bint Jbeil", "Hasbaya", "Marjeyoun", "Saida",
    "Jezzine"
  ];
  @override
  void initState() {
    super.initState();
    _futureDoctors = fetchDoctorsFromApi(); // Fetching doctors from the API
  }

  Future<List<Doctor>> _fetchAndFilterDoctors() async {
    List<Doctor> doctors = await fetchDoctorsFromApi();
    if (selectedRegion == null || selectedRegion == "All") {
      return doctors;
    } else {
      return doctors.where((doctor) => doctor.region == selectedRegion).toList();
    }
  }

  bool toggleIsFavorated(bool isFavorated) {
    return !isFavorated;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.black54.withOpacity(.6),
                          ),
                          const Expanded(
                            child: TextField(
                              showCursor: true,
                              decoration: InputDecoration(
                                hintText: 'Search Doctors',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRegion,
                        icon: const Icon(Icons.filter_list, color: Colors.deepPurple),
                        elevation: 0,
                        style: const TextStyle(color: Colors.deepPurple),
                        hint: const Text("Region"), // Added hint text
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRegion = newValue;
                            _futureDoctors = _fetchAndFilterDoctors();
                          });
                        },
                        items: regions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50.0,
              width: size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            FutureBuilder<List<Doctor>>(
              future: _futureDoctors,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No doctors found in this region'));
                }

                List<Doctor> _doctorList = snapshot.data!;

                return SizedBox(
                  height: size.height * .3,
                  child: ListView.builder(
                    itemCount: _doctorList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: DetailPage(
                                doctorId: _doctorList[index].id, // Pass the doctor's ID
                              ),
                              type: PageTransitionType.bottomToTop,
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 10,
                                right: 20,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        bool isFavorated = toggleIsFavorated(
                                            _doctorList[index].isFavorite);
                                        _doctorList[index]
                                            .isFavorite = isFavorated;
                                      });
                                    },
                                    icon: Icon(
                                      _doctorList[index].isFavorite == true
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Constants.primaryColor,
                                    ),
                                    iconSize: 30,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 50,
                                right: 50,
                                top: 50,
                                bottom: 50,
                                child:
                                Image.network(_doctorList[index].image),
                              ),
                              Positioned(
                                bottom: 15,
                                left: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _doctorList[index].specialty,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _doctorList[index].name,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 15,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withOpacity(.8),
                            borderRadius: BorderRadius.circular(20),
                          ),

                        ),
                      );
                    },
                  ),
                );
              },

            ),
            Container(
              margin: const EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                color: Constants.primaryColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 300,
                    child: Image.asset(
                      'images/emergency/emergency.gif', // Replace with your GIF path
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Emergency First Aid',
                          style: TextStyle(

                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          textAlign: TextAlign.center,
                          'We provide crucial guidance during emergencies for children '
                              'with special needs until professional medical assistance arrives.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyPage(),
                              ),
                            );
                          },
                          child: const Text('Go to Emergency Page'),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
