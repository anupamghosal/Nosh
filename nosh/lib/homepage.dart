/*
 @CONTAINS
 APPBAR,
 BOTTOM_NAV,
 FLOATING_ACTION_BUTTON,
 PAGE_CONTROL {NOT ACTUAL PAGES}
*/

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:nosh/data/actions/actions.dart';
import 'package:nosh/models/ShoppingItem.dart';
import 'package:nosh/pages/analytics.dart';
import 'package:nosh/pages/onBoarding.dart';
import 'package:nosh/utils/slide.dart';
import 'package:nosh/widgets/inputModal.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:nosh/widgets/speedDial.dart';
import 'package:url_launcher/url_launcher.dart';

import './pages/stock.dart';
import './pages/expired.dart';
import './pages/shoppinglist.dart';
import 'config/globalScaffold.dart';
import 'data/appState.dart';
import 'models/StoredItem.dart';
import 'package:redux/redux.dart';

class HomePage extends StatefulWidget {
  final Store<AppState> store;
  final bool isFirstBoot;
  HomePage(this.store, this.isFirstBoot);
  @override
  _HomePageState createState() => _HomePageState(store);
}

class _HomePageState extends State<HomePage> {
  final Store<AppState> store;
  _HomePageState(this.store);
  int _navindex = 0;

  PageController pageController =
      PageController(initialPage: 0, keepPage: true);

  var expiredItems;
  var stockItems;

  setItems(_ViewModel vm) {
    expiredItems = vm.items.where((a) => ifExpired(a.expiry)).toList();
    stockItems = vm.items.where((a) => !ifExpired(a.expiry)).toList();
  }

  Widget buildAppBar() {
    return AppBar(
      actions: <Widget>[],
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5.0), //8 if using 'n' logo
            child: Image(
              width: 55, //30 if using 'n' logo
              image: AssetImage('assets/nosh.png'),
            ),
          ),
        ],
      ),
    );
  }

  buildDrawerMenu(final items) {
    return ListView(children: <Widget>[
      DrawerHeader(
        child: null,
      ),
      Align(alignment: Alignment.topLeft, child: PageHeading('Menu')),
      SizedBox(height: 15),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Divider(
          color: Colors.grey,
        ),
      ),
      SizedBox(height: 25),
      ListTile(
        leading: Icon(Icons.equalizer),
        title: Text('Weekly analytics'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, Slide(page: Analysis(stockItems, expiredItems)));
        },
      ),
      ListTile(
          leading: Icon(Icons.help),
          title: Text('Help'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => OnBoardingPage(null, false)));
          }),
      ListTile(
        leading: Icon(Icons.book),
        title: Text('Privacy policy'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () => launch("https://nosh.tech/privacy-policy.html"),
      ),
      ListTile(
        leading: Icon(Icons.supervised_user_circle),
        title: Text('About us'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () => launch("https://nosh.tech/index.html#about.html"),
      ),
    ]);
  }

  Widget buildPageView(final _ViewModel vm) {
    return PageView(
      controller: pageController,
      onPageChanged: (idx) => setState(() {
        _navindex = idx;
      }),
      children: <Widget>[
        Stock(stockItems, vm, widget.isFirstBoot),
        Shopping(vm.shopItems, vm),
        Expired(expiredItems, vm.onRemoveItem)
      ],
    );
  }

  bool ifExpired(DateTime date) {
    if (date == null) return false;
    return (date.day - DateTime.now().day) < 0 &&
        (date.month - DateTime.now().month) == 0 &&
        (date.year - DateTime.now().year) == 0;
  }

  Widget buildFloatingAction(final _ViewModel vm) {
    return Container(
      child: _navindex == 1
          ? Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  String modalName;
                  if (_navindex != 2) {
                    if (_navindex == 0) modalName = "ADD_TO_STOCKED";
                    if (_navindex == 1) modalName = "SHOP_LIST";
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return InputModal(modalName, vm, null);
                        });
                  }
                },
              ),
            )
          : SpeedDialButton(vm),
    );
  }

  Widget buildBottomNav() {
    return Container(
      child: BottomNavigationBar(
        selectedFontSize: 12,
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _navindex,
        unselectedItemColor: Colors.grey[400],
        items: [
          getBottomNavItem(0),
          getBottomNavItem(1),
          getBottomNavItem(2),
        ],
        onTap: (idx) {
          setState(() {
            _navindex = idx;
            pageController.animateToPage(idx,
                duration: Duration(milliseconds: 250), curve: Curves.easeOut);
            // pageController.jumpToPage(idx);
          });
        },
      ),
    );
  }

  BottomNavigationBarItem getBottomNavItem(int idx) {
    List<Widget> icons = [
      Icon(Icons.shopping_cart),
      Icon(Icons.format_list_bulleted),
      AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: expiredItems.length != 0 && _navindex != 2
              ? Stack(
                  children: <Widget>[
                    Icon(Icons.report),
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red[700],
                      ),
                    )
                  ],
                )
              : Icon(Icons.report))
    ];

    List<String> menuLabel = ["Stock", "Shopping List", "Expired"];

    return BottomNavigationBarItem(
      icon: Padding(padding: EdgeInsets.all(4), child: icons[idx]),
      title: Text(
        menuLabel[idx],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        builder: (BuildContext context, _ViewModel vm) {
          setItems(vm);
          return Scaffold(
            key: baseScaffold,
            drawer: Drawer(child: buildDrawerMenu(vm.items)),
            appBar: buildAppBar(),
            body: buildPageView(vm),
            floatingActionButton:
                _navindex != 2 ? buildFloatingAction(vm) : null,
            bottomNavigationBar: buildBottomNav(),
          );
        });
  }
}

//////////////////////////// VIEW MODEL REDUX //////////////////////////////////

class _ViewModel {
  final List<Item> items;
  final List<ShoppingItem> shopItems;
  final Function(String, String, DateTime, String) onAddItem;
  final Function(Item) onRemoveItem;
  final Function(Item) onUpdateItem;
  final Function(String, String) onAddShopItem;
  final Function(ShoppingItem) onRemoveShopItem;
  final Function(ShoppingItem) onUpdateShoppingItem;

  _ViewModel(
      {this.items,
      this.shopItems,
      this.onAddItem,
      this.onRemoveItem,
      this.onAddShopItem,
      this.onRemoveShopItem,
      this.onUpdateShoppingItem,
      this.onUpdateItem});

  factory _ViewModel.create(Store<AppState> store) {
    _onAddItem(String name, String quantity, DateTime expiry, String imageUri) {
      store.dispatch(AddItemAction(name, quantity, expiry, imageUri));
    }

    _onRemoveItem(Item item) {
      store.dispatch(RemoveItemAction(item));
    }

    _onAddShopItem(String name, String quantity) {
      store.dispatch(AddShoppingAction(name, quantity));
    }

    _onRemoveShopItem(ShoppingItem item) {
      store.dispatch(RemoveShoppingAction(item));
    }

    _onUpdateShoppingItem(ShoppingItem item) {
      store.dispatch(UpdateShoppingItemAction(item));
    }

    _onUpdateItem(Item item) {
      store.dispatch(UpdateItemAction(item));
    }

    var viewModel = _ViewModel(
      items: store.state.items,
      shopItems: store.state.shopItems,
      onAddItem: _onAddItem,
      onRemoveItem: _onRemoveItem,
      onAddShopItem: _onAddShopItem,
      onUpdateShoppingItem: _onUpdateShoppingItem,
      onRemoveShopItem: _onRemoveShopItem,
      onUpdateItem: _onUpdateItem,
    );
    return viewModel;
  }
}
