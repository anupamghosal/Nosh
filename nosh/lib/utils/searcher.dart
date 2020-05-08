import 'package:flutter/material.dart';

class SearchItems extends SearchDelegate {
  final List<dynamic> items;

  SearchItems(this.items);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items.where((a) => a.name.toLowerCase().contains(query));
    return ListView(
      children: results
          .map<ListTile>((a) => ListTile(
                leading: Icon(Icons.fastfood),
                title: Text(a.name),
                onTap: () => close(context, a),
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (items.length == 0) return Center(child: Text(("No searchable item")));

    var suggestions = items.where((a) => a.name.toLowerCase().contains(query));
    if (query == '') suggestions = suggestions.take(5);
    return ListView(
      children: suggestions
          .map<ListTile>((a) => ListTile(
                leading: Icon(Icons.fastfood, color: Colors.grey[300]),
                title: Text(
                  a.name,
                  style: TextStyle(color: Colors.grey[800]),
                ),
                onTap: () => close(context, a),
              ))
          .toList(),
    );
  }
}
