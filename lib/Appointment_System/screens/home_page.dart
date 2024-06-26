import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tender_touch/Appointment_System/components/appointment_card.dart';
import 'package:tender_touch/Appointment_System/components/doctor_card.dart';
import 'package:tender_touch/Appointment_System/models/auth_model.dart';
import 'package:tender_touch/Appointment_System/utils/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> user = {};
  Map<String, dynamic> doctor = {};
  List<dynamic> favList = [];
  bool _isLoading = true;
  List<dynamic> upcomingAppointments = [];
  bool _isAuthenticated = false;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final userId = await storage.read(key: 'user_id');
    final authModel = Provider.of<AuthModel>(context, listen: false);

    // Fetch doctor data from AuthModel provider
    await authModel.fetchDoctors();
    setState(() {
      user = authModel.getUser;
      doctor = authModel.getAppointment;
      favList = authModel.getFav;
      _isAuthenticated = true;
    });

    await _fetchUpcomingAppointments(userId!, token);
  }

  Future<void> _fetchUpcomingAppointments(String userId, String token) async {
    final url = 'https://touchtender-web.onrender.com/v1/appointment/user/$userId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('API Response: $data'); // Debugging statement

      setState(() {
        upcomingAppointments = data['appointments']
            .where((appointment) => appointment['status'] == 'Scheduled')
            .toList();
        print('Upcoming Appointments: $upcomingAppointments'); // Debugging statement
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
      final userId = await storage.read(key: 'user_id');
      await _fetchUpcomingAppointments(userId!, token);
      setState(() {}); // Trigger a UI rebuild
    } else {
      // Handle error appropriately
      print('Failed to cancel appointment');
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/homepage', // Navigate back to the appointment main page
                  (route) => false,
            );
          },
        ),
        title: Text('Doctor Page'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Config.spaceSmall,
                const Text(
                  'Upcoming Appointments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                !_isAuthenticated
                    ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Please login to view your appointments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : upcomingAppointments.isNotEmpty
                    ? Column(
                  children: List.generate(
                    upcomingAppointments.length,
                        (index) {
                      final appointment = upcomingAppointments[index];
                      print('Appointment: $appointment'); // Debugging statement

                      // Ensuring all fields are non-null
                      final appointmentDate = appointment['appointment_date']?.split('T')?.first ?? 'N/A';
                      final startTime = appointment['start_time'] ?? 'N/A';
                      final endTime = appointment['end_time'] ?? 'N/A';
                      final reason = appointment['reason'] ?? 'N/A';
                      final doctorProfile = appointment['doctor_image'] != null ? 'https://touchtender-web.onrender.com${appointment['doctor_image']}' : '';
                      final doctorName = appointment['doctor_name'] ?? 'Unknown';
                      final doctorCategory = appointment['specialty'] ?? 'General';
                      final appointmentId = appointment['appointment_id']?.toString() ?? 'N/A'; // Ensure appointment ID is a string

                      final doctorInfo = {
                        'doctor_profile': doctorProfile,
                        'doctor_name': doctorName,
                        'specialty': doctorCategory,
                      };

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0), // Add spacing between cards
                        child: AppointmentCard(
                          doctor: doctorInfo,
                          appointmentDate: appointmentDate,
                          startTime: startTime,
                          endTime: endTime,
                          reason: reason,
                          status: appointment['status'],
                          color: Config.primaryColor,
                          appointmentId: appointmentId, // Pass the appointment ID
                          onCancel: cancelAppointment, // Pass the cancel function
                        ),
                      );
                    },
                  ),
                )
                    : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No Appointments Today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Config.spaceSmall,
                const Text(
                  'Top Doctors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                user['doctor'] != null && user['doctor'].isNotEmpty
                    ? Column(
                  children: List.generate(user['doctor'].length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0), // Add spacing between cards
                      child: DoctorCard(
                        doctor: user['doctor'][index],
                        isFav: favList.contains(user['doctor'][index]['doctor_id']),
                      ),
                    );
                  }),
                )
                    : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No Doctors Available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
