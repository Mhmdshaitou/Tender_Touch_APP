import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:tender_touch/Community/addthread.dart';
import 'package:tender_touch/Profile/profile_page.dart';
import '../HomePage/forcelogin.dart';

class CommunityPage extends StatefulWidget {
  static const String routeName = '/community';

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> comments = [];
  Map<int, int> _totalLikes = {};
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await storage.read(key: 'auth_token');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: ForceloginPage(destinationRoute: CommunityPage.routeName),
          type: PageTransitionType.fade,
        ),
      );
    } else {
      fetchComments();
    }
  }

  Future<void> fetchComments() async {
    final response = await http.get(
      Uri.parse('http://localhost:7000/v1/community/comments'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        comments = data['comments'];
      });
      _fetchTotalLikes(comments);
    } else {
      print('Failed to fetch comments');
    }
  }

  Future<void> _fetchTotalLikes(List<dynamic> comments) async {
    for (var comment in comments) {
      final response = await http.get(
        Uri.parse('http://localhost:7000/v1/community/totallikes/${comment['CommentID']}'),
      );

      if (response.statusCode == 200) {
        final totalLikes = json.decode(response.body)['totalLikes'];
        setState(() {
          _totalLikes[comment['CommentID']] = totalLikes;
        });
      } else {
        throw Exception('Failed to load total likes');
      }
    }
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
          ThreadsTab(comments: comments, totalLikes: _totalLikes),
          ForumsTab(comments: comments),
        ],
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

class ThreadsTab extends StatelessWidget {
  final List<dynamic> comments;
  final Map<int, int> totalLikes;

  ThreadsTab({required this.comments, required this.totalLikes});

  @override
  Widget build(BuildContext context) {
    return CommentsListWidget(comments: comments, totalLikes: totalLikes);
  }
}

class CommentsListWidget extends StatelessWidget {
  final List<dynamic> comments;
  final Map<int, int> totalLikes;

  CommentsListWidget({required this.comments, required this.totalLikes});

  @override
  Widget build(BuildContext context) {
    final sortedComments = List<dynamic>.from(comments)
      ..sort((a, b) => b['CreatedAt'].compareTo(a['CreatedAt']));

    return ListView.builder(
      itemCount: sortedComments.length,
      itemBuilder: (context, index) {
        final comment = sortedComments[index];
        return CommentCard(
          commentId: comment['CommentID'],
          userId: comment['UserID'],
          content: comment['Content'],
          createdAt: comment['CreatedAt'],
          category: comment['category'],
          totalLikes: totalLikes[comment['CommentID']] ?? 0,
        );
      },
    );
  }
}

class CommentCard extends StatefulWidget {
  final int commentId;
  final int userId;
  final String content;
  final String createdAt;
  final String category;
  final int totalLikes;

  CommentCard({
    required this.commentId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.category,
    required this.totalLikes,
  });

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isLiked = false;
  int likeCount = 0;
  final storage = FlutterSecureStorage();
  List<dynamic> _replies = [];
  bool isLoadingReplies = false;
  String? errorMessage;
  bool _showAllReplies = false;

  @override
  void initState() {
    super.initState();
    likeCount = widget.totalLikes;
    _fetchReplies();
    _checkIfLiked();
  }

