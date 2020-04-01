import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import './util/slide.dart';
import './models/Recipe.dart';

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
    print('started'); // delete karr dena
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
    print('done'); // delete karr dena

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context, Slide(page: snapshot.data[index]));
                      },
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(snapshot.data[index].picture),
                      ),
                      title: Text(snapshot.data[index].title),
                    );
                  },
                );
              }
            },
          ),
        ));
  }
}

// recipe detail

class RecipeDetail extends StatelessWidget {
  final Recipe recipe;

  RecipeDetail(this.recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5c30f8),
        title: Text(recipe.title),
      ),
    );
  }
}
