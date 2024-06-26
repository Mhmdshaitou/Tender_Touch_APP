import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:tender_touch/Appointment_System/utils/config.dart';
import 'package:tender_touch/Appointment_System/components/appointment_card.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

//enum for appointment status
enum FilterStatus { upcoming, complete, cancel }

class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.upcoming; //initial status
  Alignment _alignment = Alignment.centerLeft;
  List<dynamic> schedules = [];
  bool _isLoading = true;

  final storage = FlutterSecureStorage();

  //get appointments details
  Future<void> getAppointments() async {
    final token = await storage.read(key: 'auth_token');
    final userId = await storage.read(key: 'user_id');
    if (token == null || userId == null) {
      // Handle error: user not logged in
      return;
    }

    final url = 'https://touchtender-web.onrender.com/v1/appointment/user/$userId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        schedules = data['appointments'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
      print('Failed to load appointments');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      // Handle error: user not logged in
      return;
    }

    final url = 'https://touchtender-web.onrender.com/v1/appointment/$appointmentId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Refresh appointments after successful cancellation
      await getAppointments();
      setState(() {}); // Trigger a UI rebuild
    } else {
      // Handle error appropriately
      print('Failed to cancel appointment');
    }
  }

  @override
  void initState() {
    super.initState();
    getAppointments();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSchedules = schedules.where((var schedule) {
      switch (schedule['status']) {
        case 'Scheduled':
          return status == FilterStatus.upcoming;
        case 'Completed':
          return status == FilterStatus.complete;
        case 'Cancelled':
          return status == FilterStatus.cancel;
        default:
          return false;
      }
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Appointment Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Config.spaceSmall,
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //this is the filter tabs
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                status = filterStatus;
                                switch (filterStatus) {
                                  case FilterStatus.upcoming:
                                    _alignment = Alignment.centerLeft;
                                    break;
                                  case FilterStatus.complete:
                                    _alignment = Alignment.center;
                                    break;
                                  case FilterStatus.cancel:
                                    _alignment = Alignment.centerRight;
                                    break;
                                }
                              });
                            },
                            child: Center(
                              child: Text(filterStatus.name),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  alignment: _alignment,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Config.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Config.spaceSmall,
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: ((context, index) {
                  var schedule = filteredSchedules[index];
                  bool isLastElement = filteredSchedules.length + 1 == index;

                  final doctorProfile = 'https://touchtender-web.onrender.com${schedule['doctor_image']}' ?? '';
                  final doctorName = schedule['doctor_name'] ?? 'Unknown';
                  final doctorCategory = schedule['specialty'] ?? 'General';

                  // Extract and format the appointment date
                  final appointmentDate = schedule['appointment_date']?.split('T')?.first ?? 'N/A';

                  final startTime = schedule['start_time'] ?? 'N/A';
                  final endTime = schedule['end_time'] ?? 'N/A';
                  final appointmentId = schedule['appointment_id']?.toString() ?? 'N/A'; // Ensure appointment ID is a string

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0), // Add spacing between cards
                    child: AppointmentCard(
                      doctor: {
                        'doctor_profile': doctorProfile,
                        'doctor_name': doctorName,
                        'specialty': doctorCategory,
                      },
                      appointmentDate: appointmentDate,
                      startTime: startTime,
                      endTime: endTime,
                      reason: schedule['reason'] ?? 'No reason provided',
                      status: schedule['status'],
                      color: schedule['status'] == 'Scheduled'
                          ? Colors.green
                          : (schedule['status'] == 'Completed'
                          ? Colors.blue
                          : Colors.red),
                      appointmentId: appointmentId, // Pass the appointment ID
                      onCancel: cancelAppointment, // Pass the cancel function
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
