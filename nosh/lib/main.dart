import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './expired.dart' as expired;
import './Items.dart' as items;
import './stock.dart' as stock;
import './selectPanel.dart';
import './util/slide.dart';
import './onBoarding.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DBhelper dBhelper = new DBhelper();
  bool welcome = await dBhelper.dbExists();
  //bool welcome = true;
  print(welcome);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  runApp(new MaterialApp(
    theme: ThemeData(scaffoldBackgroundColor: Colors.white),
    home: welcome ? OnBoardingPage(welcome) : AppTabs(),
  ));
}

class AppTabs extends StatefulWidget {
  @override
  AppTabsState createState() => new AppTabsState();
}

class AppTabsState extends State<AppTabs> with SingleTickerProviderStateMixin {
  AppTabsState();

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
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.white,
            accentColor: Color(0xff5c39f8)),
        home: Scaffold(
          appBar: new AppBar(
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
