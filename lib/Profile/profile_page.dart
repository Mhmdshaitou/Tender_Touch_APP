import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tender_touch/Profile/setting.dart';
import 'package:tender_touch/login/Screens/Login/login_screen.dart';

import '../Community/addthread.dart';
import 'editpage.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<Comment> _comments = [];
  final storage = FlutterSecureStorage();
  Map<int, int> _totalLikes = {};
  Map<int, List<dynamic>> _replies = {};
  String _fullName = 'Loading...';
  String _email = 'Loading...';
  String _profileImage = 'images/home_images/male_avatar.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchComments().then((comments) {
      setState(() {
        _comments = comments;
        _fetchTotalLikes(comments);
        _fetchAllReplies(comments);
      });
    });
  }

  Future<List<Comment>> _fetchComments() async {
    String? userId = await storage.read(key: 'user_id');

    if (userId == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse('https://touchtender-web.onrender.com/v1/community/comments/user/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> jsonComments = jsonResponse['comments'];
      final List<Comment> comments =
      jsonComments.map((json) => Comment.fromJson(json)).toList();
      return comments;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _fetchTotalLikes(List<Comment> comments) async {
    for (var comment in comments) {
      final response = await http.get(
        Uri.parse('https://touchtender-web.onrender.com/v1/community/totallikes/${comment.commentId}'),
      );

      if (response.statusCode == 200) {
        final totalLikes = json.decode(response.body)['totalLikes'];
        setState(() {
          _totalLikes[comment.commentId] = totalLikes;
        });
      } else {
        throw Exception('Failed to load total likes');
      }
    }
  }

  Future<void> _fetchAllReplies(List<Comment> comments) async {
    for (var comment in comments) {
      final response = await http.get(
        Uri.parse('https://touchtender-web.onrender.com/v1/community/comment/${comment.commentId}/replies'),
      );

      if (response.statusCode == 200) {
        final replies = json.decode(response.body)['replies'];
        setState(() {
          _replies[comment.commentId] = replies;
        });
      } else {
        throw Exception('Failed to load replies');
      }
    }
  }

  Future<void> _logout() async {
    // Remove the user ID and token from secure storage
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'auth_token');

    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      PageTransition(
        child: LoginScreen(), // Replace with your login page
        type: PageTransitionType.fade,
      ),
    );
  }

  void _removeComment(int commentId) {
    setState(() {
      _comments.removeWhere((comment) => comment.commentId == commentId);
      _totalLikes.remove(commentId);
      _replies.remove(commentId);
    });
  }
  Future<void> _loadUserProfile() async {
    String? userId = await storage.read(key: 'user_id');
    if (userId != null) {
      final response = await http.get(Uri.parse('https://touchtender-web.onrender.com/v1/auth/user/$userId'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _fullName = jsonResponse['user']['fullName'];
          _email = jsonResponse['user']['email'];
          _profileImage = jsonResponse['user']['image_url'];
        });
      }
    }
  }


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
                    backgroundImage: NetworkImage(_profileImage), // Changed to NetworkImage to load from URL
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.purple[800],
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        _email,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsPage()),
                          );
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
                        onPressed: _logout, // Call the logout method
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
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return ThreadCard(
                    category: comment.category,
                    content: comment.content,
                    totalLikes: _totalLikes[comment.commentId] ?? 0,
                    commentId: comment.commentId, // Pass the commentId here
                    replies: _replies[comment.commentId] ?? [],
                    removeComment: _removeComment,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddThreadPage()),
          );
        },
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class Comment {
  final int commentId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final String category;

  Comment({
    required this.commentId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.category,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['CommentID'],
      userId: json['UserID'],
      content: json['Content'],
      createdAt: DateTime.parse(json['CreatedAt']),
      category: json['category'],
    );
  }
}

class ThreadCard extends StatefulWidget {
  final String category;
  final String content;
  final int totalLikes;
  final int commentId;
  final List<dynamic> replies;
  final void Function(int commentId) removeComment;

  ThreadCard({
    required this.category,
    required this.content,
    required this.totalLikes,
    required this.commentId,
    required this.replies,
    required this.removeComment,
  });

  @override
  _ThreadCardState createState() => _ThreadCardState();
}

class _ThreadCardState extends State<ThreadCard> {
  bool isLiked = false;
  bool _showAllReplies = false;

  Future<void> _deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse('https://touchtender-web.onrender.com/v1/community/deletecomment/$commentId'),
    );

    if (response.statusCode == 200) {
      print('Comment deleted');
      widget.removeComment(commentId);
    } else {
      print('Failed to delete comment');
    }
  }

  void _navigateToEditThreadPage(BuildContext context, int commentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditThreadPage(commentId: commentId),
      ),
    );
  }

  Widget _interactionButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border_outlined,
          color: Colors.green,
        ),
        onPressed: () {
          // Like/Unlike functionality
        },
      ),
      Text(
        '${widget.totalLikes}',
        style: TextStyle(color: Colors.black),
      ),
      SizedBox(width: 16.0),
      IconButton(
        icon: Icon(Icons.reply, color: Colors.green),
        onPressed: () {
          setState(() {
            _showAllReplies = !_showAllReplies;
          });
        },
      ),
      Text(
        '${widget.replies.length}',
        style: TextStyle(color: Colors.black),
      ),
    ],
  );

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
              widget.category,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.content,
              style: TextStyle(color: Colors.purple[800]),
            ),
            SizedBox(height: 8.0),
            _interactionButtons(),
            if (_showAllReplies) _buildReplies(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteComment(widget.commentId);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    _navigateToEditThreadPage(context, widget.commentId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplies() {
    bool shouldShowViewMore = widget.replies.length > 2 && !_showAllReplies; // Control the "View More" button
    List<Widget> visibleReplies;

    if (_showAllReplies) {
      visibleReplies = widget.replies.map((reply) => _buildReplyItem(reply)).toList();
    } else {
      visibleReplies = widget.replies.take(2).map((reply) => _buildReplyItem(reply)).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 8.0),
          child: Text(
            'Replies:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple, // Customize color to suit app theme
            ),
          ),
        ),
        ...visibleReplies,
        if (shouldShowViewMore)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllReplies = true; // Show all replies
              });
            },
            child: Text('View More'),
          ),
      ],
    );
  }

  Widget _buildReplyItem(dynamic reply) {
    return Padding(
      padding: EdgeInsets.only(left: 40.0, top: 4.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply['Content'],
            style: TextStyle(fontSize: 14.0, color: Colors.black54), // Customize font as needed
          ),
          Text(
            'Posted on ${DateTime.parse(reply['CreatedAt']).toLocal()}',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          // Add more details or interaction buttons here if needed
        ],
      ),
    );
  }
}
