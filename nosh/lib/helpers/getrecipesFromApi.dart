import 'dart:convert';

import 'package:nosh/models/Recipe.dart';
import 'package:http/http.dart' as http;

Future<List<Recipe>> getRecipes(String query) async {
  String url = "https://recipe-puppy.p.rapidapi.com/?i=" + query;
  var response = await http.get(Uri.encodeFull(url), headers: {
    "x-rapidapi-host": "recipe-puppy.p.rapidapi.com",
    "x-rapidapi-key": "6abb9495d1mshbe05be219116a9cp1e3040jsne3f49a2b75b9",
    "Accept": "application/json"
  });

  var res = jsonDecode(response.body);
  res = res["results"].toList();
  List<Recipe> recipes = [];

  for (var r in res) {
    Recipe recipe = Recipe(r["title"].trim(), r["href"].trim(),
        r["ingredients"].trim(), r["thumbnail"].trim());
    recipes.add(recipe);
  }

  return recipes;
}
