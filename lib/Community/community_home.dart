import 'package:flutter/material.dart';
import 'package:tender_touch/Community/addthread.dart';
import 'package:tender_touch/Profile/profile_page.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Threads'),
            Tab(text: 'Filter'),
          ],
          indicatorColor: Colors.blue[900],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ThreadsTab(),
          ForumsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddThreadPage()),
          );        },
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ThreadsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Replace with actual number of threads
      itemBuilder: (context, index) {
        return ThreadCard();
      },
    );
  }
}

class ThreadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[100],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do not let your child drink Soda!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Text('Salli Oranson', style: TextStyle(color: Colors.blue[900])),
                SizedBox(width: 8.0),
                Text('2h ago', style: TextStyle(color: Colors.blue[900])),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              'Drinking soda is the most dangerous thing to your child! Last day, I was going with my children on a family trip, suddenly I heard my child cuffing and asking for help..',
              style: TextStyle(color: Colors.blue[900]),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border_outlined, color: Colors.green),
                  onPressed: () {
                    // Like thread
                  },
                ),
                IconButton(
                  icon: Icon(Icons.comment_outlined, color: Colors.green),
                  onPressed: () {
                    // Open comments
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

class ForumsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.green),
              ),
              SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  FilterChip(
                    label: Text('Autism', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue[800],
                    onSelected: (selected) {
                      // Navigate to Autism forum
                    },
                  ),
                  FilterChip(
                    label: Text('ADHD', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue[800],
                    onSelected: (selected) {
                      // Navigate to ADHD forum
                    },
                  ),
                  FilterChip(
                    label: Text('Down Syndrome', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue[800],
                    onSelected: (selected) {
                      // Navigate to Down Syndrome forum
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10, // Replace with actual number of threads
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Thread Title', style: TextStyle(color: Colors.blue[800])),
                subtitle: Text('Author - Replies', style: TextStyle(color: Colors.green)),
                onTap: () {
                  // Navigate to thread detail
                },
              );
            },
          ),
        ),
      ],
    );
  }
}