import 'package:flutter/material.dart';
import 'database/listItem.dart';
import 'database/db_helper.dart';
import 'package:intl/intl.dart';
import 'database/stockItem.dart';
import 'database/expiredItem.dart';

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Future<List<ListItem>> _listItems;
  DBhelper _dBhelper;

  @override
  initState() {
    super.initState();
    _dBhelper = new DBhelper();
  }

  refreshItems() {
    setState(() {
    _listItems = _dBhelper.getItemsFromList();
    });
  }

  Future<DateTime> createDatePicker(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
  }

  createListUI(List<ListItem> items) {
    
    return new ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, builder) {
        return new Divider();
      },
      itemBuilder: (context, index) {
        return ListTile(
          leading: new IconButton(
            icon: new Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              createAlertDialog(context, false, name: items[index].getName()).then((onValue) {
                if(onValue != null) {
                  items[index].setName(onValue);
                  _dBhelper.updateItemFromList(items[index]);
                  refreshItems();
                }
              });
            },
          ),
          title: new Text(items[index].getName()),
          trailing: new Wrap(
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.add_shopping_cart, color: Colors.grey[800], size: 22),
                onPressed: () {
                  //shift item : todo
                  createDatePicker(context).then((onValue) {
                    if(onValue != null) {
                      String date = new DateFormat('yyyy-MM-dd').format(onValue).toString();
                      DateTime now = new DateTime.now();
                      now = new DateTime(now.year, now.month, now.day);
                      int daysLeft = DateTime.parse(date).difference(now).inDays;
                      if(daysLeft < 0) {
                        ExpiredItem item = new ExpiredItem(items[index].getName(), date);
                        _dBhelper.saveExpiredItem(item);
                      }
                      else {
                        StockItem item = new StockItem(items[index].getName(), date);
                        _dBhelper.saveToStock(item);
                      }
                      _dBhelper.deleteItemFromList(items[index].getName());
                      refreshItems();
                    }
                  });
                },
              ),
              new IconButton(
                icon: new Icon(Icons.cancel, color: Colors.red, size: 22),
                onPressed: () {
                  createDeleteAlert(context).then((onValue) {
                    if(onValue != null && onValue) {
                      _dBhelper.deleteItemFromList(items[index].getName());
                      refreshItems();
                    }
                  });
                },
              )
            ],
          ),
          );
      },
    );
  }

  displayListUI() {
    refreshItems();
    return FutureBuilder(
      future: _listItems,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
            //temporary remove later
          if(snapshot.data == null || snapshot.data.length == 0){
            return new Center(
              child: new Text('No items added')
            );
            //print('no data was there');
          }
          if(snapshot.hasData) {
            //create ListUI
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

  Future createAlertDialog(BuildContext context, bool state, {String name = ''}) {
    TextEditingController controller = new TextEditingController();
    String productName = '';
    String submitButtonText = 'Add Item';
    if(state == false) {
      productName = name;
      controller.text = productName;
      submitButtonText = 'Update Item';
    }
    
    return showDialog(context: context, builder: (context) {
      return new AlertDialog(
      title: new Text(submitButtonText),
      actions: <Widget>[
        new MaterialButton(
          child: new Text(submitButtonText),
          onPressed: () {
            //print(productName);
            //print(date);
            Navigator.of(context).pop(productName);
          },
          elevation: 5.0
        )
      ],
      content: new SingleChildScrollView(
        child: new Column(
        children: <Widget>[
          new TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Product name...',
            ),
            onChanged: (String value) {
              productName = value;
            },
          )
        ]
      )
      )
    );
    });
    //preventing memory leaks
    controller.dispose();
    //calendarController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: displayListUI(),
      floatingActionButton: new FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: new Color(0xff5c39f8),
        onPressed: () {
          createAlertDialog(context, true).then((onValue) {
            if(onValue != null) {
              ListItem item = new ListItem(onValue);
              _dBhelper.saveToList(item);
              refreshItems();
            }
          });
        }
      )
    );
  }
}