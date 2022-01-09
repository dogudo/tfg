import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mugunghwa/model/category.dart';
import 'package:mugunghwa/model/ingredient.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class IngredientDatabase {
  static final IngredientDatabase instance = IngredientDatabase._init();

  static Database? _database;

  IngredientDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('ingredient.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "ingredient.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    return await openDatabase(path, readOnly: true);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $tableCategory (
        ${CategoryFields.id} $idType,
        ${CategoryFields.name} $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableIngredient (
        ${IngredientFields.id} $idType,
        ${IngredientFields.nameEng} $textType,
        ${IngredientFields.nameKor} $textType,
        ${IngredientFields.categoryId} $integerType,
        ${IngredientFields.scan} $boolType,
        FOREIGN KEY(${IngredientFields.categoryId}) REFERENCES $tableCategory(${CategoryFields.id})
      )
    ''');
  }

  Future<Ingredient> create(Ingredient ingredient) async {
    final db = await instance.database;

    final id = await db.insert(tableIngredient, ingredient.toJson());
    return ingredient.copy(id: id);
  }

  Future<Ingredient> read(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableIngredient,
      columns: IngredientFields.values,
      where: '${IngredientFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Ingredient.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found'); //or return null (nullable func)
    }
  }

  Future<List<Ingredient>> readAll() async {
    final db = await instance.database;
    final result = await db.query(tableIngredient); //orderBy?

    return result.map((json) => Ingredient.fromJson(json)).toList();
  }

  Future<int> update(Ingredient ingredient) async {
    final db = await instance.database;

    return db.update(
      tableIngredient,
      ingredient.toJson(),
      where: '${IngredientFields.id} = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableIngredient,
      where: '${IngredientFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
