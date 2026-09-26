import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techwiz7/Models/users.dart';

class DatabaseHelper {
  static Database? database;

  Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }
    database = await openDatabase(
      join(await getDatabasesPath(), "Pennypal.db"),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
            '''
       CREATE TABLE users(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       FirstName TEXT,
       LastName TEXT,
       Email Text,
       Password Text,
       userid Text
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
}
