import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './onBoarding.dart';
import './analytics.dart';
import './util/slide.dart';
import 'database/db_helper.dart';
import 'database/expiredItem.dart';
import 'database/stockItem.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  DBhelper _dBhelper;
  Future<List<StockItem>> _stockItems;

  Future<List<ExpiredItem>> _expiredItems;

  @override
  initState() {
    _dBhelper = DBhelper();
    super.initState();
  }

  List<String> settings = [
    "Weekly analytics",
    "Help",
    "Privacy policy",
    "About us"
  ];

  final icons = [
    Icon(Icons.graphic_eq),
    Icon(Icons.help),
    Icon(Icons.book),
    Icon(Icons.supervised_user_circle)
  ];

  List<String> urls = [
    "https://nosh.tech/privacy-policy.html",
    "https://nosh.tech/index.html#about"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5c39f8),
        title: Text("Settings"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: settings.length,
          separatorBuilder: (BuildContext context, int idx) => Divider(),
          itemBuilder: (BuildContext context, int idx) {
            return ListTile(
              leading: icons[idx],
              title: Text(settings[idx]),
              onTap: () async {
                if (idx == 2 || idx == 3) launch(urls[idx - 2]);
                if (idx == 0) {
                  setState(() {
                    _stockItems = _dBhelper.getItemsFromStock();
                    _expiredItems = _dBhelper.getExpiredItems();
                  });
                  var exItems = await _expiredItems;
                  var stItems = await _stockItems;

                  var xyz = await Navigator.push(
                      context, Slide(page: Analysis(exItems, stItems)));
                }
                if (idx == 1)
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => OnBoardingPage(false)));
              },
            );
          },
        ),
      ),
    );
  }
}
