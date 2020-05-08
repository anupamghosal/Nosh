import 'package:nosh/data/appState.dart';
import 'package:nosh/data/reducers/shoppingReducer.dart';

import 'itemReducers.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
      items: itemReducer(state.items, action),
      shopItems: shoppingReducer(state.shopItems, action));
}
