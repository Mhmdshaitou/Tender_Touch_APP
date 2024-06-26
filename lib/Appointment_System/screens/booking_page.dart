import 'package:flutter/material.dart';
import 'package:tender_touch/Appointment_System/screens/success_booked.dart'; // Ensure this is the correct path
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tender_touch/Appointment_System/components/button.dart';
import 'package:tender_touch/Appointment_System/components/custom_appbar.dart';
import 'package:tender_touch/Appointment_System/utils/config.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingPage extends StatefulWidget {
  BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = true; // Change to true to fetch slots for current day initially
  bool _timeSelected = false;
  String? token;
  String? userId;
  List<dynamic> availableTimeSlots = [];
  final TextEditingController _reasonController = TextEditingController();
  final storage = FlutterSecureStorage();

  Future<void> getTokenAndUserId() async {
    token = await storage.read(key: 'auth_token');
    userId = await storage.read(key: 'user_id');
    setState(() {});
  }

  Future<void> fetchAvailableTimeSlots(int doctorId, DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = 'https://touchtender-web.onrender.com/v1/appointment/available-time-slots/$doctorId/$formattedDate';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Available time slots: $data'); // Debugging statement
        setState(() {
          availableTimeSlots = data['availableTimeSlots'];
        });
      } else {
        setState(() {
          availableTimeSlots = [];
        });
        print('Failed to fetch available time slots: ${response.body}'); // Debugging statement
      }
    } catch (e) {
      setState(() {
        availableTimeSlots = [];
      });
      print('Error fetching available time slots: $e'); // Debugging statement
    }
  }

  Future<void> bookAppointment(
      int doctorId,
      String userId,
      DateTime date,
      String startTime,
      String endTime,
      String reason
      ) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = 'https://touchtender-web.onrender.com/v1/appointment';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'userId': userId,
      'doctorId': doctorId,
      'appointmentDate': formattedDate,
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
    });

    // Print the data being sent to the API
    print('Booking appointment with data:');
    print('userId: $userId');
    print('doctorId: $doctorId');
    print('appointmentDate: $formattedDate');
    print('startTime: $startTime');
    print('endTime: $endTime');
    print('reason: $reason');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AppointmentBooked(), // Navigate to success page
        ));
      } else {
        print('Failed to book appointment: ${response.body}');
        showErrorDialog(context, 'Failed to book appointment: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      showErrorDialog(context, 'Error: $e');
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getTokenAndUserId().then((_) {
      final doctor = ModalRoute.of(context)!.settings.arguments as Map;
      fetchAvailableTimeSlots(doctor['doctor_id'], _currentDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final doctor = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Appointment',
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(doctor['doctor_id']),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      'Select Consultation Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 30),
              alignment: Alignment.center,
              child: const Text(
                'Weekend is not available, please select another date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
              : availableTimeSlots.isEmpty
              ? SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              alignment: Alignment.center,
              child: const Text(
                'No available time slots for the selected date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
              : SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final timeSlot = availableTimeSlots[index];
                final startTime = timeSlot['start_time'];
                final endTime = timeSlot['end_time'];

                return InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                      _timeSelected = true;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      color: _currentIndex == index
                          ? Config.primaryColor
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                        _currentIndex == index ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              },
              childCount: availableTimeSlots.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 1.5),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: TextField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Reason for Appointment',
                    ),
                    maxLines: 3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Button(
                    width: double.infinity,
                    title: 'Make Appointment',
                    onPressed: () async {
                      if (!_timeSelected || !_dateSelected || token == null || userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select date and time for the appointment'),
                          ),
                        );
                        return;
                      }

                      final selectedSlot = availableTimeSlots[_currentIndex!];
                      final startTime = selectedSlot['start_time'];
                      final endTime = selectedSlot['end_time'];
                      final reason = _reasonController.text;

                      await bookAppointment(
                        doctor['doctor_id'],
                        userId!,
                        _currentDay,
                        startTime,
                        endTime,
                        reason,
                      );
                    },
                    disable: _timeSelected && _dateSelected ? false : true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCalendar(int doctorId) {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2024, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration:
        BoxDecoration(color: Config.primaryColor, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (focusedDay.isBefore(DateTime(2024, 12, 31))) {
          setState(() {
            _currentDay = selectedDay;
            _focusDay = focusedDay;
            _dateSelected = true;
            _timeSelected = false;
            _currentIndex = null;

            if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
              _isWeekend = true;
              availableTimeSlots = [];
            } else {
              _isWeekend = false;
              fetchAvailableTimeSlots(doctorId, selectedDay);
            }
          });
        }
      },
    );
  }
}
