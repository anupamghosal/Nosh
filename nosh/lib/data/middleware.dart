import 'dart:async';
import 'dart:convert';

import 'package:nosh/data/appState.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nosh/models/StoredItem.dart';
import 'package:nosh/models/ShoppingItem.dart';

import 'actions/actions.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:nosh/prevDb/db_helper.dart';

void saveToPrefs(AppState state) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var string = json.encode(state.toJson());
  await preferences.setString('noshState', string);
}

Future<AppState> loadFromPrefs() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var string = preferences.getString('noshState');
  if (string != null) {
    Map map = json.decode(string);
    return AppState.fromJson(map);
  } else {
    DBhelper dBhelper = DBhelper();
    List<Item> storedItems = await dBhelper.getItemsFromStock();
    List<ShoppingItem> shoppingItems = await dBhelper.getItemsFromList();
    if ((storedItems == null || storedItems.length == 0) &&
        (shoppingItems == null || shoppingItems.length == 0)) {
      return AppState.initialState();
    } else {
      AppState appState =
          AppState(items: storedItems, shopItems: shoppingItems);
      saveToPrefs(appState);
      return appState;
    }
  }
}

Future<String> saveCachedImage(String cache) async {
  if (cache.startsWith("https")) return cache;
  Directory directory = await getApplicationDocumentsDirectory();
  String path = directory.path;
  String fileName = cache.substring(cache.lastIndexOf('/') + 1);
  var saved = await File(cache).copy('$path/' + fileName);
  return saved.path;
}

void appStateMiddleware(
    Store<AppState> store, action, NextDispatcher next) async {
  next(action);

  if (action is AddItemAction) {
    if (action.imageUri != '') {
      Item addedItem = store.state.items[0];
      String savedImagePath = await saveCachedImage(addedItem.imageUri);
      addedItem.imageUri = savedImagePath;
    }
    saveToPrefs(store.state);
  }

  if (action is UpdateItemAction) {
    if (action.item.imageUri != '') {
      Item updatedItem;
      for (Item item in store.state.items) {
        if (item.id == action.item.id) {
          updatedItem = item;
          break;
        }
      }
      String savedImagePath = await saveCachedImage(updatedItem.imageUri);
      updatedItem.imageUri = savedImagePath;
    }
    saveToPrefs(store.state);
  }

  if (action is RemoveItemAction ||
      action is AddShoppingAction ||
      action is RemoveShoppingAction ||
      action is UpdateShoppingItemAction) {
    saveToPrefs(store.state);
  }

  if (action is GetItemsAction) {
    await loadFromPrefs()
        .then((state) => store.dispatch(LoadedItemsAction(state.items)));
  }

  if (action is GetShoppingItemsAction) {
    await loadFromPrefs().then(
        (state) => store.dispatch(LoadedShoppingItemsAction(state.shopItems)));
  }
}
