//chat.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_news_flutter/application/pages/chat_page/widget/chat_message.dart';
import 'package:firebase_news_flutter/domain/usecases/auth_usecases.dart';
import 'package:firebase_news_flutter/widget/new_message2.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';



class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

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
                    await AuthUseCases().signOutApplication();
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