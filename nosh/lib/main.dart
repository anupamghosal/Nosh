import 'package:flutter/material.dart';
import 'package:nosh/data/middleware.dart';
import 'package:nosh/pages/onBoarding.dart';
import 'package:nosh/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './homepage.dart';

import 'package:flutter/services.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import './data/reducers/reducers.dart';
import './data/appState.dart';
import 'data/actions/actions.dart';
import 'helpers/notificationHelper.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));

  runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final Store<AppState> store = Store<AppState>(appStateReducer,
      initialState: AppState.initialState(), middleware: [appStateMiddleware]);

  Store<AppState> _currentStore;

  bool isFirstBoot = false;
  var thisContext;
  @override
  void initState() {
    super.initState();
    _currentStore = store;
    WidgetsBinding.instance.addObserver(this);
    initializeAndCancelNotifications();
    checkBootSatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        scheduleNotifications(_currentStore.state.items);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        scheduleNotifications(_currentStore.state.items);
        break;
      case AppLifecycleState.resumed:
        initializeAndCancelNotifications();
        setState(() => {});
        break;
    }
  }

  checkBootSatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var boot = prefs.getString('noshBoot');
    if (boot == null) setState(() => isFirstBoot = true);
  }

  @override
  Widget build(BuildContext context) {
    thisContext = context;
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: noshTheme(),
        home: isFirstBoot
            ? OnBoardingPage(store, isFirstBoot)
            : Scaffold(
                body: StoreBuilder<AppState>(onInit: (store) {
                  store.dispatch(GetItemsAction());
                  store.dispatch(GetShoppingItemsAction());
                }, builder: (BuildContext context, Store<AppState> store) {
                  _currentStore = store;
                  return HomePage(store, isFirstBoot);
                }),
              ),
      ),
    );
  }
}
