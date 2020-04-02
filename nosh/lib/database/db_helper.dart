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
  //list table
  static const String LISTTABLE = 'List';
  static const String LNAME = 'listItemName';
  static const String LID = 'listItemId';
  //expired table
  static const String EXPIREDTABLE = 'Expired';
  static const String ENAME = 'expiredItemName';
  static const String EDATE = 'expiredItemExpiryDate';
  static const String EID = 'expiredItemId';
  static const String EIMG = 'expiredItemImage';

  Future<Database> get db async {
    if(_db != null) {
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
    await db.execute("CREATE TABLE $STOCKTABLE ($SID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $SNAME TEXT, $SDATE TEXT, $SIMG TEXT)");
    await db.execute("CREATE TABLE $LISTTABLE ($LID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $LNAME TEXT)");
    await db.execute("CREATE TABLE $EXPIREDTABLE ($EID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $ENAME TEXT, $EDATE TEXT, $EIMG TEXT)");

  }

  //Stock db functions
  Future<StockItem> saveToStock(StockItem item) async {
    var dbClient = await db;
    int id = await dbClient.insert(STOCKTABLE, item.toMap());
    item.setId(id);
    return item;
  }

  Future<List<StockItem>> getItemsFromStock() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $STOCKTABLE ORDER BY $SDATE ASC");
    List<StockItem> items  = [];
    if(maps.length > 0) {
      for(int i = 0; i < maps.length; i++) {
        items.add(StockItem.fromMap(maps[i]));
      }
    }
    return items;
  }

  Future<int> deleteItemFromStock(String itemName) async {
    var dbClient = await db;
    return await dbClient.delete(STOCKTABLE, where: '$SNAME = ?', whereArgs: [itemName]);
  }

  Future<int> updateItemFromStock(StockItem item) async {
    var dbClient = await db;
    return await dbClient.update(STOCKTABLE, item.toMap(), 
        where: '$SID = ?', whereArgs: [item.getId()]);
  }

  //List db functions
  Future<ListItem> saveToList(ListItem item) async {
    var dbClient = await db;
    int id = await dbClient.insert(LISTTABLE, item.toMap());
    item.setId(id);
    return item;
  }

  Future<List<ListItem>> getItemsFromList() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $LISTTABLE");
    List<ListItem> items  = [];
    if(maps.length > 0) {
      for(int i = 0; i < maps.length; i++) {
        items.add(ListItem.fromMap(maps[i]));
      }
    }
    return items;
  }

  Future<int> deleteItemFromList(String itemName) async {
    var dbClient = await db;
    return await dbClient.delete(LISTTABLE, where: '$LNAME = ?', whereArgs: [itemName]);
  }

  Future<int> updateItemFromList(ListItem item) async {
    var dbClient = await db;
    return await dbClient.update(LISTTABLE, item.toMap(), 
        where: '$LID = ?', whereArgs: [item.getId()]);
  }

  //Expired db functions
  Future<ExpiredItem> saveExpiredItem(ExpiredItem item) async {
    var dbClient = await db;
    int id = await dbClient.insert(EXPIREDTABLE, item.toMap());
    item.setId(id);
    return item;
  }

  Future<List<ExpiredItem>> getExpiredItems() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $EXPIREDTABLE");
    List<ExpiredItem> items  = [];
    if(maps.length > 0) {
      for(int i = 0; i < maps.length; i++) {
        items.add(ExpiredItem.fromMap(maps[i]));
      }
    }
    return items;
  }

  Future<int> deleteExpiredItem(String itemName) async {
    var dbClient = await db;
    return await dbClient.delete(EXPIREDTABLE, where: '$ENAME = ?', whereArgs: [itemName]);
  }

  //close db client
  Future dispose() async {
    var dbClient = await db;
    dbClient.close();
  }

}