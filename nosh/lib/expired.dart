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
    
    return new ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemBuilder: (context, index) {
        return ListTile(
          leading: new IconButton(
            icon: new Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              createDeleteAlert(context).then((onValue) {
                if(onValue != null && onValue) {
                  _dBhelper.deleteExpiredItem(items[index].getName());
                  refreshItems();
                }
              });
            },
          ),
          title: new Text(items[index].getName()),
          subtitle: new Text(items[index].getExpiryDate()),
          trailing: Icon(Icons.sentiment_very_dissatisfied, color: Colors.black)
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

  Future createDeleteAlert(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return new AlertDialog(
        title: new Text("Are you sure?"),
        actions: <Widget>[
          new MaterialButton(
            child: new Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          new MaterialButton(
            child: new Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            }
          )
        ]
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: displayListUI(),
    );
  }
}