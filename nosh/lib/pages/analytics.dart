import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:nosh/models/StoredItem.dart';
import 'package:nosh/widgets/emptyMessage.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:nosh/widgets/sliverVerticalSpace.dart';

class Analysis extends StatefulWidget {
  final List<Item> stockItems;
  final List<Item> expiredItems;

  const Analysis(this.stockItems, this.expiredItems);

  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  List<Item> stockItems;
  List<Item> expiredItems;
  List<String> commons = [];

  @override
  void initState() {
    super.initState();
    stockItems = List.from(widget.stockItems.reversed);
    expiredItems = List.from(widget.expiredItems.reversed);
    expiredItems.forEach((a) {
      for (var item in stockItems)
        if (item.name == a.name && !commons.contains(a.name))
          commons.add(a.name);
    });
  }

  graph(int n, double width, List<ChartItem> data) {
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
                    cornerStrategy: charts.ConstCornerStrategy(6)),
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

  buildGraph(int graphId, var items, double width) {
    HashMap freqMap = new HashMap<String, int>();

    for (var i = 0; i <= items.length - 1; i++) {
      String itemName = items[i].name;
      if (!freqMap.containsKey(itemName)) {
        freqMap[itemName] = 1;
      } else {
        freqMap[itemName] = freqMap[itemName] + 1;
      }
    }
    //convert frequency map
    List<ChartItem> chartItems = new List<ChartItem>();

    int i = 0;
    for (var key in freqMap.keys) {
      i++;
      ChartItem item = new ChartItem(key, freqMap[key]);
      chartItems.add(item);
      if (i == 6) break; // using only 6 items for space constrains
    }
    return graph(graphId, width, chartItems);
  }

  buildGraphContainer(int graphId, double width, var items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: width / 2.2,
      width: width,
      decoration: BoxDecoration(
          color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
      child: buildGraph(graphId, items, width),
    );
  }

  buildDisplayMessage() {
    if (stockItems.length == 0 && expiredItems.length == 0)
      return EmptyText(
          "Not enough data to calculate analytics", "assets/charts.png");
    if (expiredItems.length != 0)
      return EmptyText(
          "Seems like you have some expiry items\nLet's be cautious from now",
          "assets/expiry_date.png");
    if (expiredItems.length == 0)
      return EmptyText(
          "No expired items!\nThat is some great buying habit you have",
          "assets/congrats.png");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: PageHeading('Weekly Analytics'),
            ),
            VerticalSpace(40),
            SliverToBoxAdapter(
              child: expiredItems.length != 0
                  ? buildGraphContainer(0, width, expiredItems)
                  : SizedBox(),
            ),
            SliverToBoxAdapter(
              child: stockItems.length != 0
                  ? buildGraphContainer(1, width, stockItems)
                  : SizedBox(),
            ),
            SliverToBoxAdapter(
              child: commons.length != 0
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Text(
                        'Be Cautious of these',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    )
                  : null,
            ),
            commons.length == 0
                ? buildDisplayMessage()
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int idx) {
                      return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                          title: Wrap(
                            children: <Widget>[
                              Icon(Icons.alarm),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(commons[idx]),
                              )
                            ],
                          ));
                    }, childCount: commons.length),
                  )
          ],
        ));
  }
}

class ChartItem {
  String itemName;
  int frequency;
  ChartItem(this.itemName, this.frequency);
}
