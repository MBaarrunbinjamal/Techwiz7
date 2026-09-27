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

  // Single shared instance. GoalService calls DatabaseHelper.instance.
  // The database field above is static, so every instance shares one db.
  static final DatabaseHelper instance = DatabaseHelper();

  // Separate flags per table — a single shared flag meant that calling
  // syncPendingIncomes(), syncPendingexpense() and syncPendingBudgets()
  // around the same time (e.g. all three on app start) let only the first
  // one actually run; the others returned immediately and silently skipped
  // their sync, with nothing printed to explain why.
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

        // Budgets table for the Budget Planner feature.
        // One row per category per month, scoped by userid like everything else.
        // How much has actually been spent is NOT stored here — it's derived
        // live from the expenses table (see getBudgetSpent), so it can never
        // drift out of sync with the real transactions.
        // Column is 'budgetLimit', not 'limit', since LIMIT is a SQL keyword.
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

        // Same for budgets — safe to run on every upgrade.
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

  // ===================== BUDGETS =====================
  // Local storage for the Budget Planner feature.
  // Every method is scoped by userid, like income, expenses and goals.
  //
  // IMPORTANT ASSUMPTION: expenses don't have a dedicated 'category' column
  // in this schema — they use 'source' for that. So a budget's `category`
  // is matched against the expense's `source` field. If expenses get a real
  // category column later, swap 'source' for it in getBudgetSpent below.

  // Insert a new budget for a category+month. synced starts at 0.
  Future<int> insertBudget(BudgetModel budget) async {
    final db = await getDatabase();
    final map = budget.toMap();
    map.remove('id'); // let SQLite assign it
    map['synced'] = 0;
    return await db.insert('budgets', map);
  }

  // All budgets for a user, optionally filtered to one month ('YYYY-MM').
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

  // Change a budget's limit. synced resets to 0 so it re-pushes to Firebase.
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

  // How much has been spent against this category this month — derived
  // live from the expenses table, never stored on the budget row itself.
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

  // Recomputes spend vs limit for one budget and flips its status locally
  // ('active' <-> 'exceeded') when it changed. Marks it unsynced so the
  // new status reaches Firebase on the next sync pass.
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

  // Called after every income/expense insert so budgets stay current
  // without the UI having to remember to refresh them manually.
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