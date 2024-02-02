import 'package:firebase_core/firebase_core.dart';

class FirebaseDatasouce{

  Future<void> startFirebase() async {
    await Firebase.initializeApp();
  }
}