import 'package:chronius/model/chronius.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:chronius/constants.dart';

class DbHelper{
  // Singleton creation...
  static final DbHelper _dbHelper = new DbHelper._internal();

  // Private constuctor for singleton creation...
  DbHelper._internal();

  // Factory for returning singleton...
  factory DbHelper() {
    return _dbHelper;
  }

  String _columnId = Constants.COLUMN_ID;
  String _columnName = Constants.COLUMN_NAME;
  String _columnDescription = Constants.COLUMN_DESCRIPTION;
  String _columnIsActive = Constants.COLUMN_ISACTIVE;
  String _columnTargetDate = Constants.COLUMN_TARGET_DATE;
  String _columnStartDate = Constants.COLUMN_STARTING_DATE;

  // Other variables / constants...
  static Database _db;

  // Table names...
  static const String CHRONI_TABLE = "chroni";

  Future<Database> get database async {
    if(_db == null){
      _db = await initializeDb();
    }

    return _db;
  }

  Future<Database> initializeDb() async {
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path + "lunarianstudios.edenbridge.db";
    var db = await openDatabase(path, version: 1, onCreate: createDb);
    return db;
  }

  void createDb(Database db, int version) async {
    await db.execute(
      "CREATE TABLE $CHRONI_TABLE($_columnId INTEGER PRIMARY KEY, " +
      "$_columnName TEXT, $_columnDescription TEXT, $_columnTargetDate TEXT, $_columnStartDate TEXT, $_columnIsActive INTEGER"
    );
  }

  Future<int> insertChronius(Chronius chronius) async {
    var db = await this.database;
    var result = await db.insert(CHRONI_TABLE, chronius.toMap());
    return result;
  }

  Future<int> updateChronius(Chronius chronius) async {
    var db = await this.database;
    var result = await db.update(CHRONI_TABLE, chronius.toMap(), 
      where: "$_columnId = ?", 
      whereArgs: [chronius.id]);

    return result;
  }

  Future<List> getAllChroni() async {
    var db = await this.database;
    var result = await db.rawQuery("SELECT * FROM $CHRONI_TABLE ORDER BY $_columnId");
    return result;
  }

  Future<List> findChroni(String searchTerm) async {
    var db = await this.database;
    var result = await db.rawQuery("SELECT * FROM $CHRONI_TABLE WHERE $_columnName LIKE '%$searchTerm%' ORDER BY $_columnId");
    return result;
  }
}