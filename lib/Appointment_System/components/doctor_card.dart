import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tender_touch/Appointment_System/appointmentmain.dart';
import 'package:tender_touch/Appointment_System/screens/doctor_details.dart';
import 'package:tender_touch/Appointment_System/utils/config.dart';

class DoctorsList extends StatefulWidget {
  @override
  _DoctorsListState createState() => _DoctorsListState();
}

class _DoctorsListState extends State<DoctorsList> {
  List<dynamic> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors List'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _doctors.length,
        itemBuilder: (context, index) {
          return DoctorCard(
            doctor: _doctors[index],
            isFav: false,
          );
        },
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.isFav,
  }) : super(key: key);

  final Map<String, dynamic> doctor;
  final bool isFav;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 150,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                width: Config.widthSize * 0.33,
                child: doctor['doctor_image'] != null && doctor['doctor_image'].isNotEmpty
                    ? Image.network(
                  "https://touchtender-web.onrender.com${doctor['doctor_image']}",
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                )
                    : Icon(Icons.person, size: 80),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${doctor['doctor_name']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${doctor['specialty']}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.phone,
                            color: Colors.green,
                            size: 16,
                          ),
                          Spacer(flex: 1),
                          Text(doctor['number']),
                          Spacer(flex: 7),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          AppointmentmainPage.navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (_) => DoctorDetails(
                doctor: doctor,
                isFav: isFav,
              )));
        },
      ),
    );
  }
}
