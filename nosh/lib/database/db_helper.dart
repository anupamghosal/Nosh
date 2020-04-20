import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'stockItem.dart';
import 'listItem.dart';
import 'expiredItem.dart';

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
  //temp expired item table
  static const String TEMPEXPIREDTABLE = 'TempExpired';
  static const String TENAME = 'expiredItemName';
  static const String TEDATE = 'expiredItemExpiryDate';
  static const String TEID = 'expiredItemId';
  static const String TEIMG = 'expiredItemImage';
  static const String TEQUANTITY = 'expiredItemQuantity';
  bool _dbExists = false;

  Future<bool> dbExists() async {
    await db;
    return _dbExists;
  }

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
    await db.execute(
        "CREATE TABLE $TEMPEXPIREDTABLE ($TEID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $TENAME TEXT, $TEDATE TEXT, $TEIMG TEXT, $TEQUANTITY)");
    _dbExists = true;
  }

  //Stock table functions
  Future<StockItem> saveToStock(StockItem item) async {
    var dbClient = await db;
    int id = await dbClient.insert(STOCKTABLE, item.toMap());
    item.setId(id);
    return item;
  }

  Future<List<StockItem>> getItemsFromStock() async {
    var dbClient = await db;
    List<Map> maps1 = await dbClient.rawQuery(
        "SELECT * FROM $STOCKTABLE WHERE $SDATE == '' ORDER BY $SID DESC");
    List<Map> maps2 = await dbClient.rawQuery(
        "SELECT * FROM $STOCKTABLE WHERE $SDATE != '' ORDER BY $SDATE ASC");
    List<Map> maps = List.from(maps1)..addAll(maps2);
    List<StockItem> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(StockItem.fromMap(maps[i]));
      }
    }
    return items;
  }

  Future<int> deleteItemFromStock(int itemID) async {
    var dbClient = await db;
    return await dbClient
        .delete(STOCKTABLE, where: '$SID = ?', whereArgs: [itemID]);
  }

  Future<int> updateItemFromStock(StockItem item) async {
    var dbClient = await db;
    return await dbClient.update(STOCKTABLE, item.toMap(),
        where: '$SID = ?', whereArgs: [item.getId()]);
  }

  //List table functions
  Future<ListItem> saveToList(ListItem item) async {
    var dbClient = await db;
    int id = await dbClient.insert(LISTTABLE, item.toMap());
    item.setId(id);
    return item;
  }

  Future<List<ListItem>> getItemsFromList() async {
    var dbClient = await db;
    List<Map> maps =
        await dbClient.rawQuery("SELECT * FROM $LISTTABLE ORDER BY $LID DESC");
    List<ListItem> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(ListItem.fromMap(maps[i]));
      }
    }
    return items;
  }

  Future<int> deleteItemFromList(int itemID) async {
    var dbClient = await db;
    return await dbClient
        .delete(LISTTABLE, where: '$LID = ?', whereArgs: [itemID]);
  }

  Future<int> updateItemFromList(ListItem item) async {
    var dbClient = await db;
    return await dbClient.update(LISTTABLE, item.toMap(),
        where: '$LID = ?', whereArgs: [item.getId()]);
  }

  //Expired table functions
  Future<ExpiredItem> saveExpiredItem(ExpiredItem item) async {
    var dbClient = await db;
    int id = await dbClient.insert(EXPIREDTABLE, item.toMap());
    item.setId(id);
    return item;
  }

  Future<List<ExpiredItem>> getExpiredItems() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $EXPIREDTABLE");
    List<ExpiredItem> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(ExpiredItem.fromMap(maps[i]));
      }
    }
    return items;
  }

  Future<int> deleteExpiredItem(int itemID) async {
    var dbClient = await db;
    return await dbClient
        .delete(EXPIREDTABLE, where: '$EID = ?', whereArgs: [itemID]);
  }

  //Temp Expired table functions
  Future<ExpiredItem> saveTempExpiredItem(ExpiredItem item) async {
    var dbClient = await db;
    int id = await dbClient.insert(TEMPEXPIREDTABLE, item.toMap());
    item.setId(id);
    return item;
  }

  Future<List<ExpiredItem>> getTempExpiredItems() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TEMPEXPIREDTABLE");
    List<ExpiredItem> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(ExpiredItem.fromMap(maps[i]));
      }
    }
    return items;
  }

  Future<int> deleteTempExpiredItem(int itemID) async {
    var dbClient = await db;
    return await dbClient
        .delete(TEMPEXPIREDTABLE, where: '$EID = ?', whereArgs: [itemID]);
  }

  //close db client
  Future dispose() async {
    var dbClient = await db;
    dbClient.close();
  }
}
