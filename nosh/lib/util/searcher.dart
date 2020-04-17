import 'dart:async';

import 'package:flutter/material.dart';

import '../database/stockItem.dart';

class searchItems extends SearchDelegate {
  final List<StockItem> items;

  searchItems(this.items);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
    ;
  }

  @override
  Widget buildResults(BuildContext context) {
    final reults =
        items.where((a) => a.getName().toLowerCase().contains(query));
    return ListView(
      children: reults
          .map<ListTile>((a) => ListTile(
                leading: Icon(Icons.fastfood),
                title: Text(
                  a.getName(),
                ),
                subtitle: Text(
                  a.getExpiryDate() == ""
                      ? "No expiry mentioned"
                      : a.getExpiryDate().toString(),
                ),
                onTap: () => close(context, a),
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        items.where((a) => a.getName().toLowerCase().contains(query));
    return ListView(
      children: suggestions
          .map<ListTile>((a) => ListTile(
                title: Text(
                  a.getName(),
                  style: TextStyle(color: Colors.grey[800]),
                ),
                subtitle: Text(
                  a.getExpiryDate() == ""
                      ? "No expiry mentioned"
                      : a.getExpiryDate().toString(),
                ),
                onTap: () => close(context, a),
              ))
          .toList(),
    );
  }
}
