import 'package:flutter/material.dart';
import './expired.dart' as expired;
import './Items.dart' as items;
import './stock.dart' as stock;

void main() {
  runApp(new MaterialApp(
    home: new AppTabs()
  ));
}

class AppTabs extends StatefulWidget {
  @override
  AppTabsState createState() => new AppTabsState();
}

class AppTabsState extends State<AppTabs> with SingleTickerProviderStateMixin {

  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Nosh"),
        backgroundColor: Colors.red,
        bottom: new TabBar(
          controller: controller,
          tabs: <Tab>[
            new Tab(child: new Text('Stock')),
            new Tab(child: new Text('List')),
            new Tab(child: new Text('Expired'))
          ]
        )
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new stock.Stock(),
          new items.Items(),
          new expired.Expired()
        ]
      ),
    );
  }
}