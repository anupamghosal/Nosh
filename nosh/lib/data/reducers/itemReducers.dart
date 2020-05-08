import 'package:nosh/data/actions/actions.dart';
import 'package:nosh/models/StoredItem.dart';

List<Item> itemReducer(List<Item> prevState, action) {
  if (action is AddItemAction) {
    return []
      ..add(Item(
          id: action.id,
          name: action.name,
          quantity: action.quantity,
          expiry: action.expiry,
          imageUri: action.imageUri))
      ..addAll(prevState);
  }
  if (action is RemoveItemAction) {
    return List.unmodifiable(List.from(prevState)..remove(action.item));
  }

  if (action is LoadedItemsAction) {
    return action.items;
  }

  if (action is UpdateItemAction) {
    return prevState
        .map((item) => item.id == action.item.id ? action.item : item)
        .toList();
  }

  return prevState;
}
