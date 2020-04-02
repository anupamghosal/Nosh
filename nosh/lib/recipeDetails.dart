import 'package:flutter/material.dart';
import 'models/Recipe.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetail extends StatelessWidget {
  final Recipe recipe;

  RecipeDetail(this.recipe);

  getIngredients() {
    final ingredientsString = recipe.ingredients;
    List ingredients = ingredientsString.split(",");
    return ingredients;
  }

  BuildIngredients() {
    final ingredients = getIngredients();
    return Theme(
      data: ThemeData(accentColor: Color(0xff5c39f8)),
      child: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (BuildContext context, int idx) {
          return ListTile(
            title: Text(ingredients[idx]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Color(0xff5c39f8),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                height: MediaQuery.of(context).size.width / 2.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image(
                    image: NetworkImage(recipe.picture),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
              recipe.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 30.0),
            ),
          ),
          Text(
            'Ingredients',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: BuildIngredients(),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: RaisedButton(
              onPressed: () {
                final url = recipe.recipeUri;
                launch(url);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: Color(0xff5c39f8),
              textColor: Colors.white,
              child: Text("View full recipe"),
            ),
          )
        ],
      ),
    );
  }
}
