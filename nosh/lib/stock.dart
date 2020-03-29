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
    Future<List<stockItem.StockItem>> items = _dBhelper.getItemsFromStock();
    setState(() {
      _stockItems = items;
    });
  }

  Icon tileColor(String date) {
    DateTime now = new DateTime.now();
    now = new DateTime(now.year, now.month, now.day);
    int daysLeft = DateTime.parse(date).difference(now).inDays;
    if (daysLeft == 0) {
      return Icon(Icons.error_outline, color: Colors.red);
    }
    else if (daysLeft <= 2) {
      return Icon(Icons.report_problem, color: Colors.amber);
    }
    else {
      return null;
    }
  }

  createListUI(List<stockItem.StockItem> items) {
    //filter dates
    for (int i = 0; i < items.length; i++) {
      DateTime now = new DateTime.now();
      now = new DateTime(now.year, now.month, now.day);
      int daysLeft =
          DateTime.parse(items[i].getExpiryDate()).difference(now).inDays;
      if (daysLeft < 0) {
        //move the item to expired list: todo
        ExpiredItem item =
            new ExpiredItem(items[i].getName(), items[i].getExpiryDate());
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
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            leading: new Wrap(children: <Widget>[
              new IconButton(
                padding: new EdgeInsets.all(0.0),
                icon: new Icon(Icons.edit, color: Colors.black, size: 22),
                onPressed: () {
                  DateTime date = DateTime.parse(items[index].getExpiryDate());
                  createAlertDialog(context, false,
                          name: items[index].getName(), initDate: date)
                      .then((onValue) {
                    if (onValue != null) {
                      items[index].setName(onValue[0]);
                      String dateconverted = new DateFormat('yyyy-MM-dd')
                          .format(onValue[1])
                          .toString();
                      items[index].setExpiryDate(dateconverted);
                      _dBhelper.updateItemFromStock(items[index]);
                      refreshItems();
                    }
                  });
                },
              ),
              new IconButton(
                icon: new Icon(Icons.delete, color: Colors.red),
                padding: new EdgeInsets.all(0.0),
                onPressed: () {
                  createDeleteAlert(context).then((onValue) {
                    if (onValue != null && onValue) {
                      _dBhelper.deleteItemFromStock(items[index].getName());
                      refreshItems();
                    }
                  });
                },
              )
            ]),
            title: new Text(items[index].getName()),
            subtitle: new Text(items[index].getExpiryDate()),
            trailing: tileColor(items[index].getExpiryDate()));
      },
    );
  }

  //make a future builder with the dynamic list view
  displayUI() {
    //refreshItems();
    return FutureBuilder(
      future: _stockItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //temporary remove later
          if (snapshot.data == null || snapshot.data.length == 0) {
            return new Center(
                child: new Text(
              'Add food items and track their expiry',
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
          return new Center(child: new CircularProgressIndicator());
        }
      },
    );
  }

  createCounterPanel(List<stockItem.StockItem> items) {
    int redCounter = 0, amberCounter = 0, blueCounter = 0;
    for(stockItem.StockItem item in items) {
      String date = item.getExpiryDate();
      DateTime now = new DateTime.now();
      now = new DateTime(now.year, now.month, now.day);
      int daysLeft = DateTime.parse(date).difference(now).inDays;
      if(daysLeft >= 0) {
        if (daysLeft == 0) {
          redCounter = redCounter + 1;
        }
        else if (daysLeft <= 2) {
          amberCounter = amberCounter + 1;
        }
        else {
          blueCounter = blueCounter + 1;
        }
      }
    }
    return new Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.error_outline, color: Colors.white),
                        Text(redCounter.toString(),
                            style: TextStyle(
                                color: Colors.white)) //dynamic value here
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    height: 40.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(colors: [
                          Colors.red,
                          Colors.pink
                        ])), //1Day to expire alert
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.report_problem),
                        Text(amberCounter.toString()) // dynamic value here
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    height: 40.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(colors: [
                          Colors.amber,
                          Colors.yellow
                        ])), //2Days to expire alert
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.shopping_cart, color: Colors.white),
                        Text(blueCounter.toString(),
                            style: TextStyle(
                                color: Colors.white)) // dynamic value here
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    height: 40.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(colors: [
                          Color(0xFF5C39F8),
                          Colors.blue
                        ])), //3Days to expire alert
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0)),
            );
  }

  createUI(List<stockItem.StockItem> items) {
    return Column(
          children: <Widget>[
            createCounterPanel(items),
            Expanded(child: createListUI(items))
          ],
        );
  }

  Future<List> createAlertDialog(BuildContext context, bool state,
      {String name = '', DateTime initDate = null}) {
    TextEditingController controller = new TextEditingController();
    CalendarController calendarController = new CalendarController();
    //initialization of units
    List<String> units = ['kg', 'g', 'l', 'ml', 'unit'];
    List<DropdownMenuItem<String>> menuItems = List();
    for (String unit in units) {
      menuItems.add(DropdownMenuItem(value: unit, child: Text(unit)));
    }
    DateTimePickerTheme dateTimePickerTheme = new DateTimePickerTheme(
        cancel: Text(""), confirm: Text(""), title: Text('Select Expiry Date'));
    DateTime date = DateTime.now();
    String productName = '';
    String submitButtonText = 'Add Item';
    if (state == false) {
      date = initDate;
      productName = name;
      controller.text = productName;
      submitButtonText = 'Update Item';
    }

    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
              contentPadding: EdgeInsets.all(25.0),
              title: new Text(submitButtonText),
              actions: <Widget>[
                new MaterialButton(
                    child: new Text(submitButtonText,
                        style: TextStyle(color: Color(0xff5c39f8))),
                    onPressed: () {
                      //print(productName);
                      //print(date);
                      Navigator.of(context).pop([productName, date]);
                    },
                    elevation: 5.0)
              ],
              content: new SingleChildScrollView(
                  child: new Column(children: <Widget>[
                new TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add product name...',
                  ),
                  onChanged: (String value) {
                    productName = value;
                  },
                ),
                /*new TableCalendar(
            calendarController: calendarController,
            builders: CalendarBuilders(),
          )*/
                SizedBox(
                  height: 30,
                ),
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
              ])));
        });
    //preventing memory leaks
    controller.dispose();
    //calendarController.dispose();
  }

  Future createDeleteAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
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
                    })
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    print('called');
    return new Scaffold(
        body: displayUI(),
        floatingActionButton: new FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: new Color(0xff5c39f8),
            onPressed: () {
              createAlertDialog(context, true).then((onValue) {
                if (onValue != null) {
                  print(onValue[0]);
                  print(onValue[1]);
                  String date = new DateFormat('yyyy-MM-dd')
                      .format(onValue[1])
                      .toString();
                  stockItem.StockItem item =
                      new stockItem.StockItem(onValue[0], date);
                  _dBhelper.saveToStock(item);
                  refreshItems();
                }
              });
            }));
  }
}
