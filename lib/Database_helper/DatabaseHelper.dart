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
}
