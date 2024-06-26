import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tender_touch/HomePage/homepage.dart';
import '../HomePage/forcelogin.dart';

void main() => runApp(ChatBotPage());

class ChatBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chatbot';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  bool _isLoading = false;
  final storage = FlutterSecureStorage();

  List<String> suggestions = [
    "Hello!",
    "How can I improve my child's communication skills?",
    "How can I take care of myself while caring for my child?",
    "What activities can help with social skills?"
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await storage.read(key: 'auth_token');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: ForceloginPage(destinationRoute: ChatScreen.routeName),
          type: PageTransitionType.fade,
        ),
      );
    }
  }

  void _sendMessage({String? text}) async {
    text = text ?? _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add(Message(text!, true)); // User message
        _isLoading = true;  // Set loading to true
      });
      _controller.clear();

      try {
        // Send POST request to the server
        final response = await http.post(
          Uri.parse('https://touchtender-web.onrender.com/v1/community/chat'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'userInput': text}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            messages.add(Message(responseData['response'], false)); // Chatbot response
          });
        } else {
          print('Request failed with status: ${response.statusCode}.');
          print('Response body: ${response.body}');
          setState(() {
            messages.add(Message('Error: ${json.decode(response.body)['error']}', false));
          });
        }
      } catch (e) {
        print('An error occurred: $e');
        setState(() {
          messages.add(Message('Sorry, an error occurred. Please try again.', false));
        });
      }

      setState(() {
        _isLoading = false;  // Set loading to false
      });
    }
  }

  Widget messageTile(Message message) {
    bool isMe = message.isMe;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: AssetImage('images/menubuttons/chatbot.png'), // Chatbot profile picture
              radius: 20,
            ),
            SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                  color: isMe ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isMe ? Colors.blue[700]! : Colors.grey[500]!)
              ),
              child: Text(
                message.text,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: AssetImage('images/home_images/male_avatar.jpg'), // User profile picture
              radius: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('images/menubuttons/chatbot.png'), // Chatbot profile picture
          radius: 20,
        ),
        SizedBox(width: 10),
        Text('Chatbot is typing...', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _suggestionsBox() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(text: suggestions[index]),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Center(
                child: Text(
                  suggestions[index],
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyChatBackground() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/menubuttons/chatbot.png', // Replace with your background image path
            width: 200,
            height: 200,
          ),
          SizedBox(height: 20),
          Text(
            'Welcome to our chat service!',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Navigate to HomePage
            );
          },
        ),
        title: Text("Professional Chatbot", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (messages.isEmpty) _emptyChatBackground(),
          Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == messages.length) {
                      return _typingIndicator();
                    } else {
                      return messageTile(messages[index]);
                    }
                  },
                ),
              ),
              _suggestionsBox(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Send a message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _isLoading ? null : () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Message {
  String text;
  bool isMe;
  Message(this.text, this.isMe);
}
