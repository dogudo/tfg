import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'custom_bottom_sheet.dart' as bs;
import 'db/ingredient_database.dart';
import 'model/ingredient.dart';

import 'package:http/http.dart' as http;

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

// A widget that displays the picture taken by the user.
class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<Ingredient> found = <Ingredient>[];
  bool isLoading = false;
  final _saved = <Ingredient>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    refreshFound();
  }

  @override
  void dispose() {
    //IngredientDatabase.instance.close();
    super.dispose();
  }

  Future refreshFound() async {
    setState(() => isLoading = true);
    found = await IngredientDatabase.instance.readAllScan();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(children: [
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Spacer(flex: 1),
          Expanded(
              flex: 8,
              child: GestureDetector(
                  child: Hero(
                      tag: 'imageHero',
                      child: Image.file(
                        File(widget.imagePath),
                        width: 125,
                        fit: BoxFit.cover,
                      )),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Scaffold(
                        backgroundColor: Colors.black,
                        body: GestureDetector(
                          child: Center(
                            child: Hero(
                              tag: 'imageHero',
                              child: Image.file(File(widget.imagePath)),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }));
                  })),
          const Spacer(flex: 1),
          Expanded(
              flex: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Scan #1", style: Theme.of(context).textTheme.headline5),
                  Text("Aquí va la fecha",
                      style: Theme.of(context).textTheme.subtitle1),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.lightGreen,
                    child: Text(
                      "\n✅ No se ha encontrado nada peligroso\n",
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )),
          const Spacer(flex: 1),
        ]),
        const SizedBox(height: 16),
        Expanded(child: _buildFound())
      ]),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          Future<List<String>> text = processImage(widget.imagePath);
          bs.showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            context: context,
            builder: (context) => FutureBuilder<List<String>>(
                future: text,
                builder: (context, snapshot) {
                  snapshot.hasData ? matcher(snapshot.data![0]) : ""; // debug
                  return SafeArea(
                      child: snapshot.hasData
                          ? SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(snapshot.data![0],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2),
                                      Text('🇰🇷 Korean - Original',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption),
                                      Text('\n' + snapshot.data![1],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2),
                                      Text('🇬🇧 English - Translation',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption),
                                    ]),
                              ),
                            )
                          : const Center(
                              heightFactor: 2.0,
                              child: CircularProgressIndicator()));
                }),
          );
        },
        child: const Icon(Icons.translate),
        tooltip: 'Translate text',
      ),
    );
  }

  Widget _buildFound() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: found.length,
        itemBuilder: (context, i) {
          final item = found[i];

          return _buildRow(item);
        });
  }

  Widget _buildRow(Ingredient ingredient) {
    final alreadySaved = _saved.contains(ingredient);
    return ListTile(
      title: Text(
        ingredient.nameEng,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(ingredient);
          } else {
            _saved.add(ingredient);
          }
        });
      },
    );
  }

  Future<List<String>> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final textDetector = GoogleMlKit.vision.textDetectorV2();
    final recognisedText = await textDetector.processImage(inputImage,
        script: TextRecognitionOptions.KOREAN);

    final translateLanguageModelManager =
        GoogleMlKit.nlp.translateLanguageModelManager();
    try {
      await translateLanguageModelManager.downloadModel('en');
      await translateLanguageModelManager.downloadModel('ko');
    } catch (e) {
      print(e.toString());
    }

    final onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
        sourceLanguage: TranslateLanguage.KOREAN,
        targetLanguage: TranslateLanguage.ENGLISH);

    var translatedText = await getTranslationPapago(recognisedText.text);
    translatedText ??=
        await onDeviceTranslator.translateText(recognisedText.text);

    textDetector.close();
    onDeviceTranslator.close();

    return [recognisedText.text, translatedText];
  }

  Future<List<Ingredient>> matcher(String rawtext) async {
    List<Ingredient> ingredients =
        await IngredientDatabase.instance.readAllScan();
    List<Ingredient> matches = <Ingredient>[];
    for (final ingredient in ingredients) {
      print(ingredient.nameKor);
      List<String> checks = ingredient.nameKor.split(', ');
      for (final check in checks) {
        print("PART: " + check);
        if (rawtext.contains(check)) {
          matches.add(ingredient);
        }
      }
    }
    for (final match in matches) {
      print("FOUND: " + match.nameEng + match.nameKor);
    }
    print("done");
    return matches;
  }
}

Future<String?> getTranslationPapago(String text) async {
  String clientId = "lKdraqwfxdXrVcxhgXkh";
  String clientSecret = "7sfeYSECYh";
  String contentType = "application/x-www-form-urlencoded; charset=UTF-8";
  String _url = "https://openapi.naver.com/v1/papago/n2mt";

  http.Response trans = await http.post(
    Uri.parse(_url),
    headers: {
      'Content-Type': contentType,
      'X-Naver-Client-Id': clientId,
      'X-Naver-Client-Secret': clientSecret
    },
    body: {
      'source': "ko",
      'target': "en",
      'text': text,
    },
  );
  if (trans.statusCode == 200) {
    var dataJson = jsonDecode(trans.body);
    var resultPapago = dataJson['message']['result']['translatedText'];
    return resultPapago;
  }
}
