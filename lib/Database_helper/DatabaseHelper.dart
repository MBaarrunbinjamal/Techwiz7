import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techwiz7/Models/expense.dart';
import 'package:techwiz7/Models/income.dart';
import 'package:techwiz7/Models/users.dart';
import 'package:techwiz7/Models/TransactionModel.dart';
import 'package:techwiz7/Models/goal.dart';
import 'package:techwiz7/Models/BudgetModel.dart';

class DatabaseHelper {
  static Database? database;

  static final DatabaseHelper instance = DatabaseHelper();

  bool _isSyncingIncome = false;
  bool _isSyncingExpense = false;
  bool _isSyncingBudgets = false;

  Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }
    database = await openDatabase(
      join(await getDatabasesPath(), 'Pennypal.db'),
      version: 5,
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
          status TEXT NOT NULL DEFAULT 'active',
          milestone INTEGER NOT NULL DEFAULT 0,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');

        await db.execute('''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userid TEXT NOT NULL,
          category TEXT NOT NULL,
          budgetLimit REAL NOT NULL,
          month TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
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
          status TEXT NOT NULL DEFAULT 'active',
          milestone INTEGER NOT NULL DEFAULT 0,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userid TEXT NOT NULL,
          category TEXT NOT NULL,
          budgetLimit REAL NOT NULL,
          month TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      },
    );

    await _ensureGoalColumns(database!);
    return database!;
  }

  Future<void> _ensureGoalColumns(Database db) async {
    try {
      await db.execute(
        "ALTER TABLE goals ADD COLUMN status TEXT NOT NULL DEFAULT 'active'",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE goals ADD COLUMN milestone INTEGER NOT NULL DEFAULT 0",
      );
    } catch (_) {}
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
    await _refreshBudgetsForIncomeOrExpense(income.userid, income.source, income.date);
  }

  Future<void> syncPendingIncomes() async {
    if (_isSyncingIncome) return;
    _isSyncingIncome = true;

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
      _isSyncingIncome = false;
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
    await _refreshBudgetsForIncomeOrExpense(expense.userid, expense.source, expense.date);
  }

  Future<void> syncPendingexpense() async {
    if (_isSyncingExpense) return;
    _isSyncingExpense = true;

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
      _isSyncingExpense = false;
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

  Future<void> updateSaved(String id, double saved) async {
    final db = await getDatabase();
    await db.update(
      'goals',
      {'saved': saved, 'synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateGoalMeta(
      String id, {
        int? milestone,
        String? status,
      }) async {
    final db = await getDatabase();
    final data = <String, dynamic>{'synced': 0};
    if (milestone != null) data['milestone'] = milestone;
    if (status != null) data['status'] = status;
    await db.update('goals', data, where: 'id = ?', whereArgs: [id]);
  }
  Future<void> addSavingsExpense({
    required String userId,
    required double amount,
    required String goalTitle,
    required DateTime date,
  }) async {
    final db = await getDatabase();
    await db.insert('expenses', {
      'amount': amount,
      'description': 'Deposit to $goalTitle',
      'source': 'Savings',
      'userid': userId,
      'status': 'pending',
      'date': date.toIso8601String(),
    });
  }

  Future<void> deleteGoal(String id) async {
    final db = await getDatabase();
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markGoalSynced(String id) async {
    final db = await getDatabase();
    await db.update(
      'goals',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertBudget(BudgetModel budget) async {
    final db = await getDatabase();
    final map = budget.toMap();
    map.remove('id');
    map['synced'] = 0;
    return await db.insert('budgets', map);
  }

  Future<List<BudgetModel>> getBudgets(String userId, {String? month}) async {
    final db = await getDatabase();
    final rows = await db.query(
      'budgets',
      where: month != null ? 'userid = ? AND month = ?' : 'userid = ?',
      whereArgs: month != null ? [userId, month] : [userId],
      orderBy: 'category ASC',
    );
    return rows.map((e) => BudgetModel.fromMap(e)).toList();
  }

  Future<void> updateBudgetLimit(int id, double limit) async {
    final db = await getDatabase();
    await db.update(
      'budgets',
      {'budgetLimit': limit, 'synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteBudget(int id) async {
    final db = await getDatabase();
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getBudgetSpent(String userId, String category, String month) async {
    final db = await getDatabase();
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) AS total FROM expenses
      WHERE userid = ? AND source = ? AND strftime('%Y-%m', date) = ?
      ''',
      [userId, category, month],
    );
    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }

  Future<void> refreshBudgetStatus(int id) async {
    final db = await getDatabase();
    final rows = await db.query('budgets', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;

    final row = rows.first;
    final spent = await getBudgetSpent(
      row['userid'] as String,
      row['category'] as String,
      row['month'] as String,
    );
    final limit = (row['budgetLimit'] as num).toDouble();
    final newStatus = spent >= limit ? 'exceeded' : 'active';

    if (newStatus != row['status']) {
      await db.update(
        'budgets',
        {'status': newStatus, 'synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> _refreshBudgetsForIncomeOrExpense(
      String userId,
      String source,
      DateTime date,
      ) async {
    final db = await getDatabase();
    final month =
        '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final matches = await db.query(
      'budgets',
      where: 'userid = ? AND category = ? AND month = ?',
      whereArgs: [userId, source, month],
    );
    for (final row in matches) {
      await refreshBudgetStatus(row['id'] as int);
    }
  }

  Future<void> syncBudget(int id) async {
    final db = await getDatabase();
    final result = await db.query('budgets', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return;

    final budget = result.first;

    try {
      await FirebaseDatabase.instance.ref('budgets/$id').set({
        'userid': budget['userid'],
        'category': budget['category'],
        'limit': budget['budgetLimit'],
        'month': budget['month'],
        'status': budget['status'],
      });

      await db.update('budgets', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('SYNC FAILED for budget id=$id: $e');
    }
  }

  Future<void> addBudgetAndSync(BudgetModel budget) async {
    final id = await insertBudget(budget);
    await syncBudget(id);
  }

  Future<void> syncPendingBudgets() async {
    if (_isSyncingBudgets) return;
    _isSyncingBudgets = true;

    try {
      final user = await getuserid();
      if (user == null) return;

      final db = await getDatabase();
      final pending = await db.query(
        'budgets',
        where: 'userid = ? AND synced = 0',
        whereArgs: [user.userId],
      );

      for (final row in pending) {
        await syncBudget(row['id'] as int);
      }
    } finally {
      _isSyncingBudgets = false;
    }
  }
}