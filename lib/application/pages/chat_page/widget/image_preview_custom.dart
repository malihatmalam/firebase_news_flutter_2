

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewCustom extends StatelessWidget {
  XFile? imageFile;

  ImagePreviewCustom({XFile? this.imageFile,  super.key});

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return SizedBox.shrink();
    }
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(imageFile!.path)),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(right: 8),
    );
  }
}
