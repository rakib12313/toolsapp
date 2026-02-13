import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  
  SharedPreferences? _prefs;
  Database? _database;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initDatabase();
  }
  
  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'toolbox_pro.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE history (
            id TEXT PRIMARY KEY,
            tool_name TEXT NOT NULL,
            tool_icon TEXT NOT NULL,
            input_file TEXT NOT NULL,
            output_file TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            input_size INTEGER,
            output_size INTEGER,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }
  
  SharedPreferences? get prefs => _prefs;
  Database? get database => _database;
}