

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../application/core/services/auth_services.dart';

class ChatUseCases {

  void submitMessage({
    required BuildContext context,
    TextEditingController? messageController,
    imageFile,
  }) async {
    final enteredMessage = messageController?.text;

    if (enteredMessage!.trim().isEmpty && imageFile == null) {
      return;
    }

    FocusScope.of(context).unfocus();
    messageController?.clear();


    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (imageFile != null) {
      final time = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('$time.jpg');

      // Upload the image to Firebase Storage
      final UploadTask uploadTask = storageRef.putFile(
        File(imageFile!.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for the upload to complete and get the download URL
      await uploadTask.whenComplete(() {});

      final imageUrl = await storageRef.getDownloadURL();

      // Store the message in Firestore with the image URL
      FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
        'imageUrl': imageUrl,
      });
    } else {
      // If no image, store the message without imageUrl
      FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
        'imageUrl': null,
      });
    }
    Provider.of<AuthService>(context, listen: false).setImageFile(null);
  }

  Future<XFile?> pickImage() async {

    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if(pickedImage == null){
      return null;
    }
    return pickedImage;
  }

}