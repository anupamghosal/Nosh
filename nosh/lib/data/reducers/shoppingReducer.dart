import 'package:nosh/data/actions/actions.dart';
import 'package:nosh/models/ShoppingItem.dart';

List<ShoppingItem> shoppingReducer(List<ShoppingItem> prevState, action) {
  if (action is AddShoppingAction) {
    return []
      ..add(ShoppingItem(
          id: action.id, name: action.name, quantity: action.quantity))
      ..addAll(prevState);
  }
  if (action is RemoveShoppingAction) {
    return List.unmodifiable(List.from(prevState)..remove(action.shopItem));
  }

  if (action is LoadedShoppingItemsAction) {
    return action.shopItems;
  }

  if (action is UpdateShoppingItemAction) {
    return prevState
        .map((item) => item.id == action.shopItem.id ? action.shopItem : item)
        .toList();
  }

  return prevState;
}
