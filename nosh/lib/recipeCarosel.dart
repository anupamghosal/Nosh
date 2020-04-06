import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import './util/slide.dart';
import './models/Recipe.dart';
import './recipeDetails.dart';

class RecipeCarosel extends StatefulWidget {
  String query;
  RecipeCarosel({this.query});

  @override
  RecipeCaroselState createState() => RecipeCaroselState(query);
}

class RecipeCaroselState extends State<RecipeCarosel> {
  String query;
  RecipeCaroselState(this.query);

  Future<List<Recipe>> getRecipes() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Recipes'),
          backgroundColor: Color(0xff5c39f8),
        ),
        body: Container(
          child: FutureBuilder(
            future: getRecipes(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Center(
                        child: new CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xff5c39f8)),
                    )),
                  ),
                );
              } else {
                if (snapshot.data.length == 0) {
                  return Center(
                    child: Text("No recipes found for selected items",
                        style: TextStyle(color: Colors.grey[600])),
                  );
                } else {
                  return Theme(
                    data: ThemeData(accentColor: Color(0xff5c39f8)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ListView.builder(
                        itemExtent: 80.0,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  Slide(
                                      page:
                                          RecipeDetail(snapshot.data[index])));
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              radius: 30.0,
                              backgroundImage:
                                  NetworkImage(snapshot.data[index].picture),
                            ),
                            title: Text(snapshot.data[index].title),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        },
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ));
  }
}

// recipe detail
