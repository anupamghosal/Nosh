import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'database/stockItem.dart';
import 'database/expiredItem.dart';

class Analysis extends StatefulWidget {
  var exItems, stItems;

  Analysis(this.exItems, this.stItems);
  @override
  _AnalysisState createState() => _AnalysisState(exItems, stItems);
}

class _AnalysisState extends State<Analysis> {
  var exItems, stItems;
  _AnalysisState(this.exItems, this.stItems);
  DBhelper _dBhelper;
  Future<List<StockItem>> _stockItems;
  Future<List<ExpiredItem>> _expiredItems;

  List<StockItem> sitems;
  List<ExpiredItem> eitems;
  var displayItems = [];

  var listItems;

  @override
  void initState() {
    super.initState();
    _dBhelper = new DBhelper();
  }

  refreshGraphs() async {
    setState(() {
      _stockItems = _dBhelper.getItemsFromStock();
      _expiredItems = _dBhelper.getExpiredItems();

      if (exItems.length != 0)
        for (var item in exItems) {
          displayItems = stItems
              .where((a) => a
                  .getName()
                  .toLowerCase()
                  .contains(item.getName().toLowerCase()))
              .toList();
        }

      displayItems = displayItems.toSet().toList();
    });
  }

  createGraph(int n, double width, List<ChartItem> data) {
    List<String> headings = ["Expiry trend", "Buying trend"];

    List<charts.Series<ChartItem, String>> series = [
      charts.Series(
        id: "Subscribers",
        data: data,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Color(0xff5c39f8).withOpacity(0.9)),
        domainFn: (ChartItem items, _) => items.itemName.length > 7
            ? items.itemName.substring(0, 5) + '...'
            : items.itemName,
        measureFn: (ChartItem items, _) => items.frequency,
      )
    ];

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          child: Text(
            headings[n],
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Container(
            child: Center(
              child: charts.BarChart(
                series,
                animate: true,
                animationDuration: Duration(milliseconds: 500),
                defaultRenderer: charts.BarRendererConfig(
                    cornerStrategy: charts.ConstCornerStrategy(4)),
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    minimumPaddingBetweenLabelsPx: 2,
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget graphArea(int n, double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey[200], blurRadius: 20.0, offset: Offset(5, 5))
        ],
      ),
      width: width - 50,
      height: width / 2.2 + 10,
      padding: EdgeInsets.all(8),
      child: FutureBuilder(
        future: n == 0 ? _expiredItems : _stockItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null || snapshot.data.length == 0) {
              if (n == 1)
                return Center(
                  child: Text(''),
                );

              return Column(
                children: <Widget>[
                  Text(
                    "Expiry trend",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            '0',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        Text('Food items\n wasted')
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Good Job!',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Color(0xff5c39f8))),
                  )
                ],
              );
            }
            if (snapshot.hasData) {
              //make the chart
              HashMap freqMap = new HashMap<String, int>();
              for (var i = 0; i <= 6; i++) {
                String itemName = snapshot.data[i].getName();
                if (!freqMap.containsKey(itemName)) {
                  freqMap[itemName] = 1;
                } else {
                  freqMap[itemName] = freqMap[itemName] + 1;
                }
              }
              //convert frequency map
              List<ChartItem> chartItems = new List<ChartItem>();
              for (var key in freqMap.keys) {
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
      ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              stItems != 0 ? graphArea(0, width) : SizedBox(),
              SizedBox(
                height: 30,
              ),
              stItems.length != 0 ? graphArea(1, width) : SizedBox()
            ],
          ),
        ),
        displayItems.length != 0
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Text(
                      "Mind these products",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Center(
                    child: Text(
                      "You have a tendency to let them be expired",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (BuildContext context, int idx) {
                          if (listItems.length == 0)
                            return Container(
                              height: 0,
                              width: 0,
                            );
                          else
                            return ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20),
                              title: Text((idx + 1).toString() +
                                  ". " +
                                  displayItems[idx].getName()),
                            );
                        },
                        separatorBuilder: (BuildContext context, int idx) =>
                            Divider(),
                        itemCount: displayItems.length),
                  )
                ],
              )
            : Expanded(
                child: Center(
                  child: Text(
                      "You are doing great with \n   managing your food!",
                      style: TextStyle(fontSize: 15, letterSpacing: 0.5)),
                ),
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
        title: Text("Expiration analytics"),
      ),
      body: stItems.length == 0 && exItems.length == 0
          ? Center(
              child: Text(
                'Not enough data for me to calculate analytics',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : displayUI(width),
    );
  }
}

class ChartItem {
  String itemName;
  int frequency;
  ChartItem(this.itemName, this.frequency);
}
