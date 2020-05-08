import 'package:flutter/material.dart';
import 'package:nosh/models/Recipe.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetail extends StatelessWidget {
  final Recipe recipe;

  RecipeDetail(this.recipe);

  getIngredients() {
    final ingredientsString = recipe.ingredients;
    List ingredients = ingredientsString.split(", ");
    ingredients = ingredients.toSet().toList();
    return ingredients;
  }

  makeSentenceCase(String string) {
    return string[0].toUpperCase() + string.substring(1);
  }

  buildIngredients() {
    final ingredients = getIngredients();
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (BuildContext context, int idx) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.local_pizza),
                SizedBox(width: 10),
                Text(makeSentenceCase(ingredients[idx]))
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              child: PageHeading('Enjoy!')),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  backgroundImage: NetworkImage(recipe.picture),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Main ingredients',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: buildIngredients(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
        child: RaisedButton(
          onPressed: () => launch(recipe.recipeUri),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
            child: Text("View full recipe"),
          ),
        ),
      ),
    );
  }
}
