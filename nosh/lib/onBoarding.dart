import 'package:flutter/material.dart';
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
    const bodyStyle = TextStyle(fontSize: 18.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

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
          body: "Stocked and categorized as per expiry dates",
          image: _buildImage('manage_stock'),
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
          body: "Get recipe suggestions from your stocked items.",
          image: _buildImage('recipe'),
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
                      Text("Click on ", style: bodyStyle),
                      Icon(Icons.edit),
                      Text(" to edit a any item", style: bodyStyle),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Wrap(
                    children: <Widget>[
                      Text("Click on ", style: bodyStyle),
                      Icon(
                        Icons.delete,
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
                      Text("Click on ", style: bodyStyle),
                      Icon(
                        Icons.add_shopping_cart,
                        color: Colors.grey[800],
                      ),
                      Text(" an item from to stocked", style: bodyStyle),
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
          title: "Empowering UI design",
          body:
              "User empowering UI design. Long press items to reveal more options",
          image: _buildImage('ui'),
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
      next: const Icon(Icons.arrow_forward),
      done: const Text('Get started',
          style:
              TextStyle(fontWeight: FontWeight.w800, color: Color(0xff5c39f8))),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeColor: Color(0xff5c39f8),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
