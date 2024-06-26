import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String appointmentDate;
  final String startTime;
  final String endTime;
  final String reason;
  final String status;
  final Color color;
  final Map<String, dynamic> doctor;
  final String appointmentId; // Add appointment ID
  final Function(String) onCancel; // Add cancel function

  const AppointmentCard({
    Key? key,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.status,
    required this.color,
    required this.doctor,
    required this.appointmentId, // Initialize appointment ID
    required this.onCancel, // Initialize cancel function
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      doctor['doctor_profile'],
                    ),
                    radius: 30,
                    onBackgroundImageError: (_, __) => Icon(Icons.error),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['doctor_name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor['specialty'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Appointment Info
              Text(
                'Date: $appointmentDate',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                'Time: $startTime - $endTime',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                'Reason: $reason',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              // Conditionally Display Action Button
              if (status == 'Scheduled')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          onCancel(appointmentId); // Call the cancel function
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
