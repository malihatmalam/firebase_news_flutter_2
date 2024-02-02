//new_message
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_news_flutter/domain/usecases/chat_usecases.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/services/auth_services.dart';
import 'image_preview_custom.dart';


class NewMessage  extends StatelessWidget {
  NewMessage ({super.key});
  XFile? _imageFile;
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Consumer<AuthService>(
        builder: (context, value, child) {
          return Row(
            children: [
              IconButton(
                onPressed: () async {
                  _imageFile = ChatUseCases().pickImage() as XFile?;
                  Provider.of<AuthService>(context, listen: false).setImageFile(_imageFile);
                },
                icon: Icon(Icons.camera),
                color: Theme.of(context).colorScheme.primary,
              ),
              ImagePreviewCustom(
                imageFile: Provider.of<AuthService>(context, listen: false).getImageFile(),
              ),
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
                onPressed: () {
                  ChatUseCases().submitMessage(
                      context: context,
                      messageController: _messageController,
                      imageFile: Provider.of<AuthService>(context, listen: false).getImageFile()
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
