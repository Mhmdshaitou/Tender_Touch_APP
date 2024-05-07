import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: AssetImage('images/home_images/profile.jpg'),
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mohammad Shaitou',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.purple[800],
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'shaitoumohammad@gmail.com',
                        style: TextStyle(color: Colors.purple[800]),
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.green,
                            size: 16.0,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            '250 Likes',
                            style: TextStyle(color: Colors.purple[800]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to settings page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[800],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Settings'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Perform logout
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[800],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Logout'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Divider(
                color: Colors.purple[800],
                thickness: 1.0,
              ),
              SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 10, // Replace with actual number of threads
                itemBuilder: (context, index) {
                  return ThreadCard();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add thread page
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ThreadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple[100],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do not let your child drink Soda!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  Icons.comment,
                  color: Colors.purple[800],
                  size: 16.0,
                ),
                SizedBox(width: 4.0),
                Text(
                  '10 Replies',
                  style: TextStyle(color: Colors.purple[800]),
                ),
                SizedBox(width: 16.0),
                Icon(
                  Icons.favorite,
                  color: Colors.green,
                  size: 16.0,
                ),
                SizedBox(width: 4.0),
                Text(
                  '25 Likes',
                  style: TextStyle(color: Colors.purple[800]),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              'Drinking soda is the most dangerous thing to your child! Last day, I was going with my children on a family trip, suddenly I heard my child cuffing and asking for help..',
              style: TextStyle(color: Colors.purple[800]),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Delete thread
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    // Edit thread
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}