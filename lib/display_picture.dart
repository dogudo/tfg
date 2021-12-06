import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Display the Picture'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          final text = await processImage(imagePath);
          showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            context: context,
            builder: (context) {
              // Using Wrap makes the bottom sheet height the height of the content.
              // Otherwise, the height will be half the height of the screen.
              return Wrap(children: [
                Text(text),
              ]);
            },
          );
        },
        child: const Icon(Icons.visibility),
      ),
    );
  }
}

Future<String> processImage(String imagePath) async {
  final inputImage = InputImage.fromFilePath(imagePath);
  final textDetector = GoogleMlKit.vision.textDetectorV2();
  final recognisedText = await textDetector.processImage(inputImage,
      script: TextRecognitionOptions.KOREAN);

  return recognisedText.text;
}
