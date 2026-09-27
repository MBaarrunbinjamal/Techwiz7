import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techwiz7/Models/expense.dart';
import 'package:techwiz7/Models/income.dart';
import 'package:techwiz7/Models/users.dart';
import 'package:techwiz7/Models/TransactionModel.dart';
import 'package:techwiz7/Services/PrefsService.dart';

class DatabaseHelper {
  static Database? database;

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
        ''');

        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebaseId TEXT,
            userid TEXT NOT NULL,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            description TEXT,
            source TEXT NOT NULL,
            status TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS transactions(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              firebaseId TEXT,
              userid TEXT NOT NULL,
              type TEXT NOT NULL,
              amount REAL NOT NULL,
              description TEXT,
              source TEXT NOT NULL,
              status TEXT NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        }
      },
    );

    return database!;
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  Future<String?> getCurrentUserId() async {
    return await PrefsService.instance.getUserId();
  }

  // ============================================================
  // USERS
  // ============================================================

  Future<void> insertUser(Users userData) async {
    final db = await getDatabase();

    await db.insert(
      'users',
      userData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Users?> Loginuser(String Email, String Password) async {
    final db = await getDatabase();

    final user = await db.query(
      'users',
      where: 'Email = ?',
      whereArgs: [Email],
      limit: 1,
    );

    if (user.isNotEmpty) {
      return Users.fromMap(user.first);
    }

    return null;
  }

  Future<Users?> getuserid() async {
    final db = await getDatabase();

    final user = await db.query(
      'users',
      limit: 1,
    );

    if (user.isEmpty) return null;

    return Users.fromMap(user.first);
  }

  // ============================================================
  // INCOME
  // ============================================================

  Future<int> addincome(Income income) async {
    final db = await getDatabase();

    return await db.insert(
      'income',
      income.toMap(),
    );
  }

  Future<List<Income>> getIncomes(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'income',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result.map((e) => Income.fromMap(e)).toList();
  }

  Future<List<Income>> getPendingIncomes(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'income',
      where: 'userid = ? AND status = ?',
      whereArgs: [userId, 'pending'],
      orderBy: 'date ASC',
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

    await db.delete(
      'transactions',
      where: 'type = ? AND id = ?',
      whereArgs: ['income', id],
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
      final firebaseRef =
      FirebaseDatabase.instance.ref('income').push();

      await firebaseRef.set({
        'amount': income['amount'],
        'description': income['description'],
        'source': income['source'],
        'userid': income['userid'],
        'date': income['date'],
      });

      await db.update(
        'income',
        {
          'status': 'synced',
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      final transaction = await db.query(
        'transactions',
        where: 'type = ? AND source = ? AND userid = ? AND date = ?',
        whereArgs: [
          'income',
          income['source'],
          income['userid'],
          income['date'],
        ],
        limit: 1,
      );

      if (transaction.isNotEmpty) {
        await db.update(
          'transactions',
          {
            'firebaseId': firebaseRef.key,
            'status': 'synced',
          },
          where: 'id = ?',
          whereArgs: [transaction.first['id']],
        );
      }

      print('INCOME SYNCED: $id');
    } catch (e) {
      print('INCOME SYNC FAILED: $e');
    }
  }

  Future<void> addIncomeAndSync(Income income) async {
    final id = await addincome(income);

    await addTransaction(
      TransactionModel(
        userId: income.userid,
        type: 'income',
        amount: income.amount,
        description: income.description,
        source: income.source,
        status: 'pending',
        date: income.date,
      ),
    );

    await syncIncome(id);

    await syncPendingTransactions();
  }

  Future<void> syncPendingIncomes() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final userId = await getCurrentUserId();

      if (userId == null || userId.isEmpty) return;

      final pending = await getPendingIncomes(userId);

      for (final income in pending) {
        if (income.id != null) {
          await syncIncome(income.id!);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  // ============================================================
  // EXPENSE
  // ============================================================

  Future<int> addexpense(expense expenseData) async {
    final db = await getDatabase();

    return await db.insert(
      'expenses',
      expenseData.toMap(),
    );
  }

  Future<List<expense>> getexpense(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'expenses',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result.map((e) => expense.fromMap(e)).toList();
  }

  Future<List<expense>> getPendingexpense(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'expenses',
      where: 'userid = ? AND status = ?',
      whereArgs: [userId, 'pending'],
      orderBy: 'date ASC',
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

    final expenseData = result.first;

    try {
      final firebaseRef =
      FirebaseDatabase.instance.ref('expense').push();

      await firebaseRef.set({
        'amount': expenseData['amount'],
        'description': expenseData['description'],
        'source': expenseData['source'],
        'userid': expenseData['userid'],
        'date': expenseData['date'],
      });

      await db.update(
        'expenses',
        {
          'status': 'synced',
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      final transaction = await db.query(
        'transactions',
        where: 'type = ? AND source = ? AND userid = ? AND date = ?',
        whereArgs: [
          'expense',
          expenseData['source'],
          expenseData['userid'],
          expenseData['date'],
        ],
        limit: 1,
      );

      if (transaction.isNotEmpty) {
        await db.update(
          'transactions',
          {
            'firebaseId': firebaseRef.key,
            'status': 'synced',
          },
          where: 'id = ?',
          whereArgs: [transaction.first['id']],
        );
      }

      print('EXPENSE SYNCED: $id');
    } catch (e) {
      print('EXPENSE SYNC FAILED: $e');
    }
  }

  Future<void> addexpenseAndSync(expense expenseData) async {
    final id = await addexpense(expenseData);

    await addTransaction(
      TransactionModel(
        userId: expenseData.userid,
        type: 'expense',
        amount: expenseData.amount,
        description: expenseData.description,
        source: expenseData.source,
        status: 'pending',
        date: expenseData.date,
      ),
    );

    await syncexpense(id);

    await syncPendingTransactions();
  }

  Future<void> syncPendingexpense() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final userId = await getCurrentUserId();

      if (userId == null || userId.isEmpty) return;

      final pending = await getPendingexpense(userId);

      for (final expenseData in pending) {
        if (expenseData.id != null) {
          await syncexpense(expenseData.id!);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await getDatabase();

    return await db.insert(
      'transactions',
      transaction.toMap(),
    );
  }

  Future<List<TransactionModel>> getTransactions(
      String userId,
      ) async {
    final db = await getDatabase();

    final result = await db.query(
      'transactions',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result
        .map((e) => TransactionModel.fromMap(e))
        .toList();
  }

  Future<List<TransactionModel>> getPendingTransactions(
      String userId,
      ) async {
    final db = await getDatabase();

    final result = await db.query(
      'transactions',
      where: 'userid = ? AND status = ?',
      whereArgs: [userId, 'pending'],
      orderBy: 'date ASC',
    );

    return result
        .map((e) => TransactionModel.fromMap(e))
        .toList();
  }

  Future<void> syncTransaction(int id) async {
    final db = await getDatabase();

    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return;

    final transaction = TransactionModel.fromMap(result.first);

    try {
      final firebaseRef =
      FirebaseDatabase.instance.ref('transactions').push();

      await firebaseRef.set({
        'userid': transaction.userId,
        'type': transaction.type,
        'amount': transaction.amount,
        'description': transaction.description,
        'source': transaction.source,
        'date': transaction.date.toIso8601String(),
      });

      await db.update(
        'transactions',
        {
          'firebaseId': firebaseRef.key,
          'status': 'synced',
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      print('TRANSACTION SYNCED: $id');
    } catch (e) {
      print('TRANSACTION SYNC FAILED: $e');
    }
  }

  Future<void> syncPendingTransactions() async {
    final userId = await getCurrentUserId();

    if (userId == null || userId.isEmpty) {
      return;
    }

    final pending = await getPendingTransactions(userId);

    for (final transaction in pending) {
      if (transaction.id != null) {
        await syncTransaction(transaction.id!);
      }
    }
  }

  Future<void> deleteTransaction(int id) async {
    final db = await getDatabase();

    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  Future<double> getTotalIncome(String userId) async {
    final db = await getDatabase();

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM income
      WHERE userid = ?
      ''',
      [userId],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthlyIncome(String userId) async {
    final db = await getDatabase();

    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      1,
    );

