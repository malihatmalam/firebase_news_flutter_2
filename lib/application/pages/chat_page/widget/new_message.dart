//new_message
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  XFile? _imageFile;

  void _pickImage() async {

    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if(pickedImage == null){
      return;
    }

    setState(() {
      _imageFile = pickedImage;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty && _imageFile == null) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();


    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (_imageFile != null) {
      final time = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('$time.jpg');

      // Upload the image to Firebase Storage
      final UploadTask uploadTask = storageRef.putFile(
        File(_imageFile!.path),
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

    setState(() {
      _imageFile = null;
    });

  }

  Widget ImagePreviewCustom(){
    if (_imageFile == null) {
      return SizedBox.shrink();
    }

    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(_imageFile!.path)),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(right: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: _pickImage,
            icon: Icon(Icons.camera),
            color: Theme.of(context).colorScheme.primary,
          ),
          ImagePreviewCustom(),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.send,
            ),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}