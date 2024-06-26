import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tender_touch/HomePage/homepage.dart';
import 'package:tender_touch/Profile/setting.dart';
import 'package:tender_touch/login/Screens/Login/login_screen.dart';
import 'dart:async';
import '../Community/addthread.dart';
import '../HomePage/forcelogin.dart';
import 'editpage.dart';

class UserProfilePage extends StatefulWidget {
  static const String routeName = '/userProfile';

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
  String _profileImage = 'https://touchtender-web.onrender.com/images/home_images/male_avatar.jpg'; // Default URL
  final String imageUrlBase = 'https://touchtender-web.onrender.com'; // Base URL for images
  StreamController<int> _likesStreamController = StreamController<int>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _setupPageReload();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await storage.read(key: 'auth_token');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: ForceloginPage(destinationRoute: UserProfilePage.routeName),
          type: PageTransitionType.fade,
        ),
      );
    } else {
      _loadUserProfile();
      _fetchComments().then((comments) {
        setState(() {
          _comments = comments;
          _fetchCommentLikes(comments);
          _fetchAllReplies(comments);
        });
      });
    }
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

  Future<void> _fetchCommentLikes(List<Comment> comments) async {
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
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'auth_token');

    Navigator.pushReplacement(
      context,
      PageTransition(
        child: HomePage(),
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
          _profileImage = '$imageUrlBase${jsonResponse['user']['image_url']}';
        });
        _fetchTotalUserLikes(userId);
      } else {
        print('Failed to load user profile');
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

  Future<void> _fetchTotalUserLikes(String userId) async {
    final response = await http.get(
      Uri.parse('https://touchtender-web.onrender.com/v1/community/totaluserlikes/$userId'),
    );

    if (response.statusCode == 200) {
      final totalLikes = json.decode(response.body)['totalLikes'];
      _likesStreamController.add(totalLikes);
    } else {
      print('Failed to load total user likes');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _setupPageReload() {
    Timer.periodic(Duration(seconds: 5), (_) async {
      await _checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _likesStreamController.close();
    super.dispose();
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
                    backgroundImage: NetworkImage(_profileImage),
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Error loading profile image: $exception');
                      setState(() {
                        _profileImage = 'https://touchtender-web.onrender.com/images/home_images/male_avatar.jpg'; // Fallback URL
                      });
                    },
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
                          StreamBuilder<int>(
                            stream: _likesStreamController.stream,
                            initialData: 0,
                            builder: (context, snapshot) {
                              return Text(
                                '${snapshot.data} Likes',
                                style: TextStyle(color: Colors.purple[800]),
                              );
                            },
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
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[800],
                            foregroundColor: Colors.white),
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
              _comments.isEmpty
                  ? Text(
                'No comments yet!',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return ThreadCard(
                    category: comment.category,
                    content: comment.content,
                    totalLikes: _totalLikes[comment.commentId] ?? 0,
                    commentId: comment.commentId,
                    createdAt: comment.createdAt,
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
  final DateTime createdAt;
  final List<dynamic> replies;
  final void Function(int commentId) removeComment;

  ThreadCard({
    required this.category,
    required this.content,
    required this.totalLikes,
    required this.commentId,
    required this.createdAt,
    required this.replies,
    required this.removeComment,
  });

  @override
  _ThreadCardState createState() => _ThreadCardState();
}

class _ThreadCardState extends State<ThreadCard> {
  bool isLiked = false;
  bool _showAllReplies = false;

  Future<void> _confirmDeleteComment(int commentId) async {
    bool confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      _deleteComment(commentId);
    }
  }

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

  bool _isEditButtonEnabled(DateTime createdAt) {
    final now = DateTime.now();
    return now.difference(createdAt).inHours < 24;
  }

  void _showEditDisabledMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('24 hours have passed, you cannot edit this comment anymore.'),
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
    final isEditEnabled = _isEditButtonEnabled(widget.createdAt);

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
                    _confirmDeleteComment(widget.commentId);
                  },
                ),
                GestureDetector(
                  onTap: isEditEnabled
                      ? () {
                    _navigateToEditThreadPage(context, widget.commentId);
                  }
                      : _showEditDisabledMessage,
                  child: Icon(
                    Icons.edit,
                    color: isEditEnabled ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplies() {
    bool shouldShowViewMore = widget.replies.length > 2 && !_showAllReplies;
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
              color: Colors.deepPurple,
            ),
          ),
        ),
        ...visibleReplies,
        if (shouldShowViewMore)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllReplies = true;
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
            style: TextStyle(fontSize: 14.0, color: Colors.black54),
          ),
          Text(
            'Posted on ${DateTime.parse(reply['CreatedAt']).toLocal()}',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}