  Future<void> _fetchReplies() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:7000/v1/community/comment/${widget.commentId}/replies'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _replies = data['replies'];
          });
        }
      } else {
        throw Exception('Failed to fetch replies: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _checkIfLiked() async {
    String? userId = await storage.read(key: 'user_id');
    if (userId != null) {
      final response = await http.get(
        Uri.parse('http://localhost:7000/v1/community/isliked/${widget.commentId}/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isLiked = data['isLiked'];
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    String? userId = await storage.read(key: 'user_id');
    if (userId == null) {
      print('User ID is not available');
      return;
    }

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    String url = isLiked
        ? 'http://localhost:7000/v1/community/addlike/${widget.commentId}'
        : 'http://localhost:7000/v1/community/unlike/${widget.commentId}';

    try {
      final response = isLiked
          ? await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userID': userId}),
      )
          : await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userID': userId}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
        print('Failed to toggle like: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
      print('Error sending request: $e');
    }
  }

  void _showReplyDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ReplyDialog(
        commentId: widget.commentId,
        userId: widget.userId,
      ),
    );

    _fetchReplies();
  }

  String getTimeSinceCreated(String createdAt) {
    final createdDateTime = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(createdDateTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour(s) ago';
    } else {
      return '${difference.inMinutes} minute(s) ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeSinceCreated = getTimeSinceCreated(widget.createdAt);

    return Card(
      color: Colors.blue[100],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              timeSinceCreated,
              style: TextStyle(color: Colors.blue[900]),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.content,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16.0),
            if (isLoadingReplies)
              CircularProgressIndicator(),
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            if (!isLoadingReplies && _replies.isNotEmpty)
              _buildReplies(),
            SizedBox(height: 16.0),
            _interactionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _interactionButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.green,
        ),
        onPressed: _toggleLike,
      ),
      Text(
        '$likeCount',
        style: TextStyle(color: Colors.black),
      ),
      SizedBox(width: 16.0),
      IconButton(
        icon: Icon(Icons.reply, color: Colors.green),
        onPressed: _showReplyDialog,
      ),
      Text(
        '${_replies.length}',
        style: TextStyle(color: Colors.black),
      ),
    ],
  );

  Widget _buildReplies() {
    bool shouldShowViewMore = _replies.length > 2 && !_showAllReplies;
    List<Widget> visibleReplies;

    if (_showAllReplies) {
      visibleReplies = _replies.map((reply) => _buildReplyItem(reply)).toList();
    } else {
      visibleReplies = _replies.take(2).map((reply) => _buildReplyItem(reply)).toList();
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

class ReplyDialog extends StatefulWidget {
  final int commentId;
  final int userId;
  ReplyDialog({required this.commentId, required this.userId});
  @override
  _ReplyDialogState createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  final _replyController = TextEditingController();
  final storage = FlutterSecureStorage();

  Future<void> _addReply() async {
    String? userIdString = await storage.read(key: 'user_id');
    if (userIdString == null) {
      print('User ID is not available');
      return;
    }

    int? userId = int.tryParse(userIdString);
    if (userId == null) {
      print('User ID is invalid');
      return;
    }

    if (_replyController.text.isEmpty) {
      print('Reply content is empty');
      return;
    }

    Map<String, dynamic> requestBody = {
      'commentID': widget.commentId,
      'userID': userId,
      'content': _replyController.text,
    };

    try {
      Navigator.of(context).pop();
      final response = await http.post(
        Uri.parse('http://localhost:7000/v1/community/addreply/${widget.commentId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print('Failed to add reply: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Reply'),
      content: TextField(
        controller: _replyController,
        decoration: InputDecoration(
          hintText: 'Enter your reply',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addReply,
          child: Text('Add Reply'),
        ),
      ],
    );
  }
}

class ForumsTab extends StatefulWidget {
  final List<dynamic> comments;
  ForumsTab({required this.comments});
  @override
  _ForumsTabState createState() => _ForumsTabState();
}

class _ForumsTabState extends State<ForumsTab> {
  String? _selectedCategory;
  List<dynamic> _filteredComments = [];
  @override
  void initState() {
    super.initState();
    _filteredComments = widget.comments;
  }

  void _filterComments(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _filteredComments = widget.comments;
      } else {
        _filteredComments = widget.comments
            .where((comment) => comment['category'] == category)
            .toList();
      }
    });
  }

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
                    label: Text('All', style: TextStyle(color: Colors.white)),
                    backgroundColor: _selectedCategory == null ? Colors.blue[800] : Colors.grey[400],
                    onSelected: (selected) => _filterComments(null),
                  ),
                  FilterChip(
                    label: Text('Autism', style: TextStyle(color: Colors.white)),
                    backgroundColor: _selectedCategory == 'Autism' ? Colors.blue[800] : Colors.grey[400],
                    onSelected: (selected) => _filterComments('Autism'),
                  ),
                  FilterChip(
                    label: Text('ADHD', style: TextStyle(color: Colors.white)),
                    backgroundColor: _selectedCategory == 'ADHD' ? Colors.blue[800] : Colors.grey[400],
                    onSelected: (selected) => _filterComments('ADHD'),
                  ),
                  FilterChip(
                    label: Text('Cerebral Palsy', style: TextStyle(color: Colors.white)),
                    backgroundColor: _selectedCategory == 'Cerebral Palsy' ? Colors.blue[800] : Colors.grey[400],
                    onSelected: (selected) => _filterComments('Cerebral Palsy'),
                  ),
                  FilterChip(
                    label: Text('Locomotor Disability', style: TextStyle(color: Colors.white)),
                    backgroundColor: _selectedCategory == 'Locomotor Disability' ? Colors.blue[800] : Colors.grey[400],
                    onSelected: (selected) => _filterComments('Locomotor Disability'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredComments.length,
            itemBuilder: (context, index) {
              final comment = _filteredComments[index];
              return CommentCard(
                commentId: comment['CommentID'],
                userId: comment['UserID'],
                content: comment['Content'],
                createdAt: comment['CreatedAt'],
                category: comment['category'],
                totalLikes: 0,
              );
            },
          ),
        ),
      ],
    );
  }
}
