import 'package:flutter/material.dart';
import 'package:tender_touch/HomePage/homepage.dart';

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
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];

  void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add(Message(text, true)); // User message
        // Simulate chatbot response
        messages.add(Message("Here's a response to \"$text\"", false));
        _controller.clear();
      });
    }
  }

  Widget messageTile(Message message) {
    bool isMe = message.isMe;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            backgroundImage: AssetImage('images/menubuttons/chatbot.png'), // Chatbot profile picture
            radius: 20,
          ),
          SizedBox(width: 10),
        ],
        Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
        if (isMe) ...[
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: AssetImage('images/home_images/profile.jpg'), // User profile picture
            radius: 20,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300], // Match the header's color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(), // Navigate to the HomeScreen
              ),
            );
          },
        ),
        title: Text("Chat with us!", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => messageTile(messages[index]),
            ),
          ),
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
                  onPressed: _sendMessage,
                ),
              ],
            ),
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
