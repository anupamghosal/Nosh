import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nosh/helpers/confirmationDialog.dart';
import 'package:nosh/helpers/errorMessageSnackBar.dart';
import 'package:nosh/models/ShoppingItem.dart';
import 'package:nosh/utils/searcher.dart';
import 'package:nosh/widgets/emptyMessage.dart';
import 'package:nosh/widgets/inputModal.dart';
import 'package:nosh/widgets/listEndLine.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:nosh/widgets/sliverVerticalSpace.dart';

class Shopping extends StatefulWidget {
  final List<ShoppingItem> shopItems;
  final vm;

  const Shopping(this.shopItems, this.vm);
  @override
  _ShoppingState createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  bool _longPressEventActive = false;
  var navToTileIndex;

  ScrollController _scrollController = ScrollController();

  var searchResult;

  navigateToItem(var result) {
    setState(() => navToTileIndex = widget.shopItems.indexOf(result));

    // if (navToTileIndex > 6)
    _scrollController.animateTo((navToTileIndex) * 60.0,
        duration: Duration(seconds: 1), curve: Curves.easeOut);
    Timer(Duration(seconds: 3), () => setState(() => navToTileIndex = null));
  }

  Widget buildTrailing(ShoppingItem item) {
    return AnimatedSwitcher(
      transitionBuilder: (widget, animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
              .animate(animation),
          child: widget,
        );
      },
      duration: Duration(milliseconds: 200),
      child: _longPressEventActive
          ? Wrap(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_shopping_cart,
                      color: Colors.grey[800], size: 22),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            InputModal("MOVE_TO_STOCKED", widget.vm, item));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: Colors.red, size: 22),
                  onPressed: () async {
                    var userIsSure = await getSurity(context);
                    if (userIsSure) {
                      widget.vm.onRemoveShopItem(item);
                      Scaffold.of(context)
                          .showSnackBar(showError('Item has been deleted'));
                    }
                  },
                )
              ],
            )
          : SizedBox(),
    );
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

  Widget searchButton() {
    return IconButton(
      onPressed: () async {
        searchResult = await showSearch(
            context: context, delegate: SearchItems(widget.shopItems));
        if (searchResult != null) navigateToItem(searchResult);
      },
      icon: Icon(Icons.search),
    );
  }

  Widget editButton(ShoppingItem shopItem) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                InputModal("UPDATE_SHOP", widget.vm, shopItem));
      },
      icon: Icon(
        Icons.edit,
        size: 22,
      ),
    );
  }

  Widget buildCheckMark(ShoppingItem shopItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(
        Icons.check,
        color: shopItem.isChecked
            ? Theme.of(context).primaryColor
            : Colors.grey[300],
      ),
    );
  }

  Widget buildLeading(ShoppingItem shopItem) {
    return _longPressEventActive && widget.shopItems.length != 0
        ? editButton(shopItem)
        : buildCheckMark(shopItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scrollbar(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 8.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: <Widget>[
          //         PageHeading("Shopping List"),
          //         _longPressEventActive ? doneButton() : searchButton()
          //       ],
          //     ),
          //   ),
          // ),
          SliverPersistentHeader(
            floating: true,
            delegate: SliverHeading(
                heading: 'Shopping List',
                minExtent: 120,
                maxExtent: 120,
                trailing:
                    _longPressEventActive ? doneButton() : searchButton()),
          ),
          VerticalSpace(30),
          widget.shopItems.length == 0
              ? EmptyText(
                  'No items in shopping list', 'assets/shopping_cart.png')
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int idx) {
                    final shopItem = widget.shopItems[idx];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                          color: navToTileIndex != idx
                              ? shopItem.isChecked ? Colors.grey[100] : null
                              : Theme.of(context).primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: buildLeading(shopItem),
                        title: Row(
                          children: <Widget>[
                            Flexible(
                              flex: 7,
                              child: Text(
                                widget.shopItems[idx].name,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            widget.shopItems[idx].quantity != ''
                                ? Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    margin: EdgeInsets.only(left: 20.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 3.0),
                                    child: Text(
                                      widget.shopItems[idx].quantity,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        trailing: buildTrailing(widget.shopItems[idx]),
                        onTap: _longPressEventActive
                            ? null
                            : () => widget.vm.onUpdateShoppingItem(shopItem
                                .copyWith(isChecked: !shopItem.isChecked)),
                        onLongPress: () => setState(
                          () => _longPressEventActive = !_longPressEventActive,
                        ),
                      ),
                    );
                  }, childCount: widget.shopItems.length),
                ),
          ListEndLine(widget.shopItems.length)
        ],
      ),
    ));
  }
}
