
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_news_flutter/application/core/services/auth_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<UserCredential> signInWithGoogle() async {
    // Create a new GoogleSignIn instance
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if user data already exists in Firestore
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userData.exists) {
      // If the user data does not exist, create a new document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': userCredential.user!.displayName,
        'email': userCredential.user!.email,
        'image_url': userCredential.user!.photoURL,
      });
    }

    return userCredential;
  }

  Future<void> signOutApplication() async{
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}