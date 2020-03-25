import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'stockItem.dart';

class DBhelper {
  static Database _db;
  static const String DB_NAME = 'nosh.db';
  static const String STOCKTABLE = 'Stock';
  static const String NAME = 'itemName';
  static const String DATE = 'date';
  static const String ID = 'id';

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
    await db.execute("CREATE TABLE $STOCKTABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $NAME TEXT, $DATE TEXT)");
  }

  //Stock db functions
  Future<StockItem> saveToStock(StockItem item) async {
    var dbClient = await db;
    item.ID = await dbClient.insert(STOCKTABLE, item.toMap());
    return item;
  }

  Future<List<StockItem>> getItemsFromStock() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $STOCKTABLE ORDER BY $DATE ASC");
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
    return await dbClient.delete(STOCKTABLE, where: '$NAME = ?', whereArgs: [itemName]);
  }

  Future<int> updateItemFromStock(StockItem item) async {
    var dbClient = await db;
    return await dbClient.update(STOCKTABLE, item.toMap(), 
        where: '$ID = ?', whereArgs: [item.ID]);
  }

  Future closeStockTable() async {
    var dbClient = await db;
    dbClient.close();
  }

}