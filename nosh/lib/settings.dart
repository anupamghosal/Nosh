import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './onBoarding.dart';

class Settings extends StatelessWidget {
  List<String> settings = ["Help", "Privacy policy", "About us"];

  final icons = [
    Icon(Icons.help),
    Icon(Icons.book),
    Icon(Icons.supervised_user_circle)
  ];

  List<String> urls = [
    "",
    "https://nosh.tech/privacy-policy.html",
    "https://nosh.tech/index.html#about"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5c39f8),
        title: Text("Settings"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: settings.length,
          separatorBuilder: (BuildContext context, int idx) => Divider(),
          itemBuilder: (BuildContext context, int idx) {
            return ListTile(
              leading: icons[idx],
              title: Text(settings[idx]),
              onTap: () {
                idx != 0
                    ? launch(urls[idx])
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OnBoardingPage(false)));
              },
            );
          },
        ),
      ),
    );
  }
}
