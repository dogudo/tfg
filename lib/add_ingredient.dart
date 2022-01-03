import 'package:flutter/material.dart';

import 'models/ingredient.dart';

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
        //backgroundColor: Color(0xFF6200EE), maybe use this color
        title: const Text('Añadir ingrediente'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(Ingredient(name: controller.text));
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
