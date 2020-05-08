import 'package:nosh/models/ShoppingItem.dart';

import '../models/StoredItem.dart';

class AppState {
  final List<Item> items;
  final List<ShoppingItem> shopItems;

  AppState({this.items, this.shopItems});

  AppState.fromJson(Map json)
      : items = (json['items'] as List).map((i) => Item.fromJson(i)).toList(),
        shopItems = (json['shopItems'] as List)
            .map((i) => ShoppingItem.fromJson(i))
            .toList();

  Map toJson() => {'items': items, 'shopItems': shopItems};

  AppState.initialState()
      : items = List.unmodifiable(<Item>[]),
        shopItems = List.unmodifiable(<ShoppingItem>[]);
}
