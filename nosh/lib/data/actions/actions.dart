import '../../models/ShoppingItem.dart';
import '../../models/StoredItem.dart';
import 'package:uuid/uuid.dart';

class AddItemAction {
  static String _id;
  final String name;
  final String quantity;
  final DateTime expiry;
  final String imageUri;

  AddItemAction(this.name, this.quantity, this.expiry, this.imageUri) {
    _id = Uuid().v1();
  }

  String get id => _id;
}

class RemoveItemAction {
  final Item item;

  RemoveItemAction(this.item);
}

class UpdateItemAction {
  final Item item;
  UpdateItemAction(this.item);
}

class GetItemsAction {}

class LoadedItemsAction {
  final List<Item> items;

  LoadedItemsAction(this.items);
}
////////////////// SHOPPING ACTIONS /////////////////////

class AddShoppingAction {
  static String _id;
  final String name;
  final String quantity;

  AddShoppingAction(this.name, this.quantity) {
    _id = Uuid().v1();
  }

  String get id => _id;
}

class RemoveShoppingAction {
  final ShoppingItem shopItem;
  RemoveShoppingAction(this.shopItem);
}

class UpdateShoppingItemAction {
  final ShoppingItem shopItem;
  UpdateShoppingItemAction(this.shopItem);
}

class GetShoppingItemsAction {}

class LoadedShoppingItemsAction {
  final List<ShoppingItem> shopItems;

  LoadedShoppingItemsAction(this.shopItems);
}