    final end = DateTime(
      now.year,
      now.month + 1,
      1,
    );

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM income
      WHERE userid = ?
      AND date >= ?
      AND date < ?
      ''',
      [
        userId,
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense(String userId) async {
    final db = await getDatabase();

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM expenses
      WHERE userid = ?
      ''',
      [userId],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthlyExpense(String userId) async {
    final db = await getDatabase();

    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      1,
    );

    final end = DateTime(
      now.year,
      now.month + 1,
      1,
    );

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM expenses
      WHERE userid = ?
      AND date >= ?
      AND date < ?
      ''',
      [
        userId,
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getBalance(String userId) async {
    final income = await getTotalIncome(userId);
    final expense = await getTotalExpense(userId);

    return income - expense;
  }

  // ============================================================
  // DEBUG
  // ============================================================

  Future<void> debugAllIncomeAndExpenses() async {
    final db = await getDatabase();

    final incomes = await db.query('income');
    final expenses = await db.query('expenses');
    final transactions = await db.query('transactions');

    print('======================================');
    print('ALL SQLITE INCOME RECORDS');
    print('======================================');

    for (final income in incomes) {
      print(income);
    }

    print('======================================');
    print('ALL SQLITE EXPENSE RECORDS');
    print('======================================');

    for (final expense in expenses) {
      print(expense);
    }

    print('======================================');
    print('ALL SQLITE TRANSACTION RECORDS');
    print('======================================');

    for (final transaction in transactions) {
      print(transaction);
    }

    print('======================================');
  }

}