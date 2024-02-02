//chat.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_news_flutter/widget/new_message2.dart';
import 'package:flutter/material.dart';

import '../widget/chat_message2.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
        actions: [
          Container(
            margin: EdgeInsets.all(3),
            child: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.logout)
            ),
          )
        ],
      ),
      body: const Column(
        children: const [
          Expanded(
              child: ChatMessages(),
          ),
          NewMessage()
        ],
      )
    );
  }
}