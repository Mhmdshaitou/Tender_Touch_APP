import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tender_touch/Doctors/models/doctor.dart';

// Base API URL
const String _baseUrl = 'https://touchtender-web.onrender.com/v1';

// Custom Exception for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

// Fetch specific doctor by ID from the API
Future<Doctor> fetchDoctorDetailsById(int doctorId) async {
  final url = Uri.parse('$_baseUrl/dr/$doctorId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('API Response Data: $data'); // Print the raw API response data

    if (data['doctor'] != null) { // Checking if 'doctor' key exists
      try {
        final doctorData = data['doctor'];
        final doctor = Doctor.fromJson(doctorData);
        print(doctor); // Print the parsed Doctor object
        return doctor;
      } catch (e) {
        throw ApiException('Failed to parse doctor data: $e');
      }
    } else {
      throw ApiException('Doctor data is missing in the response');
    }
  } else {
    throw ApiException('API request failed with status code ${response.statusCode}');
  }
}
