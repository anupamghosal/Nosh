import 'package:flutter/material.dart';

class EmptyText extends StatelessWidget {
  final String message;
  final String imageURI;
  EmptyText(this.message, this.imageURI);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          imageURI != ''
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Image.asset(
                    imageURI,
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                )
              : SizedBox(),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15))
        ],
      ),
    );
  }
}
