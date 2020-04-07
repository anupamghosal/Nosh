import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nosh/database/expiredItem.dart';
import './expired.dart' as expired;
import './Items.dart' as items;
import './stock.dart' as stock;
import './selectPanel.dart';
import './util/slide.dart';
import './onBoarding.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DBhelper dBhelper = DBhelper();
  bool welcome = await dBhelper.dbExists();
  //bool welcome = true;
  print(welcome);
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

  DBhelper _dBhelper;
  TabController _controller;
  int _expiredItemCount = 0;

  @override
  initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this);
    _dBhelper = new DBhelper();
    initializeExpiredItemCount();
  }

  initializeExpiredItemCount() async {
    List<ExpiredItem> items = await _dBhelper.getExpiredItems();
    print(items.length);
    setState(() {
      _expiredItemCount = items.length;
    });
  }

  incrementExpiredItemCount() {
    setState(() {
      _expiredItemCount = _expiredItemCount + 1;
    });
  }

  decrementExpiredItemCount() {
    setState(() {
      _expiredItemCount = _expiredItemCount - 1;
    });
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
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => OnBoardingPage(false))),
                  icon: Icon(
                    Icons.help_outline,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.restaurant,
                    color: Color(0xff5c39f8),
                  ),
                  onPressed: () {
                    Navigator.push(context, Slide(page: SelectPanel()));
                  },
                )
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
                  new Tab(
                    child: _expiredItemCount != 0 ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Expired'),
                        SizedBox( width: 5),
                        CircleAvatar(
                          radius: 9,
                          child: Text(
                            _expiredItemCount.toString(), 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              fontSize: 10.0
                            )
                          ),
                          backgroundColor: Color(0xff5c39f8),
                        )
                      ]
                    ) : Text('Expired')
                  )
                ],
                indicatorColor: Color(0xff5c39f8),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[600],
              )),
          body: new TabBarView(controller: _controller, children: <Widget>[
            new stock.Stock(incrementExpiredItemCount: () {incrementExpiredItemCount();},),
            new items.Items(incrementExpiredItemCount: () {incrementExpiredItemCount();},),
            new expired.Expired(decrementExpiredItemCount: () {decrementExpiredItemCount();},)
          ]),
        ));
  }
}
