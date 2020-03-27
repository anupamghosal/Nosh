import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './expired.dart' as expired;
import './Items.dart' as items;
import './stock.dart' as stock;

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light));
  runApp(new MaterialApp(home: new AppTabs()));
}

class AppTabs extends StatefulWidget {
  @override
  AppTabsState createState() => new AppTabsState();
}

class AppTabsState extends State<AppTabs> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primaryColor: new Color(0xff5c39f8)),
        home: Scaffold(
          appBar: new AppBar(
              title: new Container(
                  padding: new EdgeInsets.only(top: 10.0),
                  child: new Image(
                      image: AssetImage('assets/nosh.png'),
                      width: 50.0,
                      height: 250.0)),
              bottom: new TabBar(controller: _controller, tabs: <Tab>[
                new Tab(child: new Text('Stocked')),
                new Tab(child: new Text('Shopping List')),
                new Tab(child: new Text('Expired'))
              ])),
          body: new TabBarView(controller: _controller, children: <Widget>[
            new stock.Stock(),
            new items.Items(),
            new expired.Expired()
          ]),
        ));
  }
}
