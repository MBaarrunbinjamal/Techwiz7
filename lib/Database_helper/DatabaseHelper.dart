import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techwiz7/Models/expense.dart';
import 'package:techwiz7/Models/income.dart';
import 'package:techwiz7/Models/users.dart';
import 'package:techwiz7/Models/TransactionModel.dart';
import 'package:techwiz7/Models/goal.dart';

class DatabaseHelper {
  static Database? database;

  // Single shared instance. GoalService calls DatabaseHelper.instance.
  // The database field above is static, so every instance shares one db.
  static final DatabaseHelper instance = DatabaseHelper();

  bool _isSyncing = false;

  Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }
    database = await openDatabase(
      join(await getDatabasesPath(), 'Pennypal.db'),
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          FirstName TEXT,
          phonenumber TEXT,
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
      ''');

        // Goals table for the Savings Goals feature (SRS FR-32 to FR-40).
        // id is a TEXT primary key because a goal id is a string.
        // userid scopes goals to one account, like income and expenses.
        // synced marks whether the row reached Firebase. 0 means pending.
        await db.execute('''
        CREATE TABLE goals(
          id TEXT PRIMARY KEY,
          title TEXT,
          category TEXT,
          target REAL,
          saved REAL,
          monthly REAL,
          targetDate TEXT,
          userid TEXT,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {

        await db.execute('DROP TABLE IF EXISTS expense');
        await db.execute('DROP TABLE IF EXISTS expenses');


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

        // Create the goals table for apps upgrading from an older version.
        // IF NOT EXISTS keeps this safe if the table is already there.
        await db.execute('''
        CREATE TABLE IF NOT EXISTS goals(
          id TEXT PRIMARY KEY,
          title TEXT,
          category TEXT,
          target REAL,
          saved REAL,
          monthly REAL,
          targetDate TEXT,
          userid TEXT,
          synced INTEGER NOT NULL DEFAULT 0
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
      print('SYNC FAILED for id=$id: $e');
    }
  }

  Future<void> addIncomeAndSync(Income income) async {
    final id = await addincome(income);
    await syncIncome(id);
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
      print('SYNC FAILED for id=$id: $e');
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
  Future<double> getTotalIncome(String userId) async {
    final db = await getDatabase();

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM income WHERE userid = ?',
      [userId],
    );

    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }

  Future<double> getTotalExpense(String userId) async {
    final db = await getDatabase();

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM expenses WHERE userid = ?',
      [userId],
    );

    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }

  Future<double> getMonthlyIncome(String userId) async {
    final db = await getDatabase();

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM income '
          'WHERE userid = ? AND date >= ? AND date < ?',
      [userId, start.toIso8601String(), end.toIso8601String()],
    );

    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final db = await getDatabase();

    final incomeRows = await db.query(
      'income',
      where: 'userid = ?',
      whereArgs: [userId],
    );

    final expenseRows = await db.query(
      'expenses',
      where: 'userid = ?',
      whereArgs: [userId],
    );

    final list = <TransactionModel>[];

    for (final row in incomeRows) {
      list.add(_rowToTransaction(row, 'income'));
    }
    for (final row in expenseRows) {
      list.add(_rowToTransaction(row, 'expense'));
    }

    list.sort((a, b) => b.date.compareTo(a.date));

    return list;
  }



  TransactionModel _rowToTransaction(Map<String, dynamic> row, String type) {
    return TransactionModel(
      id: row['id'] as int?,
      userId: (row['userid'] ?? '') as String,
      type: type,
      amount: (row['amount'] as num).toDouble(),
      description: (row['description'] ?? '') as String,
      source: (row['source'] ?? '') as String,
      status: (row['status'] ?? 'pending') as String,
      date: DateTime.parse(row['date'] as String),
    );
  }

  // ===================== GOALS =====================
  // Local storage for the Savings Goals feature.
  // Every method is scoped by userid, the same way income and expenses are.
  // GoalService calls these, then mirrors the data to Firebase.

  // Save a new goal. goal.toMap() has no userid or synced, so we add both.
  // userid ties the goal to the signed in user.
  // synced starts at 0, meaning it has not reached Firebase yet.
  // replace overwrites a row with the same id instead of throwing.
  Future<int> insertGoal(Goal goal, String userId) async {
    final db = await getDatabase();
    final map = goal.toMap();
    map['userid'] = userId;
    map['synced'] = 0;
    return await db.insert(
      'goals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Load every goal for this user, soonest target date first.
  // Goal.fromMap reads only its own fields and ignores userid and synced.
  Future<List<Goal>> getGoals(String userId) async {
    final db = await getDatabase();
    final rows = await db.query(
      'goals',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'targetDate ASC',
    );
    return rows.map((e) => Goal.fromMap(e)).toList();
  }

  // Update the saved amount after a deposit.
  // synced resets to 0 so the next sync pushes the new total to Firebase.
  Future<void> updateSaved(String id, double saved) async {
    final db = await getDatabase();
    await db.update(
      'goals',
      {'saved': saved, 'synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Remove a goal from local storage. The service removes it from Firebase.
  Future<void> deleteGoal(String id) async {
    final db = await getDatabase();
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // Flag a goal as pushed to Firebase, so syncPending skips it next time.
  Future<void> markGoalSynced(String id) async {
    final db = await getDatabase();
    await db.update(
      'goals',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}