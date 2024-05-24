import '../apifetchbyid.dart';

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String number;
  final String description;
  final int experience;
  final String region;
  final String image;
  late final bool isFavorite;

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialty: $specialty, number: $number,region: $region, description: $description, experience: $experience, image: $image, isFavorite: $isFavorite)';
  }

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.number,
    required this.region,
    required this.description,
    required this.experience,
    required this.image,
    this.isFavorite = false, // Default value for isFavorite
  });

  factory Doctor.fromJson(Map<String, dynamic> json, {bool nested = false}) {
    Map<String, dynamic> doctorData = nested ? (json['doctor'] ?? {}) : json;
    try {
      return Doctor(
        id: doctorData['doctor_id'] ?? 0,
        name: doctorData['doctor_name'] ?? '',
        specialty: doctorData['specialty'] ?? '',
        number: doctorData['number'] ?? '',
        region: doctorData['region'] ?? '',
        description: doctorData['description'] ?? '',
        experience: doctorData['experience'] ?? 0,
        image: doctorData['doctor_image'] ?? '',
        isFavorite: doctorData['is_favorite'] ?? false,
      );
    } catch (e) {
      print('Failed to parse doctor data: $e');
      throw ApiException('Failed to parse doctor data: $e');
    }
  }



}
