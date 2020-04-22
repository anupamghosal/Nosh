import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nosh/database/expiredItem.dart';
import 'package:nosh/settings.dart';
import './expired.dart' as expired;
import './Items.dart' as items;
import './stock.dart' as stock;
import './selectPanel.dart';
import './util/slide.dart';
import './onBoarding.dart';
import 'database/db_helper.dart';
import './util/searcher.dart';
import 'database/expiredItem.dart';
import 'database/stockItem.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DBhelper dBhelper = DBhelper();
  bool welcome = await dBhelper.dbExists();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  runApp(MaterialApp(
    theme: ThemeData(scaffoldBackgroundColor: Colors.white),
    home: welcome ? OnBoardingPage(welcome) : AppTabs(),
  ));
}

class AppTabs extends StatefulWidget {
  @override
  AppTabsState createState() => AppTabsState();
}

class AppTabsState extends State<AppTabs> with SingleTickerProviderStateMixin {
  AppTabsState();
  TabController _controller;
  final _key = new GlobalKey<_CounterState>();
  Future<List<StockItem>> _stockItems;
  var result;
  DBhelper _dBhelper;

  @override
  initState() {
    _dBhelper = DBhelper();
    super.initState();
    _stockItems = _dBhelper.getItemsFromStock();
    _controller = new TabController(length: 3, vsync: this);
  }

  incrementExpiredItemCount(int count) {
    print(count);
    _key.currentState.incrementExpiredItemCount(count);
  }

  decrementExpiredItemCount() {
    _key.currentState.decrementExpiredItemCount();
  }

  initializeExpiredItemCount() {
    _key.currentState.initializeExpiredItemCount();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.white,
            accentColor: Color(0xff5c39f8)),
        home: Scaffold(
          appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    setState(() {
                      _stockItems = _dBhelper.getItemsFromStock();
                    });

                    var items = await _stockItems;
                    result = await showSearch(
                        context: context, delegate: searchItems(items));

                    if (result != null) result = await result.getId();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.restaurant,
                    color: Color(0xff5c39f8),
                  ),
                  onPressed: () {
                    Navigator.push(context, Slide(page: SelectPanel()));
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.list,
                  ),
                  onPressed: () =>
                      Navigator.push(context, Slide(page: Settings())),
                ),
              ],
              elevation: 0.0,
              title: Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Image(
                      image: AssetImage('assets/nosh.png'),
                      width: 65.0,
                      height: 250.0)),
              bottom: TabBar(
                controller: _controller,
                tabs: <Tab>[
                  new Tab(child: new Text('Stocked')),
                  new Tab(child: new Text('Shopping List')),
                  new Tab(child: Counter(key: _key))
                ],
                indicatorColor: Color(0xff5c39f8),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[600],
              )),
          body: new TabBarView(controller: _controller, children: <Widget>[
            new stock.Stock(
              results: result,
              incrementExpiredItemCount: (int count) {
                incrementExpiredItemCount(count);
              },
            ),
            new items.Items(
              incrementExpiredItemCount: () {
                incrementExpiredItemCount(1);
              },
            ),
            new expired.Expired(
              decrementExpiredItemCount: () {
                decrementExpiredItemCount();
              },
            )
          ]),
        ));
  }
}

//counter
class Counter extends StatefulWidget {
  Counter({Key key}) : super(key: key);

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _expiredItemCount = 0;
  DBhelper _dBhelper;

  @override
  void initState() {
    _dBhelper = new DBhelper();
    initializeExpiredItemCount();
  }

  initializeExpiredItemCount() async {
    List<ExpiredItem> items = await _dBhelper.getExpiredItems();
    setState(() {
      _expiredItemCount = items.length;
    });
    print('refreshed items');
    print(items.length);
  }

  incrementExpiredItemCount(int count) {
    setState(() {
      _expiredItemCount = _expiredItemCount + count;
    });
    //initializeExpiredItemCount();
  }

  decrementExpiredItemCount() {
    /*setState(() {
      // _expiredItemCount = _expiredItemCount == 0 ? 0 : _expiredItemCount - 1;
      //initializeExpiredItemCount();
    });*/
    setState(() {
      _expiredItemCount = _expiredItemCount == 0 ? 0 : _expiredItemCount - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text('Expired'),
      // SizedBox(width: 7),
      AnimatedCrossFade(
        duration: Duration(milliseconds: 300),
        crossFadeState: _expiredItemCount != 0
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Padding(
          padding: const EdgeInsets.only(left: 7.0),
          child: CircleAvatar(
            radius: 9,
            child: Text(_expiredItemCount.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9)),
            backgroundColor: Color(0xff5c39f8),
          ),
        ),
        secondChild: SizedBox(),
      )
    ]);
  }
}
