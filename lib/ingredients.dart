import 'package:flutter/material.dart';
import 'package:mugunghwa/db/ingredient_database.dart';
import 'package:mugunghwa/model/ingredient.dart';

import 'add_ingredient.dart';
/*
class AllergensScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      // Column is also a layout widget. It takes a list of children and
      // arranges them vertically. By default, it sizes itself to fit its
      // children horizontally, and tries to be as tall as its parent.
      //
      // Invoke "debug painting" (press "p" in the console, choose the
      // "Toggle Debug Paint" action from the Flutter Inspector in Android
      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
      // to see the wireframe for each widget.
      //
      // Column has various properties to control how it sizes itself and
      // how it positions its children. Here we use mainAxisAlignment to
      // center the children vertically; the main axis here is the vertical
      // axis because Columns are vertical (the cross axis would be
      // horizontal).
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'WEPA',
        ),
        Text(
          'You have pushed the button this many times:',
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}
*/

class _IngredientsScreenState extends State<IngredientsScreen> {
  List<Ingredient> ingredients = <Ingredient>[];
  bool isLoading = false;
  final _saved = <Ingredient>{};

  @override
  void initState() {
    super.initState();
    refreshIngredients();
  }

  @override
  void dispose() {
    //IngredientDatabase.instance.close();
    super.dispose();
  }

  Future refreshIngredients() async {
    setState(() => isLoading = true);
    ingredients = await IngredientDatabase.instance.readAllScan();
    setState(() => isLoading = false);
  }

  Widget _buildIngredients() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: ingredients.length,
        itemBuilder: (context, i) {
          final item = ingredients[i];

          return _buildRow(item);
        });
  }

  Widget _buildRow(Ingredient ingredient) {
    final alreadySaved = _saved.contains(ingredient);
    return ListTile(
      title: Text(
        ingredient.nameEng,
      ),
      subtitle: Text(
        ingredient.nameKor,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Saved Ingredients',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ingredients.isEmpty
              ? const Center(child: Text('Empty'))
              : _buildIngredients(),
      floatingActionButton: FloatingActionButton(
        // CHECK AND FIX THIS CODE, NULL CHECKS MISSING
        onPressed: () async {
          Ingredient? ing = await Navigator.push(
            context,
            MaterialPageRoute<Ingredient>(
              builder: (BuildContext context) => const AddIngredientScreen(),
              fullscreenDialog: true,
            ),
          );
          IngredientDatabase.instance.create(ing!);
          refreshIngredients();
        },
        tooltip: 'Text',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (ingredient) {
              return ListTile(
                title: Text(
                  ingredient.nameEng,
                ),
                subtitle: Text(
                  ingredient.nameKor,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Ingredients'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({Key? key}) : super(key: key);

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}
