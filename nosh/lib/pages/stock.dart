import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nosh/helpers/errorMessageSnackBar.dart';
import 'package:nosh/models/StoredItem.dart';
import 'package:nosh/pages/recipeSelectItems.dart';
import 'package:nosh/utils/searcher.dart';
import 'package:nosh/utils/slide.dart';
import 'package:nosh/widgets/emptyMessage.dart';
import 'package:nosh/helpers/confirmationDialog.dart';
import 'package:nosh/widgets/inputModal.dart';
import 'package:nosh/widgets/listEndLine.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:intl/intl.dart';
import '../widgets/infoBar.dart';
import 'dart:io';

class Stock extends StatefulWidget {
  final List<Item> items;
  final vm;
  final bool isFirstBoot;

  Stock(this.items, this.vm, this.isFirstBoot);
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  var sortedItems;
  var searchResult;
  var navToTileIndex;
  bool _longPressEventActive = false;
  ScrollController _scrollController = ScrollController();

  int diffInDays(DateTime date) {
    if (date.month == DateTime.now().month && date.year == DateTime.now().year)
      return (date.day - DateTime.now().day);
    return 10;
  }

  List<Item> sortByDate() {
    List<Item> itemsWithExpiry =
        widget.items.where((a) => a.expiry != null).toList();
    itemsWithExpiry.sort((a, b) => a.expiry.compareTo(b.expiry));
    return (widget.items.where((a) => a.expiry == null).toList()
      ..addAll(itemsWithExpiry));
  }

  Widget buildLeading(Item item) {
    return AnimatedCrossFade(
      crossFadeState: _longPressEventActive
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 200),
      firstChild: Container(
        height: 60.0,
        key: ValueKey(1),
        child: Wrap(children: <Widget>[
          IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Icon(Icons.edit, size: 22),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      InputModal("UPDATE_STOCKED", widget.vm, item));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            padding: EdgeInsets.all(0.0),
            onPressed: () async {
              var userIsSure = await getSurity(context);
              if (userIsSure) {
                widget.vm.onRemoveItem(item);
                Scaffold.of(context)
                    .showSnackBar(showError('Item has been deleted'));
              }
            },
          )
        ]),
      ),
      secondChild: Container(
        key: ValueKey(2),
        child: CircleAvatar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey[300],
          radius: 30,
          backgroundImage: selectImageType(item.imageUri),
          child: selectImageType(item.imageUri) == null
              ? Icon(
                  Icons.fastfood,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }

  selectImageType(String link) {
    if (link == '') return null;
    if (link.startsWith('https'))
      return NetworkImage(link);
    else
      return FileImage(File(link));
  }

  Widget expiryDate(DateTime expiry) {
    return Text(
      expiry == null
          ? 'No expiry date'
          : DateFormat('yyyy-MM-dd').format(expiry).toString(),
    );
  }

  buildWarningIcon(DateTime expiry) {
    if (expiry != null) {
      int daysLeft = diffInDays(expiry);
      if (daysLeft == 0)
        return Icon(Icons.error_outline, color: Colors.red[700]);
      if (daysLeft <= 2)
        return Icon(Icons.report_problem, color: Colors.amber[700]);
      return Icon(Icons.thumb_up, color: Colors.transparent);
    }
  }

  navigateToItem(var result) {
    setState(() => navToTileIndex = sortedItems.indexOf(result));
    if (navToTileIndex > 3)
      _scrollController.animateTo((navToTileIndex) * 80.0,
          duration: Duration(seconds: 1), curve: Curves.easeOut);
    Timer(Duration(seconds: 3), () => setState(() => navToTileIndex = null));
  }

  Widget doneButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        height: 30,
        width: 75,
        child: OutlineButton(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text(
            'Done',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
          onPressed: () => setState(
            () => _longPressEventActive = false,
          ),
        ),
      ),
    );
  }

  Widget searchAndRecipeButton() {
    return Wrap(
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.restaurant,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Navigator.push(context, Slide(page: RecipePanel(sortedItems)));
          },
        ),
        IconButton(
          onPressed: () async {
            searchResult = await showSearch(
                context: context, delegate: SearchItems(sortedItems));
            if (searchResult != null) navigateToItem(searchResult);
          },
          icon: Icon(Icons.search),
        )
      ],
    );
  }

  buildEmptyMessage() {
    if (widget.isFirstBoot)
      return EmptyText(
          'Add food items and track their expiry', 'assets/manage_stock.png');
    return EmptyText(
        "You don't have any items\n Use our Shopping list to plan your shopping",
        "assets/go_shopping.png");
  }

  @override
  Widget build(BuildContext context) {
    sortedItems = sortByDate();
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  PageHeading("Stocked"),
                  _longPressEventActive && widget.items.length != 0
                      ? doneButton()
                      : searchAndRecipeButton()
                ],
              ),
            ),
          ),
          widget.items.length == 0
              ? SliverToBoxAdapter()
              : SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: InfoBar(
                      minExtent: 100, maxExtent: 120, items: sortedItems)),
          sortedItems.length == 0
              ? buildEmptyMessage()
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int idx) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: navToTileIndex != idx
                              ? null
                              : Theme.of(context).primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        onLongPress: () => setState(() =>
                            _longPressEventActive = !_longPressEventActive),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: buildLeading(sortedItems[idx]),
                        title: Row(
                          children: <Widget>[
                            Flexible(
                              flex: 6,
                              child: Text(
                                sortedItems[idx].name,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            sortedItems[idx].quantity != ''
                                ? Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    margin: EdgeInsets.only(left: 20.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 3.0),
                                    child: Text(
                                      sortedItems[idx].quantity,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                        subtitle: expiryDate(sortedItems[idx].expiry),
                        trailing: buildWarningIcon(sortedItems[idx].expiry),
                      ),
                    );
                  }, childCount: sortedItems.length),
                ),
          ListEndLine(sortedItems.length)
        ],
      ),
    );
  }
}
