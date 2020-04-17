import 'dart:collection';

import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'database/stockItem.dart';
import 'database/expiredItem.dart';

class Analysis extends StatefulWidget {
  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {

  DBhelper _dBhelper;
  Future<List<StockItem>> _stockItems;
  Future<List<ExpiredItem>> _expiredItems;

  @override
  void initState() {
    super.initState();
    _dBhelper = new DBhelper();
  }

  refreshGraphs() {
    setState(() {
      _stockItems = _dBhelper.getItemsFromStock();
      _expiredItems = _dBhelper.getExpiredItems();
    });
  }

  createGraph(int n, double width, List<ChartItem> data) {
    List<String> headings = ["Expiry trend", "Buying trend"];

    List<charts.Series<ChartItem, String>> series = [
      charts.Series(
          id: "Subscribers",
          data: data,
          domainFn: (ChartItem items, _) => items.itemName,
          measureFn: (ChartItem items, _) => items.frequency)
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey[200], blurRadius: 20.0, offset: Offset(5, 5))
        ],
      ),
      width: width / 2 - 30,
      height: width / 3 + 10,
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Text(
            headings[n],
            style: TextStyle(fontSize: 16),
          ),
          Flexible(
            child: Container(
              child: Center(
                child: charts.BarChart(series, animate: true)
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget graphArea(int n, double width) {
    return FutureBuilder(
      future: n == 0 ? _expiredItems : _stockItems,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          if(snapshot.data == null || snapshot.data.length == 0) {
            return Center(child: Text('Add items for analytics'),);
          }
          if(snapshot.hasData) {
            //make the chart
            HashMap freqMap = new HashMap<String, int>();
            for(var item in snapshot.data) {
              String itemName = item.getName();
              if(!freqMap.containsKey(itemName)) {
                freqMap[itemName] = 1;
              }
              else {
                freqMap[itemName] = freqMap[itemName] + 1;
              }
            }
            //convert frequency map
            List<ChartItem> chartItems = new List<ChartItem>();
            for(var key in freqMap.keys) {
              ChartItem item = new ChartItem(key, freqMap[key]);
              chartItems.add(item);
            }
            return createGraph(n, width, chartItems); 
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xff5c39f8))));
        }
      },
    );
  }
  
  displayUI(var width) {
    refreshGraphs();
    return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[graphArea(0, width), graphArea(1, width)],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int idx) {
                  return ListTile(
                    title: Text((idx + 1).toString() + "  some info"),
                  );
                },
                separatorBuilder: (BuildContext context, int idx) => Divider(),
                itemCount: 8),
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5c29f8),
        title: Text("Analytics"),
      ),
      body: displayUI(width),
    );
  }
}

class ChartItem {
  String itemName;
  int frequency;

  ChartItem(this.itemName, this.frequency);
}
