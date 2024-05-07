import 'package:flutter/material.dart';
import 'package:tender_touch/Doctors/constants.dart';
import 'package:tender_touch/Doctors/models/doctor.dart';
import 'package:tender_touch/Doctors/apifetchbyid.dart'; // Ensure this imports the new function

class DetailPage extends StatefulWidget {
  final int doctorId;
  const DetailPage({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Doctor?> _futureDoctor;

  @override
  void initState() {
    super.initState();
    // Fetch doctor details using the specific API call
    _futureDoctor = fetchDoctorDetailsById(widget.doctorId);
  }

  bool toggleIsFavorated(bool isFavorated) {
    return !isFavorated;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder<Doctor?>(
        future: _futureDoctor,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Doctor not found'));
          }

          Doctor doctor = snapshot.data!;

          return Stack(
            children: [
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Constants.primaryColor.withOpacity(.15),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Constants.primaryColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          doctor.isFavorite = toggleIsFavorated(doctor.isFavorite);
                        });
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Constants.primaryColor.withOpacity(.15),
                        ),
                        child: Icon(
                          doctor.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Constants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: Container(
                  width: size.width * .8,
                  height: size.height * .8,
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 0,
                        child: SizedBox(
                          height: 350,
                          child: Image.network(doctor.image),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 0,
                        child: SizedBox(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DoctorFeature(
                                title: 'Specialty',
                                doctorFeature: doctor.specialty,
                              ),
                              DoctorFeature(
                                title: 'Number',
                                doctorFeature: doctor.number,
                              ),
                              DoctorFeature(
                                title: 'Experience',
                                doctorFeature: doctor.experience.toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 80, left: 30, right: 30),
                  height: size.height * .5,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(.4),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: TextStyle(
                                  color: Constants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Expanded(
                        child: Text(
                          doctor.description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 18,
                            color: Constants.blackColor.withOpacity(.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        width: size.width * .9,
        height: 50,
        decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 5,
              color: Constants.primaryColor.withOpacity(.3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Contact Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}

class DoctorFeature extends StatelessWidget {
  final String doctorFeature;
  final String title;
  const DoctorFeature({
    Key? key,
    required this.doctorFeature,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Constants.blackColor,
          ),
        ),
        Text(
          doctorFeature,
          style: TextStyle(
            color: Constants.primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
