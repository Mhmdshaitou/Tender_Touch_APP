import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tender_touch/Places/places_form.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class PlacesMainPage extends StatefulWidget {
  @override
  _PlacesMainPageState createState() => _PlacesMainPageState();
}

class _PlacesMainPageState extends State<PlacesMainPage> {
  List<Place> places = [];
  List<Place> filteredPlaces = [];
  String searchQuery = '';
  String classification = '';
  final String baseUrl = 'https://touchtender-web.onrender.com/v1'; // Change this to your server's IP address or hostname
  final String imageUrlBase = 'https://touchtender-web.onrender.com'; // Base URL for images

  final storage = FlutterSecureStorage();
  bool isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
    fetchPlaces();
  }

  Future<void> checkUserLoggedIn() async {
    try {
      await getUserIdFromToken();
      setState(() {
        isUserLoggedIn = true;
      });
    } catch (e) {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  Future<void> fetchPlaces() async {
    final response = await http.get(Uri.parse('$baseUrl/place/approved'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Place> loadedPlaces = (data['places'] as List).map<Place>((json) => Place.fromJson(json)).toList();

      // Fetch average ratings for each place
      for (var place in loadedPlaces) {
        place.rating = await fetchAverageRating(place.placeid);
      }

      setState(() {
        places = loadedPlaces;
        filteredPlaces = places;
      });
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<double?> fetchAverageRating(int placeID) async {
    final response = await http.get(Uri.parse('$baseUrl/place/ratings/average/$placeID'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['averageRating']?.toDouble();
    } else {
      throw Exception('Failed to load average rating');
    }
  }

  Future<int> getUserIdFromToken() async {
    String? token = await storage.read(key: 'auth_token');
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      return payload['userId']; // Adjust the key based on your JWT structure
    }
    throw Exception('Token not found');
  }

  void filterPlaces(String query, String classification) {
    setState(() {
      searchQuery = query;
      this.classification = classification;
      filteredPlaces = places
          .where((place) =>
      place.name.toLowerCase().contains(query.toLowerCase()) &&
          (classification == 'All' || place.classification == classification))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.green[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => filterPlaces(value, classification),
                decoration: InputDecoration(
                  hintText: 'Search places',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => FilterDialog(
                          onFilter: (classification) {
                            filterPlaces(searchQuery, classification);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 170,
              child: Image.asset(
                'images/places/addplace.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8.0),
                  const Text(
                    textAlign: TextAlign.center,
                    'Request to add a new place to help others!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlacesForm(),
                        ),
                      );
                    },
                    child: const Text('Add Place'),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            Column(
              children: List.generate(
                filteredPlaces.length,
                    (index) {
                  final place = filteredPlaces[index];
                  return PlaceCard(
                    place: place,
                    onTap: () {
                      showPlaceDetailsDialog(context, place);
                    },
                    imageUrlBase: imageUrlBase,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPlaceDetailsDialog(BuildContext context, Place place) {
    showDialog(
      context: context,
      builder: (context) => PlaceDetailsDialog(
        place: place,
        onRate: (rating) {
          submitRating(place.placeid, rating);
        },
        onLocation: () {
          _launchURL(place.location);
        },
        imageUrlBase: imageUrlBase,
        isUserLoggedIn: isUserLoggedIn,
      ),
    );
  }

  Future<void> submitRating(int placeID, int rating) async {
    try {
      int userID = await getUserIdFromToken();
      final response = await http.post(
        Uri.parse('$baseUrl/place/ratings/$placeID'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rating': rating,
          'userId': userID,
        }),
      );

      if (response.statusCode == 201) {
        // Fetch the updated average rating from the server
        double? updatedAvgRating = await fetchAverageRating(placeID);

        // Update the rating locally
        setState(() {
          var placeIndex = places.indexWhere((place) => place.placeid == placeID);
          if (placeIndex != -1) {
            places[placeIndex].rating = updatedAvgRating;
            filteredPlaces = List.from(places);
          }
        });
      } else {
        throw Exception('Failed to submit rating: ${response.body}');
      }
    } catch (e) {
      print('Error submitting rating: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final String imageUrlBase;

  PlaceCard({required this.place, required this.onTap, required this.imageUrlBase});

  @override
  Widget build(BuildContext context) {
    var imageUrl = place.photos.isNotEmpty ? '$imageUrlBase${place.photos.first.photoUrl}' : 'https://via.placeholder.com/300x100';
    print('Image URL: $imageUrl');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                imageUrl,
                width: 600,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  print('Error loading image: $exception');
                  return Container(
                    width: 300,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('Error loading image'),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(place.classification),
                    Text(place.description ?? ''),
                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          index < (place.rating?.round() ?? 0) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final Function(String) onFilter;

  FilterDialog({required this.onFilter});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String selectedClassification = 'All';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter Places'),
      content: DropdownButton<String>(
        value: selectedClassification,
        onChanged: (value) {
          setState(() {
            selectedClassification = value ?? 'All';
          });
        },
        items: ['All', 'Restaurant', 'Cinema', 'Playground', 'School', 'Garden']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onFilter(selectedClassification);
            Navigator.pop(context);
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}

class PlaceDetailsDialog extends StatefulWidget {
  final Place place;
  final Function(int) onRate;
  final VoidCallback onLocation;
  final String imageUrlBase;
  final bool isUserLoggedIn;

  PlaceDetailsDialog({
    required this.place,
    required this.onRate,
    required this.onLocation,
    required this.imageUrlBase,
    required this.isUserLoggedIn,
  });

  @override
  _PlaceDetailsDialogState createState() => _PlaceDetailsDialogState();
}

class _PlaceDetailsDialogState extends State<PlaceDetailsDialog> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    var imageUrl = widget.place.photos.isNotEmpty ? '${widget.imageUrlBase}${widget.place.photos.first.photoUrl}' : 'https://via.placeholder.com/300x100';
    return AlertDialog(
      title: Text(
        widget.place.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imageUrl,
              width: 600,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                print('Error loading image: $exception');
                return Container(
                  width: 300,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('Error loading image'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.place.classification,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text((widget.place.region ?? '') + ' - ' + (widget.place.city ?? '')),
            Text(widget.place.description ?? ''),
            ...widget.place.services.map((service) => ListTile(
              title: Text(service.servicename),
              subtitle: Text(service.description),
            )).toList(),
            if (widget.isUserLoggedIn) ...[
              Text('Rate this place: '),
              Row(
                children: List.generate(
                  5,
                      (index) => GestureDetector(
                    onTap: () => setState(() => rating = index + 1),
                    child: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.isUserLoggedIn)
          TextButton(
            onPressed: () {
              widget.onRate(rating);
              Navigator.pop(context);
            },
            child: Text('Rate'),
          ),
        TextButton(
          onPressed: widget.onLocation,
          child: Text('Visit now!'),
        ),
      ],
    );
  }
}

class Place {
  final int placeid;
  final int userid;
  final String name;
  final String classification;
  final String region;
  final String city;
  final String location;
  final String status;
  final DateTime createdAt;
  double? rating;
  final String? description;
  final List<Photo> photos;
  final List<Service> services;

  Place({
    required this.placeid,
    required this.userid,
    required this.name,
    required this.classification,
    required this.region,
    required this.city,
    required this.location,
    required this.status,
    required this.createdAt,
    this.rating,
    this.description,
    required this.photos,
    required this.services,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeid: json['placeid'],
      userid: json['userid'],
      name: json['name'],
      classification: json['classification'],
      region: json['region'],
      city: json['city'],
      location: json['location'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      rating: json['rating']?.toDouble(),
      description: json['description'],
      photos: (json['photos'] as List).map((photoJson) => Photo.fromJson(photoJson)).toList(),
      services: (json['services'] as List).map((serviceJson) => Service.fromJson(serviceJson)).toList(),
    );
  }
}

class Service {
  final int serviceid;
  final String servicename;
  final String description;

  Service({required this.serviceid, required this.servicename, required this.description});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceid: json['serviceid'],
      servicename: json['servicename'],
      description: json['description'],
    );
  }
}

class Photo {
  final int photoid;
  final int placeid;
  final String photoUrl;

  Photo({required this.photoid, required this.placeid, required this.photoUrl});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoid: json['photoid'],
      placeid: json['placeid'],
      photoUrl: json['photo_url'],
    );
  }
}
