import 'package:flutter/material.dart';
import 'package:nosh/models/StoredItem.dart';
import 'package:nosh/pages/recipeCarosel.dart';
import 'package:nosh/utils/slide.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:nosh/widgets/sliverVerticalSpace.dart';
import 'package:nosh/widgets/emptyMessage.dart';
import '../helpers/errorMessageSnackBar.dart';
import '../helpers/checkConnection.dart';

class RecipePanel extends StatefulWidget {
  final List<Item> items;

  RecipePanel(this.items);

  @override
  _RecipePanelState createState() => _RecipePanelState();
}

class _RecipePanelState extends State<RecipePanel> {
  final _selectedFood = Set<String>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  buildTile(name, alreadySelected) {
    return Container(
      decoration: BoxDecoration(
          color: alreadySelected ? Colors.grey[100] : null,
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        onTap: () => setState(() {
          if (alreadySelected)
            _selectedFood.remove(name);
          else
            _selectedFood.add(name);
        }),
        leading: Icon(
          Icons.check,
          color: alreadySelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
        ),
        title: Text(
          name,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  buildGetRecipeButton() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
      child: RaisedButton(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
          child: Text(_selectedFood.isNotEmpty
              ? 'Get Recipes'
              : 'Select items to continue'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Theme.of(context).primaryColor,
        disabledColor: Colors.white,
        disabledTextColor: Colors.black,
        textColor: Colors.white,
        onPressed: _selectedFood.isNotEmpty
            ? () async {
                String query = "";
                if (!await isConnected()) {
                  scaffoldKey.currentState.showSnackBar(
                      showError("Internet connection not established!"));
                  return;
                }
                _selectedFood.forEach((item) => query += ",$item");
                Navigator.push(context,
                    Slide(page: RecipeCarosel(query: query.substring(1))));
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: PageHeading('Recipe Console'),
          ),
          VerticalSpace(30),
          widget.items.length == 0
              ? EmptyText('You need items in inventory\nto access this feature',
                  'assets/recipe.png')
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int idx) {
                  final name = widget.items[idx].name;
                  final alreadySelected = _selectedFood.contains(name);
                  return buildTile(name, alreadySelected);
                }, childCount: widget.items.length)),
        ],
      ),
      bottomNavigationBar:
          widget.items.length == 0 ? null : buildGetRecipeButton(),
    );
  }
}
