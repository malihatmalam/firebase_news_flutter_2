
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_news_flutter/application/core/services/auth_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthUseCases {
  final _firebase = FirebaseAuth.instance;
  // GlobalKey<FormState>? _form;
  bool? _isLogin;
  bool? _isAuthenticating;
  String? _enteredEmail;
  String? _enteredPassword;
  String? _enteredUsername;

  void submit({
    required GlobalKey<FormState> form,
    required BuildContext context,
    required String enteredEmail,
    required String enteredPassword,
    required String enteredUsername
  }) async {
    try {
      _isLogin = Provider.of<AuthService>(context, listen: false).getIsLogin();
      print("IS_LOGIN_USE_CASE: ${_isLogin}");
      _isAuthenticating = Provider.of<AuthService>(context, listen: false).getIsAuthenticating();


      File? _selectedImage = Provider.of<AuthService>(context, listen: false).getTempAuthImage();

      final isValid = form?.currentState!.validate();

      if (!isValid! || !_isLogin! && _selectedImage == null) {
        // show error message ...
        return;
      }

      form?.currentState!.save();
      Provider.of<AuthService>(context, listen: false).changeIsAuthenticating();
      if (_isLogin!) {
        print("SIGN IN USER ${enteredEmail},${enteredPassword} ");
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail!, password: enteredPassword!
        );
        Provider.of<AuthService>(context, listen: false).setEnteredUsername('');
        Provider.of<AuthService>(context, listen: false).setEnteredPassword('');
        Provider.of<AuthService>(context, listen: false).setEnteredEmail('');
      }
      else {
        print("CREATE USER");
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail!, password: enteredPassword!
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredUsername,
          'email': enteredEmail,
          'image_url': imageUrl,
        });

        Provider.of<AuthService>(context, listen: false).setEnteredUsername('');
        Provider.of<AuthService>(context, listen: false).setEnteredPassword('');
        Provider.of<AuthService>(context, listen: false).setEnteredEmail('');
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // ...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
    }
  }



}