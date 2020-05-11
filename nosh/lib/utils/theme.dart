import 'package:flutter/material.dart';

ThemeData noshTheme() {
  TextTheme myText(TextTheme base) {
    return base.copyWith(
        headline: base.headline.copyWith(fontSize: 16, color: Colors.black),
        title: base.title.copyWith(fontSize: 16, color: Colors.grey[800]));
  }

  final ThemeData base = ThemeData.light();
  return base.copyWith(
      textTheme: myText(base.textTheme),
      highlightColor: Colors.grey[300], //Color(0xff5c39f8).withAlpha(10),
      iconTheme: IconThemeData(size: 22),
      appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.grey[600])),
      primaryColor: Color(0xff5c39f8),
      accentColor: Colors.grey[300],
      scaffoldBackgroundColor: Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white, foregroundColor: Color(0xff5c39f8)));
}
