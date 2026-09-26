import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techwiz7/Models/expense.dart';
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
      version: 3,   // ✅ 2 → 3 kar do taaki onUpgrade dobara chale
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

        await db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          description TEXT,
          source TEXT NOT NULL,
          userid TEXT NOT NULL,
          status TEXT NOT NULL,
          date TEXT NOT NULL
        )
      ''');   // ✅ 'expenses' (plural) — code ke saath match
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Purani galat table(s) drop karo
        await db.execute('DROP TABLE IF EXISTS expense');
        await db.execute('DROP TABLE IF EXISTS expenses');

        // Fresh 'expenses' table banao
        await db.execute('''
        CREATE TABLE expenses(
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
    } catch (e, st) {
      print('SYNC FAILED for id=$id: $e'); // <-- ye line add karo
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
  Future<int> addexpense(expense expense) async {
    final db = await getDatabase();
    return await db.insert('expenses', expense.toMap());
  }
  Future<List<expense>> getexpense(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'expenses',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return result.map((e) => expense.fromMap(e)).toList();
  }
  Future<List<expense>> getPendingexpense(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'expenses',
      where: 'userid = ? AND status = ?',
      whereArgs: [userId, 'pending'],
    );

    return result.map((e) => expense.fromMap(e)).toList();
  }

  Future<void> deleteexpense(int id) async {
    final db = await getDatabase();

    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> syncexpense(int id) async {
    final db = await getDatabase();

    final result = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return;

    final expense = result.first;

    try {
      await FirebaseDatabase.instance.ref('expense/$id').set({
        'amount': expense['amount'],
        'description': expense['description'],
        'source': expense['source'],
        'userid': expense['userid'],
        'date': expense['date'],
      });

      await db.update(
        'expenses',
        {'status': 'synced'},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, st) {
      print('SYNC FAILED for id=$id: $e'); // <-- ye line add karo
    }
  }

  Future<void> addexpenseAndSync(expense expense) async {
    final id = await addexpense(expense);
    await syncexpense(id);
  }

  Future<void> syncPendingexpense() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final user = await getuserid();
      if (user == null) return;

      final pending = await getPendingexpense(user.userId);

      for (final expense in pending) {
        if (expense.id != null) {
          await syncexpense(expense.id!);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}