import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import '../../../constants.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final List<Map<String, dynamic>> problems = [
    {
      'name': 'Seizures',
      'gif': 'images/emergency/emergency.gif',
      'details': 'Stay calm, protect the child from injury by moving objects'
          ' away, place them on their side, cushion their head, and time the seizure.'
          ' If it lasts longer than 5 minutes or if its their first seizure, call emergency services.',
    },
    {
      'name': 'Choking',
      'gif': 'images/emergency/choking.gif',
      'details': ' Perform appropriate first aid techniques such as back blows'
          ' and abdominal thrusts if the child is conscious. If the child becomes unconscious, perform CPR.',
    },
    {
      'name': 'Allergic reactions',
      'gif': 'images/emergency/allergy.gif',
      'details': '  Administer any prescribed medication (like an EpiPen) if the child is having a severe'
          ' allergic reaction. Stay with the child and monitor their breathing until help arrives.',
    },
    {
      'name': 'Breathing difficulties',
      'gif': 'images/emergency/breathing.gif',
      'details': '  Help the child into a comfortable position, provide any prescribed medication like an'
          ' inhaler, and stay calm to reassure them. If breathing difficulties worsen, call emergency services.',
    },
    {
      'name': 'Aggression or self-harm',
      'gif': 'images/emergency/aggressive.gif',
      'details': ' Try to remain calm and use gentle, reassuring words. Create a safe environment by removing any'
          ' objects that could be harmful. Provide sensory tools or techniques that usually help calm the child.',
    },
    {
      'name': 'Meltdowns or emotional distress',
      'gif': 'images/emergency/meltdowns.gif',
      'details': '  Offer comfort and support by using familiar routines or items that usually provide comfort to'
          ' the child. Allow them space if needed but stay nearby to ensure their safety.',
    },
    {
      'name': 'Burns',
      'gif': 'images/emergency/burns.gif',
      'details': 'Immediately cool the affected area under running water for at least 10 minutes for burns, or apply '
          'pressure to stop bleeding for cuts. Cover the area with a clean, dry cloth.',
    },
    {
      'name': 'Difficulty communicating needs',
      'gif': 'images/emergency/communication.gif',
      'details': 'Stay patient and use simple, clear language or visual aids if available. Try to understand '
          'the childs cues or gestures to figure out their needs.',
    },
    {
      'name': 'Shutdowns',
      'gif': 'images/emergency/shutdowns.gif',
      'details': ' Respect the childs need for space and quiet.'
          ' Provide a safe, comfortable area for them to relax and recover.',
    },
    // Add more problems here
  ];

  Future<void> _makeEmergencyCall() async {
    // Replace 'YOUR_EMERGENCY_NUMBER' with the desired emergency number
    const emergencyNumber = '140';
    final telUrl = 'tel:$emergencyNumber';

    if (await canLaunch(telUrl)) {
      await launch(telUrl);
    } else {
      throw 'Could not launch $telUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency First Aid'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: problems.length,
              itemBuilder: (context, index) {
                final problem = problems[index];
                return Card(
                  color: Constants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      problem['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFFFFD0EB),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 300,
                                child: Image.asset(
                                  problem['gif'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                problem['details'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: _makeEmergencyCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
              ),
              child: const Text(
                'For Emergency Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}