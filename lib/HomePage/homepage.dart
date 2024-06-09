import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tender_touch/Activities/activities.dart';
import 'package:tender_touch/Community/community_home.dart';
import 'package:tender_touch/Doctors/ui/root_page.dart';
import 'package:tender_touch/Places/MainPlaces.dart';
import '../Chatbot/ChatApp.dart';
import '../Profile/profile_page.dart';
import 'notifications.dart';

void main() {
  runApp(HomePage());
}

const Color appBarColor = Color(0xFFFFFFFF);
const Color searchFieldColor = Color(0xFFE7E1E1);
const Color buttonColor1 = Color(0xFFA6FAFF);
const Color buttonColor2 = Color(0xFFF4BDDE);
const Color buttonColor3 = Color(0xFF0681A8);
const Color buttonColor4 = Color(0xFF0A7342);
const Color buttonColor5 = Color(0xFFFFA1A1);
const Color doctorTileBackgroundColor = Color(0xFF123456);
const Color bottomNavBarColor = Color(0xFF123456);

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tender Touch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomAppBarTheme: BottomAppBarTheme(
          color: bottomNavBarColor,
          elevation: 8,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  Timer? _timer;
  List<String> storyImages = ['images/slider/slider2.jpg', 'images/slider/slider1.jpg', 'images/slider/slider3.jpg', 'images/slider/slider2.jpg', 'images/slider/slider3.jpg'];
  List<String> storyLabels = ['Garden Vibes', 'Relaxing!', 'Dinner', 'Lets play!', 'Education'];
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_pageController.page == 3) {
        _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
      } else {
        _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<String> fetchUserName() async {
    String? userId = await storage.read(key: 'user_id');
    if (userId == null) {
      throw Exception('User ID not found, please login again.');
    }
    final response = await http.get(Uri.parse('http://localhost:7000v1/auth/user/$userId'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var fullName = data['user']['fullName'];
      var firstName = fullName.split(' ')[0];
      return firstName;
    } else {
      throw Exception('Hello Dear');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[20],
        title: FutureBuilder<String>(
          future: fetchUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Hello Dear!');
              }
              return Text('Hii ${snapshot.data}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              height: 300,
              child: PageView(
                controller: _pageController,
                children: [
                  _buildCarouselItem('images/slider/slider1.jpg', 'Welcome'),
                  _buildCarouselItem('images/slider/slider2.jpg', 'To'),
                  _buildCarouselItem('images/slider/slider3.jpg', 'Our'),
                  _buildCarouselItem('images/slider/slider4.jpg', 'Community'),
                ],
              ),
            ),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: storyImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: Image.asset(storyImages[index], fit: BoxFit.cover),
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(storyImages[index]),
                            backgroundColor: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          storyLabels[index],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            MenuGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath, String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 300,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MenuButton(title: 'Chat AI',
                    iconPath: 'images/menubuttons/chatbot.png',
                    color: buttonColor1),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommunityPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MenuButton(title: 'Community',
                    iconPath: 'images/menubuttons/community.png',
                    color: buttonColor3),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlacesMainPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MenuButton(
                    title: 'Places',
                    iconPath: 'images/menubuttons/places.png',
                    color: buttonColor4),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivitiesPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MenuButton(
                    title: 'Activities',
                    iconPath: 'images/menubuttons/activities.png',
                    color: buttonColor5),
              ),
            ),
          ],
        ),
        Container(
          height: 280, // Set the desired height here
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RootPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MenuButton(
                title: 'Doctor',
                iconPath: 'images/menubuttons/doctors.png',
                color: buttonColor2,
                imageHeight: 250, // Set the desired image height here
                imageWidth: 250,  // Set the desired image width here
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color color;
  final double? imageHeight;
  final double? imageWidth;

  const MenuButton({Key? key, required this.title, required this.iconPath, required this.color, this.imageHeight, this.imageWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                iconPath,
                height: imageHeight ?? 130, // Use the provided image height if available
                width: imageWidth ?? 130,   // Use the provided image width if available
              ),
            ),
          ),
        ],
      ),
    );
  }
}
