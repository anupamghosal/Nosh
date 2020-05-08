import 'package:flutter/material.dart';

class PageHeading extends StatelessWidget {
  final String heading;
  PageHeading(this.heading);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
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
