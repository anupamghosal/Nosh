import 'package:flutter/material.dart';
import 'package:nosh/helpers/confirmationDialog.dart';
import 'package:nosh/models/StoredItem.dart';
import 'package:nosh/widgets/emptyMessage.dart';
import 'package:intl/intl.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:nosh/widgets/sliverVerticalSpace.dart';
import 'dart:io';

class Expired extends StatefulWidget {
  final List<Item> items;
  final Function removeItem;
  Expired(this.items, this.removeItem);
  @override
  _ExpiredState createState() => _ExpiredState();
}

class _ExpiredState extends State<Expired> {
  String itemsLength;
  String items = 'items';

  selectImageType(String link) {
    if (link == '') return null;
    if (link.startsWith('https'))
      return NetworkImage(link);
    else
      return FileImage(File(link));
  }

  @override
  Widget build(BuildContext context) {
    itemsLength = widget.items.length.toString();
    if (itemsLength.length < 2 && itemsLength != '0')
      itemsLength = '0$itemsLength';
    if (itemsLength == '1') items = 'item';

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                PageHeading("Expired"),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 20),
                  child: Text(
                    '$itemsLength  $items',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[700],
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
          VerticalSpace(30),
          widget.items.length == 0
              ? EmptyText(
                  "Great! There is no expired items", 'assets/wasting.png')
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int idx) {
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey[300],
                        radius: 30,
                        backgroundImage:
                            selectImageType(widget.items[idx].imageUri),
                        child:
                            selectImageType(widget.items[idx].imageUri) == null
                                ? Icon(
                                    Icons.fastfood,
                                    color: Colors.white,
                                  )
                                : null,
                      ),
                      title: Text(widget.items[idx].name),
                      subtitle: Text(widget.items[idx].expiry == null
                          ? 'No expiry date'
                          : DateFormat('yyyy-MM-dd')
                              .format(widget.items[idx].expiry)
                              .toString()),
                      trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            var userIsSure = await getSurity(context);
                            if (userIsSure)
                              widget.removeItem(widget.items[idx]);
                          }),
                    );
                  }, childCount: widget.items.length),
                ),
        ],
      ),
    );
  }
}
