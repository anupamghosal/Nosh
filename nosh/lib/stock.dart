import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Stock extends StatefulWidget {
  @override
  StockState createState() => StockState();
}


class StockState extends State<Stock> {

  

  createAlertDialog(BuildContext context) {
    
    TextEditingController controller = new TextEditingController();
    CalendarController calendarController = new CalendarController();
    
    return showDialog(context: context, builder: (context) {
      return new AlertDialog(
      title: new Text('Add Item'),
      actions: <Widget>[
        new MaterialButton(
          child: new Text('Add Item'),
          onPressed: null,
          elevation: 5.0
        )
      ],
      content: new Column(
        children: <Widget>[
          new TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Product name...'
            )
          ),
          new TableCalendar(calendarController: calendarController)
        ]
      )
    );
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: new FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () {
          createAlertDialog(context);
        }
      )
    );
  }
}