import 'package:flutter/material.dart';
import 'model/ingredient.dart';

class AddIngredientScreenState extends State<AddIngredientScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir ingrediente'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(Ingredient(
                  nameEng: controller.text,
                  categoryId: 1,
                  nameKor: '',
                  scan: true));
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.translate),
            title: TextField(
              decoration: const InputDecoration(
                hintText: 'Optional note',
              ),
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddIngredientScreenState();
}
