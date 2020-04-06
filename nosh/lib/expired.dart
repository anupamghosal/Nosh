import 'package:flutter/material.dart';
import 'database/expiredItem.dart';
import 'database/db_helper.dart';
import 'dart:io';

class Expired extends StatefulWidget {
  @override
  _ExpiredState createState() => _ExpiredState();
}

class _ExpiredState extends State<Expired> {
  Future<List<ExpiredItem>> _expiredItems;
  DBhelper _dBhelper;
  bool _longPressedEventActive = false;

  @override
  initState() {
    super.initState();
    _dBhelper = DBhelper();
  }

  refreshItems() {
    setState(() {
      _expiredItems = _dBhelper.getExpiredItems();
    });
  }

  createUI(List<ExpiredItem> items) {
    return RefreshIndicator(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: createListUI(items)),
          _longPressedEventActive
              ? Container(
                  padding: EdgeInsets.all(20.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text("cancel"),
                    color: Color(0xff5c39f8),
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _longPressedEventActive = false;
                      });
                    },
                  ),
                )
              : Container()
        ],
      ),
      onRefresh: () async {
        refreshItems();
      },
    );
  }

  createListUI(List<ExpiredItem> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemBuilder: (context, index) {
        return ListTile(
            onLongPress: () {
              setState(() {
                _longPressedEventActive = true;
              });
            },
            leading: _longPressedEventActive
                ? IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      createDeleteAlert(context).then((onValue) {
                        if (onValue != null && onValue) {
                          _dBhelper.deleteExpiredItem(items[index].getName());
                          if (!items[index].getImage().startsWith('https') &&
                              items[index].getImage() != '')
                            File(items[index].getImage()).delete();
                          refreshItems();
                        }
                      });
                    },
                  )
                : Container(
                    child: CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                            selectImageType(items[index].getImage()),
                        child: selectImageType(items[index].getImage()) == null
                            ? Icon(Icons.fastfood)
                            : null),
                  ),
            title: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(flex: 6, child: Text(items[index].getName())),
                  items[index].getQuantity() != ''
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(4.0)),
                          margin: EdgeInsets.only(left: 20.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 3.0),
                          child: Text(
                            items[index].getQuantity(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
            subtitle: Text(items[index].getExpiryDate()),
            trailing: Icon(Icons.report, color: Colors.red[900]));
      },
    );
  }

  selectImageType(String link) {
    if (link.startsWith('https'))
      return NetworkImage(link);
    else if (link == '')
      return null;
    else
      return FileImage(File(link));
  }

  displayListUI() {
    refreshItems();
    return FutureBuilder(
      future: _expiredItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //temporary remove later
          if (snapshot.data == null || snapshot.data.length == 0) {
            return Center(
                child: Text(
              'No expired items',
              style: TextStyle(color: Colors.grey[600]),
            ));
            //print('no data was there');
          }
          if (snapshot.hasData) {
            //create ListUI
            print(snapshot.data[0].getExpiryDate());
            return createUI(snapshot.data);
            //print(snapshot.data[0].NAME);
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future createDeleteAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text("Are you sure?"), actions: <Widget>[
            MaterialButton(
              child: Text('Yes', style: TextStyle(color: Color(0xff5c39f8))),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            MaterialButton(
                child: Text('No', style: TextStyle(color: Color(0xff5c39f8))),
                onPressed: () {
                  Navigator.of(context).pop(false);
                })
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: displayListUI(),
    );
  }
}
