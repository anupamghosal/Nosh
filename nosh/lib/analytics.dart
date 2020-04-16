import 'package:flutter/material.dart';

class Analysis extends StatefulWidget {
  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  Widget graphArea(int n, double width) {
    List<String> headings = ["Expiry trend", "Buying trend"];

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
                child: Text(
                  "replace this text with the graph",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        ],
      ),
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
      body: Column(
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
      ),
    );
  }
}
