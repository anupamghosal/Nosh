import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class InfoPanel extends StatelessWidget {
  final items;
  InfoPanel(this.items);
  final List<Color> panelColor = [
    Colors.red[700],
    Colors.amber[700],
    Color(0xFF5C39F8)
  ];

  final List<Icon> panelIcon = [
    Icon(Icons.error_outline, color: Colors.red[500], size: 20),
    Icon(Icons.report_problem, color: Colors.amber[700], size: 20),
    Icon(Icons.thumb_up, color: Color(0xFF5C39F8), size: 20),
  ];

  int diffInDays(DateTime date) {
    if (date.month == DateTime.now().month && date.year == DateTime.now().year)
      return (date.day - DateTime.now().day);
    return 10;
  }

  Widget panel(int idx) {
    int count = 0;

    if (idx == 0)
      count = items
          .where((a) => a.expiry != null)
          .where((b) => diffInDays(b.expiry) == 0)
          .toList()
          .length;

    if (idx == 1)
      count = items
          .where((a) => a.expiry != null)
          .where((b) => diffInDays(b.expiry) <= 2)
          .where((c) => diffInDays(c.expiry) > 0)
          .toList()
          .length;

    if (idx == 2)
      count = items
          .where((a) => a.expiry != null)
          .where((b) => diffInDays(b.expiry) > 2)
          .toList()
          .length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: 40.0,
      width: 75.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: panelColor[idx], width: .5)),
      child: Row(
        children: <Widget>[
          panelIcon[idx],
          Text(count.toString(),
              style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                  fontSize: 16))
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }

  Widget totalPanel() {
    return Container(
      height: 40.0,
      padding: EdgeInsets.only(right: 12, left: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: .5)),
      child: Row(
        children: <Widget>[
          Transform.rotate(
              angle: -3.1415 / 2,
              child: Text("TOTAL",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w600))),
          Text(
            items.length.toString(),
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.w300, color: Colors.black),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[totalPanel(), panel(0), panel(1), panel(2)],
      ),
    );
  }
}

class InfoBar implements SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final items;

  InfoBar({this.minExtent, this.maxExtent, this.items});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: Colors.white, child: Center(child: InfoPanel(items)));
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}
