import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PageHeading extends StatelessWidget {
  final String heading;
  PageHeading(this.heading);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Text(
        heading,
        style: TextStyle(
            fontSize: 36,
            color: Colors.grey[500],
            fontWeight: FontWeight.w300,
            letterSpacing: 1),
      ),
    );
  }
}

class SliverHeading implements SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final String heading;
  final Widget trailing;

  SliverHeading(
      {this.minExtent, this.maxExtent, @required this.heading, this.trailing});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[PageHeading(heading), trailing],
          ),
        ));
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
