import 'package:flutter/material.dart';

class ListEndLine extends StatelessWidget {
  final int size;
  ListEndLine(this.size);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: size > 0
          ? Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 80),
              child: Divider(),
            )
          : SizedBox(),
    );
  }
}
