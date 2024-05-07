import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ActivitySuggestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> suggestions; // Define the suggestions parameter

  const ActivitySuggestionsPage({Key? key, required this.suggestions}) : super(key: key);

  @override
  _ActivitySuggestionsPageState createState() => _ActivitySuggestionsPageState();
}

class _ActivitySuggestionsPageState extends State<ActivitySuggestionsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Suggestions'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 300,
              autoPlay: false,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: widget.suggestions.map((suggestion) {
              return Builder(
                builder: (BuildContext context) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion['Title'],
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(suggestion['Details']),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % widget.suggestions.length;
                  });
                },
                child: Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement your logic here
                },
                child: Text('Choose'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
