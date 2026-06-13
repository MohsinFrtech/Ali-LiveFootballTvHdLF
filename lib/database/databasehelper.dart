import 'database.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static AppDatabase? _database;

  DatabaseHelper._internal();

  Future<AppDatabase> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<AppDatabase> _initDatabase() async {
    return await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }
}