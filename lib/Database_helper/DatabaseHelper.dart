import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techwiz7/Models/income.dart';
import 'package:techwiz7/Models/users.dart';

class DatabaseHelper {
  static Database? database;

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
  Future<Users?> Loginuser(String Email , String Password) async {
    final db = await getDatabase();
    final user = await db.query(
      'users',
      where: 'Email = ? AND Password = ?',
      whereArgs: [Email, Password],
      limit: 1,
    );
    if(user != null && user.isNotEmpty){
      return Users.fromMap(user.first);
    }
    return null;
  }
  Future<Users> getuserid()async{
    final db = await getDatabase();

    final user = await db.query(
      'users',
      limit: 1,
    );
    return Users.fromMap(user.first);
  }
  Future<void> addincome(Income income) async{
    final db = await getDatabase();
    await db.insert('income', income.toMap());
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

  Future<void> deleteIncome(int id) async {
    final db = await getDatabase();

    await db.delete(
      'income',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
