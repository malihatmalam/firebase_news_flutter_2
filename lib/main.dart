//main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_news_flutter/application/pages/auth_page/auth_page.dart';
import 'package:firebase_news_flutter/data/datasources/firebase_datasource.dart';
import 'package:firebase_news_flutter/screens/auth.dart';
import 'package:firebase_news_flutter/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'application/core/services/auth_services.dart';
import 'application/pages/chat_page/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FirebaseDatasouce().startFirebase();
  await Firebase.initializeApp();
  runApp(
      ChangeNotifierProvider(
          create: (context) => AuthService(),
          child: const App(),
      ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FlutterChat',
        theme: ThemeData().copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 63, 17, 177)),
        ),
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return const ChatPage();
            }
            return AuthPage();
          },
        )
    );
  }
}