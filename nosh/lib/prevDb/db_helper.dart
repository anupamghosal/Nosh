import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nosh/models/StoredItem.dart';
import 'package:nosh/models/ShoppingItem.dart';

class DBhelper {
  static Database _db;
  static const String DB_NAME = 'nosh.db';
  //stock table
  static const String STOCKTABLE = 'Stock';
  static const String SNAME = 'stockItemName';
  static const String SDATE = 'stockItemExpiryDate';
  static const String SID = 'stockItemId';
  static const String SIMG = 'stockItemImage';
  static const String SQUANTITY = 'stockItemQuantity';
  //list table
  static const String LISTTABLE = 'List';
  static const String LNAME = 'listItemName';
  static const String LID = 'listItemId';
  static const String LQUANTITY = 'listItemQuantity';
  //expired table
  static const String EXPIREDTABLE = 'Expired';
  static const String ENAME = 'expiredItemName';
  static const String EDATE = 'expiredItemExpiryDate';
  static const String EID = 'expiredItemId';
  static const String EIMG = 'expiredItemImage';
  static const String EQUANTITY = 'expiredItemQuantity';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: onCreate);
    return db;
  }

  onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $STOCKTABLE ($SID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $SNAME TEXT, $SDATE TEXT, $SIMG TEXT, $SQUANTITY TEXT)");
    await db.execute(
        "CREATE TABLE $LISTTABLE ($LID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $LNAME TEXT, $LQUANTITY TEXT)");
    await db.execute(
        "CREATE TABLE $EXPIREDTABLE ($EID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $ENAME TEXT, $EDATE TEXT, $EIMG TEXT, $EQUANTITY)");
  }

  //Stock table functions

  Future<List<Item>> getItemsFromStock() async {
    var dbClient = await db;
    List<Map> maps1 = await dbClient.rawQuery(
        "SELECT * FROM $STOCKTABLE WHERE $SDATE == '' ORDER BY $SID DESC");
    List<Map> maps2 = await dbClient.rawQuery(
        "SELECT * FROM $STOCKTABLE WHERE $SDATE != '' ORDER BY $SDATE ASC");
    List<Map> expiredMap = await dbClient.rawQuery("SELECT * FROM $EXPIREDTABLE");
    List<Map> maps = List.from(maps1)..addAll(maps2);
    List<Item> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(Item.fromPrevStockMap(maps[i]));
      }
    }
    if (expiredMap.length > 0) {
      for (int i = 0; i < expiredMap.length; i++) {
        items.add(Item.fromPrevExpiryMap(maps[i]));
      }
    }
    return items;
  }

  //List table functions

  Future<List<ShoppingItem>> getItemsFromList() async {
    var dbClient = await db;
    List<Map> maps =
        await dbClient.rawQuery("SELECT * FROM $LISTTABLE ORDER BY $LID DESC");
    List<ShoppingItem> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(ShoppingItem.fromPrevMap(maps[i]));
      }
    }
    return items;
  }

  //close db client
  Future dispose() async {
    var dbClient = await db;
    dbClient.close();
  }
}
