import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:nosh/database/expiredItem.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database/stockItem.dart' as stockItem;
import 'database/db_helper.dart' as db;
import 'package:intl/intl.dart';

class Stock extends StatefulWidget {
  @override
  _StockState createState() => _StockState();
}


class _StockState extends State<Stock> {

  Future<List<stockItem.StockItem>> _stockItems;
  db.DBhelper _dBhelper;

  @override
  initState() {
    super.initState();
    _dBhelper = new db.DBhelper();
  }

  refreshItems() {
    setState(() {
    _stockItems = _dBhelper.getItemsFromStock();
      print(_stockItems);
    });
  }

  Color tileColor(String date) {
    DateTime now = new DateTime.now();
    now = new DateTime(now.year, now.month, now.day);
    int daysLeft = DateTime.parse(date).difference(now).inDays;
    print('daysLeft');
    print(daysLeft);
    if(daysLeft == 0)
      return Colors.red;
    else if(daysLeft <= 3)
      return Colors.amber;
    else
      return Color(0xff5c39f8);
  }

  createListUI(List<stockItem.StockItem> items) {
    //filter dates
    for(int i = 0; i < items.length; i++) {
      DateTime now = new DateTime.now();
      now = new DateTime(now.year, now.month, now.day);
      int daysLeft = DateTime.parse(items[i].getExpiryDate()).difference(now).inDays;
      if(daysLeft < 0) {
        //move the item to expired list: todo
        ExpiredItem item = new ExpiredItem(items[i].getName(), items[i].getExpiryDate());
        _dBhelper.saveExpiredItem(item);
        _dBhelper.deleteItemFromStock(items[i].getName());
        items.remove(items[i]);
      }
    }
    return new ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return new Divider();
      },
      itemBuilder: (context, index) {
        return ListTile(
          leading: new Wrap(
              children: <Widget>[
                new IconButton(
                icon: new Icon(Icons.edit, color: Colors.black, size: 22),
                onPressed: () {
                  DateTime date = DateTime.parse(items[index].getExpiryDate());
                  createAlertDialog(context, false, name: items[index].getName(), initDate: date).then((onValue) {
                    if(onValue != null) {
                      items[index].setName(onValue[0]);
                      String dateconverted = new DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
                      items[index].setExpiryDate(dateconverted);
                      _dBhelper.updateItemFromStock(items[index]);
                      refreshItems();
                    }
                  });
                },
              ),
              new IconButton(
                icon: new Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  createDeleteAlert(context).then((onValue) {
                    if(onValue != null && onValue) {
                      _dBhelper.deleteItemFromStock(items[index].getName());
                      refreshItems();
                    }
                  });
                },
              )
              ]),
          title: new Text(items[index].getName()),
          subtitle: new Text(items[index].getExpiryDate()),
          trailing: new Icon(Icons.report, color: tileColor(items[index].getExpiryDate()))
          );
      },
    );
  }

  //make a future builder with the dynamic list view
  displayListUI() {
    refreshItems();
    return FutureBuilder(
      future: _stockItems,
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

  Future<List> createAlertDialog(BuildContext context, bool state, {String name = '', DateTime initDate = null}) {
    
    TextEditingController controller = new TextEditingController();
    CalendarController calendarController = new CalendarController();
    DateTimePickerTheme dateTimePickerTheme = new DateTimePickerTheme(
      cancel: Text(""),
      confirm: Text(""),
      title: Text('Select Expiry Date')
    );
    DateTime date = DateTime.now();
    String productName = '';
    String submitButtonText = 'Add Item';
    if(state == false) {
      date = initDate;
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
            Navigator.of(context).pop([productName, date]);
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
          ),
          /*new TableCalendar(
            calendarController: calendarController,
            builders: CalendarBuilders(),
          )*/
          SizedBox(height: 30,),
          new DatePickerWidget(
            minDateTime: DateTime(2018),
            maxDateTime: DateTime(2030),
            initialDateTime: date,
            locale: DATETIME_PICKER_LOCALE_DEFAULT,
            pickerTheme: dateTimePickerTheme,
            onChange: (dateTime, index) {
              date = dateTime;
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
    print('called');
    return new Scaffold(
      body: displayListUI(),
      floatingActionButton: new FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: new Color(0xff5c39f8),
        onPressed: () {
          createAlertDialog(context, true).then((onValue) {
            if(onValue != null) {
              print(onValue[0]);
              print(onValue[1]);
              String date = new DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
              stockItem.StockItem item = new stockItem.StockItem(onValue[0], date);
              _dBhelper.saveToStock(item);
              refreshItems();
            }
          });
        }
      )
    );
  }
}