import 'package:flutter/material.dart';
import 'database/stockItem.dart' as stockItem;
import 'database/db_helper.dart' as db;
import './recipeCarosel.dart';
import './util/slide.dart';

class SelectPanel extends StatefulWidget {
  @override
  SelectPanelState createState() => SelectPanelState();
}

class SelectPanelState extends State<SelectPanel> {
  Future<List<stockItem.StockItem>> _stockItems;
  db.DBhelper _dBhelper;
  final _selectedFood = Set<String>();

  initState() {
    super.initState();
    _dBhelper = new db.DBhelper();
  }

  refreshItems() {
    setState(() {
      _stockItems = _dBhelper.getItemsFromStock();
    });
  }

  buildRow(List<stockItem.StockItem> items) {
    return Theme(
      data: ThemeData(accentColor: Color(0xff5c39f8)),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (context, index) {
          final name = items[index].getName();
          final alreadySelected = _selectedFood.contains(name);
          return ListTile(
            onTap: () {
              setState(() {
                if (alreadySelected) {
                  _selectedFood.remove(name);
                } else {
                  _selectedFood.add(name);
                }
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            leading: alreadySelected
                ? Icon(
                    Icons.check_circle,
                    color: Color(0xff5c39f8),
                  )
                : Icon(Icons.check_circle_outline),
            title: new Text(items[index].getName()),
            subtitle: new Text(items[index].getExpiryDate()),
          );
        },
      ),
    );
  }

  buildList() {
    refreshItems();
    return FutureBuilder(
      future: _stockItems,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.length == 0) {
          return Center(
              child: new Text(
            'You do not have any food item',
            style: TextStyle(color: Colors.grey[600]),
          ));
        }
        if (snapshot.hasData) {
          return createUI(snapshot.data);
        }
      },
    );
  }

  createUI(List<stockItem.StockItem> items) {
    return Column(
      children: <Widget>[
        Expanded(child: buildRow(items)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                minWidth: double.infinity, minHeight: 40.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text("get recipes"),
              color: Color(0xff5c39f8),
              textColor: Colors.white,
              disabledColor: Colors.grey[300],
              onPressed: !_selectedFood.isEmpty
                  ? () {
                      String query = "";
                      for (var item in _selectedFood) {
                        if (query == "") {
                          query = query + item;
                        } else {
                          query = query + "," + item;
                        }
                      }

                      Navigator.push(
                          context, Slide(page: RecipeCarosel(query: query)));
                    }
                  : null,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Select food items'),
          backgroundColor: Color(0xff5c39f8),
        ),
        body: buildList());
  }
}
