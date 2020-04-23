import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import './main.dart';

class OnBoardingPage extends StatefulWidget {
  bool welcome;
  OnBoardingPage(this.welcome);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState(welcome);
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  bool welcome;

  _OnBoardingPageState(this.welcome);

  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    if (welcome == false) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AppTabs()),
      );
    }
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName.png', width: 300.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 15.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 18.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Expiry Tracking",
          body: "Save food by tracking the expiries.",
          image: _buildImage('expiry_date'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Stock management",
          image: _buildImage('manage_stock'),
          bodyWidget: Column(
            children: <Widget>[
              Text("Stocked and categorized as per expiry dates."),
              SizedBox(
                height: 15,
              ),
              Wrap(
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  Text("  1 day to expire")
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Wrap(
                children: <Widget>[
                  Icon(
                    Icons.report_problem,
                    size: 18,
                    color: Colors.amber,
                  ),
                  Text("  less than 3 days to expire")
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Wrap(
                children: <Widget>[
                  Icon(
                    Icons.thumb_up,
                    size: 18,
                    color: Color(0xff5c39f8),
                  ),
                  Text("  good to go for atleast 3 days")
                ],
              ),
            ],
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Create shopping list",
          body: "Creating a shopping list to remind you what to buy.",
          image: _buildImage('shopping_cart'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get recipes",
          image: _buildImage('recipe'),
          bodyWidget: Column(
            children: <Widget>[
              Text("Get recipe suggestions from your stocked items."),
              SizedBox(
                height: 15,
              ),
              Wrap(
                children: <Widget>[
                  Text("Tap on ", style: bodyStyle),
                  Icon(
                    Icons.restaurant,
                    size: 18,
                    color: Color(0xff5c39f8),
                  ),
                  Text(" to get lovely recipes", style: bodyStyle),
                ],
              ),
            ],
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Smarter Purchases",
          body:
              "With nosh's expiration analytics, know which items you tend tolet expire.",
          image: _buildImage('charts'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Empowering UI design",
          body:
              "User empowering UI design. Long press items to reveal more options",
          image: _buildImage('ui'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Managing items",
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      Text("Tap on ", style: bodyStyle),
                      Icon(
                        Icons.edit,
                        size: 18,
                      ),
                      Text(" to edit a any item", style: bodyStyle),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Wrap(
                    children: <Widget>[
                      Text("Tap on ", style: bodyStyle),
                      Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      Text(" to delete an item", style: bodyStyle),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Wrap(
                    children: <Widget>[
                      Text("Tap on ", style: bodyStyle),
                      Icon(
                        Icons.add_shopping_cart,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      Text(" to add item to stocked", style: bodyStyle),
                    ],
                  )
                ],
              )
            ],
          ),
          image: _buildImage('managing'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Start saving today",
          body:
              "Start saving food today, and helping the world by not wasting some.",
          image: _buildImage('wasting'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.keyboard_arrow_right),
      done: const Text('Get started',
          style:
              TextStyle(fontWeight: FontWeight.w800, color: Color(0xff5c39f8))),
      dotsDecorator: const DotsDecorator(
        spacing: EdgeInsets.symmetric(horizontal: 4),
        size: Size(7.0, 7.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(16.0, 7.0),
        activeColor: Color(0xff5c39f8),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
