import 'package:flutter/material.dart';
import 'database/expiredItem.dart';
import 'database/db_helper.dart';

class Expired extends StatefulWidget {
  @override
  _ExpiredState createState() => _ExpiredState();
}

class _ExpiredState extends State<Expired> {
  Future<List<ExpiredItem>> _expiredItems;
  DBhelper _dBhelper;

  @override
  initState() {
    super.initState();
    _dBhelper = new DBhelper();
  }

  refreshItems() {
    setState(() {
    _expiredItems = _dBhelper.getExpiredItems();
    });
  }

  createListUI(List<ExpiredItem> items) {
    
    return new ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          child: ListTile(
          title: new Text(items[index].getName(), style: TextStyle(color: Colors.white)),
          subtitle: new Text(items[index].getExpiryDate(), style: TextStyle(color: Colors.white)),
          trailing: new MaterialButton(
            child: new Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _dBhelper.deleteExpiredItem(items[index].getName());
              refreshItems();
            },
          )
          ),
          decoration: new BoxDecoration(
            color: Colors.black
          )
        );
      },
    );
  }

  displayListUI() {
    refreshItems();
    return FutureBuilder(
      future: _expiredItems,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
            //temporary remove later
          if(snapshot.data == null || snapshot.data.length == 0){
            return new Center(
              child: new Text('No expired items')
            );
            //print('no data was there');
          }
          if(snapshot.hasData) {
            //create ListUI
            print(snapshot.data[0].getExpiryDate());
            return createListUI(snapshot.data);
            //print(snapshot.data[0].NAME);
          }
        }
        else {
          return new Center(
              child: new CircularProgressIndicator()
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: displayListUI(),
    );
  }
}