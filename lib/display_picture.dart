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
          Future<String> text = processImage(imagePath);
          showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            context: context,
            builder: (context) => FutureBuilder<String>(
                future: text,
                builder: (context, snapshot) {
                  return SafeArea(
                    child: snapshot.hasData
                        ? Text(snapshot.data!)
                        : const Center(
                            heightFactor: 2.0,
                            child: CircularProgressIndicator()),
                  );
                }),
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

  final translateLanguageModelManager =
      GoogleMlKit.nlp.translateLanguageModelManager();
  try {
    var result = await translateLanguageModelManager.downloadModel('en');
    print('Model downloaded [EN]: $result');
    var other = await translateLanguageModelManager.downloadModel('ko');
    print('Model downloaded: [KO]: $other');
    print(await translateLanguageModelManager.getAvailableModels());
  } catch (e) {
    print(e.toString());
  }
  final onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
      sourceLanguage: TranslateLanguage.KOREAN,
      targetLanguage: TranslateLanguage.ENGLISH);
  final translatedText =
      await onDeviceTranslator.translateText(recognisedText.text);

  textDetector.close();
  onDeviceTranslator.close();

  return recognisedText.text + "\n----------\n" + translatedText;
}
