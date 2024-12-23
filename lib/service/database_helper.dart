import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'library.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Members (
      Member_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Name TEXT,
      Address TEXT,
      Phone TEXT,
      Email TEXT UNIQUE,
      Password TEXT,
      Registration_Date DATE,
      Role TEXT
    )
    ''');

    await db.execute('''
      CREATE TABLE Books (
        Book_ID INTEGER PRIMARY KEY,
        Title TEXT,
        Author TEXT,
        Publisher TEXT,
        Year INTEGER,
        Genre TEXT,
        Availability_Status INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE Transactions (
        Transaction_ID INTEGER PRIMARY KEY,
        Member_ID INTEGER,
        Book_ID INTEGER,
        Issue_Date DATE,
        Return_Date DATE,
        FOREIGN KEY (Member_ID) REFERENCES Members(Member_ID),
        FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
      )
    ''');
  }

  // CRUD operations for Members
  Future<int> insertMember(Map<String, dynamic> member) async {
    final db = await database;
    return await db.insert('Members', member);
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    final db = await database;
    return await db.query('Members');
  }

  Future<int> updateMember(int id, Map<String, dynamic> member) async {
    final db = await database;
    return await db.update(
      'Members',
      member,
      where: 'Member_ID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete(
      'Members',
      where: 'Member_ID = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Books
  Future<int> insertBook(Map<String, dynamic> book) async {
    final db = await database;
    return await db.insert('Books', book);
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await database;
    return await db.query('Books');
  }

  Future<int> updateBook(int id, Map<String, dynamic> book) async {
    final db = await database;
    return await db.update(
      'Books',
      book,
      where: 'Book_ID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(
      'Books',
      where: 'Book_ID = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Transactions
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('Transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('Transactions');
  }

  Future<int> updateTransaction(
      int id, Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.update(
      'Transactions',
      transaction,
      where: 'Transaction_ID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'Transactions',
      where: 'Transaction_ID = ?',
      whereArgs: [id],
    );
  }
}
