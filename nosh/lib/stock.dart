import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database/stockItem.dart' as stockItem;
import 'database/db_helper.dart' as db;
import 'package:intl/intl.dart';

class Stock extends StatefulWidget {
  @override
  StockState createState() => StockState();
}


class StockState extends State<Stock> {

  Future<List<stockItem.StockItem>> stockItems;
  db.DBhelper dBhelper;

  @override
  initState() {
    super.initState();
    dBhelper = new db.DBhelper();
  }

  refreshItems() {
    setState(() {
      stockItems = dBhelper.getItemsFromStock();
      print(stockItems);
    });
  }

  Color tileColor(String date) {
    int daysLeft = DateTime.parse(date).difference(DateTime.now()).inDays;
    print('daysLeft');
    print(daysLeft);
    if(daysLeft == 0)
      return Colors.red;
    else if(daysLeft <= 3)
      return Colors.amber;
    else
      return Colors.white;
  }

  createListUI(List<stockItem.StockItem> items) {
    //filter dates
    for(int i = 0; i < items.length; i++) {
      int daysLeft = DateTime.parse(items[i].DATE).difference(DateTime.now()).inDays;
      if(daysLeft < 0) {
        //move the item to expired list: todo
        items.remove(items[i]);
      }
    }
    return new ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          child: ListTile(
          leading: new MaterialButton(
            child: new Icon(Icons.edit),
            onPressed: () {
              DateTime date = DateTime.parse(items[index].DATE);
              createAlertDialog(context, false, name: items[index].NAME, initDate: date).then((onValue) {
                items[index].setName(onValue[0]);
                String dateconverted = new DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
                items[index].setDate(dateconverted);
                dBhelper.updateItemFromStock(items[index]);
                refreshItems();
              });
            },
          ),
          title: new Text(items[index].NAME),
          subtitle: new Text(items[index].DATE),
          trailing: new MaterialButton(
            child: new Icon(Icons.delete),
            onPressed: () {
              dBhelper.deleteItemFromStock(items[index].NAME);
              refreshItems();
            },
          ),
          ),
          decoration: new BoxDecoration(
            color: tileColor(items[index].DATE)
          )
        );
      },
    );
  }

  //make a future builder with the dynamic list view
  displayListUI() {
    refreshItems();
    return FutureBuilder(
      future: stockItems,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          //create ListUI
          print(snapshot.data[0].DATE);
          return createListUI(snapshot.data);
          //print(snapshot.data[0].NAME);
        }
        //temporary remove later
        if(snapshot.data == null || snapshot.data.length == 0){
          return new Center(
            child: new Text('No items added')
          );
          //print('no data was there');
        }
        return new Center(
            child: new CircularProgressIndicator()
          );
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
    calendarController.dispose();
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
            print(onValue[0]);
            print(onValue[1]);
            String date = new DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
            stockItem.StockItem item = new stockItem.StockItem(onValue[0], date);
            dBhelper.saveToStock(item);
            refreshItems();
          });
        }
      )
    );
  }
}