import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techwiz7/Models/income.dart';
import 'package:techwiz7/Models/users.dart';

class DatabaseHelper {
  static Database? database;

  bool _isSyncing = false;

  Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }
    database = await openDatabase(
      join(await getDatabasesPath(), 'Pennypal.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            FirstName TEXT,
            LastName TEXT,
            Email TEXT,
            Password TEXT,
            userId TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE income(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            description TEXT,
            source TEXT NOT NULL,
            userid TEXT NOT NULL,
            status TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );

    return database!;
  }

  Future<void> insertUser(Users userData) async {
    final db = await getDatabase();
    await db.insert('users', userData.toMap());
  }

  Future<Users?> Loginuser(String Email, String Password) async {
    final db = await getDatabase();
    final user = await db.query(
      'users',
      where: 'Email = ? AND Password = ?',
      whereArgs: [Email, Password],
      limit: 1,
    );
    if (user.isNotEmpty) {
      return Users.fromMap(user.first);
    }
    return null;
  }

  Future<Users?> getuserid() async {
    final db = await getDatabase();
    final user = await db.query('users', limit: 1);

    if (user.isEmpty) return null;
    return Users.fromMap(user.first);
  }

  // Ab id return karta hai — sync ke liye zaroori hai
  Future<int> addincome(Income income) async {
    final db = await getDatabase();
    return await db.insert('income', income.toMap());
  }

  Future<List<Income>> getIncomes(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'income',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return result.map((e) => Income.fromMap(e)).toList();
  }

  // Naya method — sirf pending wali income laata hai
  Future<List<Income>> getPendingIncomes(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'income',
      where: 'userid = ? AND status = ?',
      whereArgs: [userId, 'pending'],
    );

    return result.map((e) => Income.fromMap(e)).toList();
  }

  Future<void> deleteIncome(int id) async {
    final db = await getDatabase();

    await db.delete(
      'income',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> syncIncome(int id) async {
    final db = await getDatabase();

    final result = await db.query(
      'income',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return;

    final income = result.first;

    try {
      await FirebaseDatabase.instance.ref('income/$id').set({
        'amount': income['amount'],
        'description': income['description'],
        'source': income['source'],
        'userid': income['userid'],
        'date': income['date'],
      });

      await db.update(
        'income',
        {'status': 'synced'},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // Firebase fail hua, status 'pending' hi rahega
    }
  }

  Future<void> addIncomeAndSync(Income income) async {
    final id = await addincome(income); // STEP 1: local SQLite save
    await syncIncome(id);                // STEP 2: Firebase sync try
  }

  Future<void> syncPendingIncomes() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final user = await getuserid();
      if (user == null) return;

      final pending = await getPendingIncomes(user.userId);

      for (final income in pending) {
        if (income.id != null) {
          await syncIncome(income.id!);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}