import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tender_touch/Doctors/models/doctor.dart';

Future<List<Doctor>> fetchDoctorsFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:7000/v1/dr'));

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);

    if (responseBody['doctors'] != null) {
      List<dynamic> doctorListJson = responseBody['doctors'];

      return doctorListJson.map((json) => Doctor.fromJson(json)).toList();
    } else {
      // Handle case where 'doctors' key is null
      throw Exception('Doctors data is null');
    }
  } else {
    // Handle HTTP error status codes
    throw Exception('Failed to load doctors: ${response.statusCode}');
  }
}
