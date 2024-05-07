import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
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
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Today'),
            Tab(text: 'History'),
          ],
          indicatorColor: Colors.green,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TodayNotifications(),
          NotificationHistory(),
        ],
      ),
    );
  }
}

class TodayNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Replace with actual number of today's notifications
      itemBuilder: (context, index) {
        return NotificationCard(
          title: 'New Reply on Your Thread',
          body: 'Zeinab replied to your thread "Do not let your child drink Soda!"',
          timestamp: '2 hours ago',
        );
      },
    );
  }
}

class NotificationHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Replace with actual number of past notifications
      itemBuilder: (context, index) {
        return NotificationCard(
          title: 'Thread Updated',
          body: 'Your thread "Dealing with ADHD" has been updated with new replies.',
          timestamp: '3 days ago',
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String timestamp;

  NotificationCard({
    required this.title,
    required this.body,
    required this.timestamp,
  });

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
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              body,
              style: TextStyle(color: Colors.purple[800]),
            ),
            SizedBox(height: 8.0),
            Text(
              timestamp,
              style: TextStyle(color: Colors.purple[800]),
            ),
          ],
        ),
      ),
    );
  }
}