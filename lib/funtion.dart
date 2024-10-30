import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;

import 'package:sql/model.dart';

const String databaseName = 'notes.db';
const int versionNumber = 1;
const String tableNotes = 'notes';
const String colName = 'name';
const String colAddress = 'address';
const String colPhone = 'phone';


class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = path.join(documentsDirectory.path, databaseName);

    return await openDatabase(
      dbPath,
      version: versionNumber,
      onCreate: _onCreate,
    );
  }

  // Create table when the database is created
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS $tableNotes (
        ${colName} TEXT NOT NULL,
        ${colAddress} TEXT,
        ${colPhone} INTEGER
      )
      ''',
    );
  }

  // Insert a new note into the database
  Future<void> insert(NoteModel note) async {
    final db = await database;
    await db.insert(
      tableNotes,
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all notes from the database
  Future<List<NoteModel>> getAll() async {
    final db = await database;
    final result = await db.query(tableNotes);
    return result.map((json) => NoteModel.fromJson(json)).toList();
  }

  // Define a function to update a note
  Future<int> update(NoteModel note) async {
    final db = await database;

    // Update the given Note.
    var res = await db.update(tableNotes, note.toJson(),
        // Since we removed ID, this method will now be used only for inserting.
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  // Define a function to delete a note
  Future<void> delete(String name) async {
    final db = await database;
    try {
      // Remove the Note from the database.
      await db.delete(tableNotes,
          // Use a `where` clause to delete a specific Note.
          where: "$colName = ?",
          // Pass the Note's name as a whereArg.
          whereArgs: [name]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}