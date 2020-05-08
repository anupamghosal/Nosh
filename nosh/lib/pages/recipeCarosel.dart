import 'package:flutter/material.dart';
import 'package:nosh/helpers/getrecipesFromApi.dart';
import 'package:nosh/pages/recipeDetails.dart';
import 'package:nosh/utils/slide.dart';
import 'package:nosh/widgets/pageHeading.dart';
import 'package:nosh/widgets/sliverVerticalSpace.dart';
import 'package:nosh/widgets/emptyMessage.dart';

class RecipeCarosel extends StatelessWidget {
  final query;
  RecipeCarosel({this.query});

  Widget buildList(AsyncSnapshot snapshot) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int idx) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: ListTile(
          onTap: () {
            Navigator.push(
                context, Slide(page: RecipeDetail(snapshot.data[idx])));
          },
          leading: CircleAvatar(
            backgroundColor: Colors.grey[100],
            radius: 30.0,
            backgroundImage: NetworkImage(snapshot.data[idx].picture),
          ),
          title: Text(snapshot.data[idx].title),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      );
    }, childCount: snapshot.data.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: PageHeading('Suggestions'),
            ),
            VerticalSpace(40),
            FutureBuilder(
              future: getRecipes(query),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null)
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor)),
                    ),
                  );
                else {
                  if (snapshot.data.length == 0)
                    return EmptyText('No recipes found for selected items',
                        'assets/recipe.png');
                  else
                    return buildList(snapshot);
                }
              },
            )
          ],
        ));
  }
}
