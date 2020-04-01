import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './expired.dart' as expired;
import './Items.dart' as items;
import './stock.dart' as stock;
import './recipe.dart' as showRecipe;
import './util/slide.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent));
  runApp(new MaterialApp(
    home: new AppTabs(),
  ));
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.white,
            accentColor: Color(0xff5c39f8),
            scaffoldBackgroundColor: Colors.white),
        home: Scaffold(
          appBar: new AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.book,
                    color: Color(0xff5c39f8),
                  ),
                  onPressed: () {
                    Navigator.push(context, Slide(page: showRecipe.Recipe()));
                  },
                )
              ],
              elevation: 0.0,
              title: new Container(
                  padding: new EdgeInsets.only(top: 10.0),
                  child: new Image(
                      image: AssetImage('assets/nosh.png'),
                      width: 65.0,
                      height: 250.0)),
              bottom: new TabBar(
                controller: _controller,
                tabs: <Tab>[
                  new Tab(child: new Text('Stocked')),
                  new Tab(child: new Text('Shopping List')),
                  new Tab(child: new Text('Expired'))
                ],
                indicatorColor: Color(0xff5c39f8),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[600],
              )),
          body: new TabBarView(controller: _controller, children: <Widget>[
            new stock.Stock(),
            new items.Items(),
            new expired.Expired()
          ]),
        ));
  }
}
