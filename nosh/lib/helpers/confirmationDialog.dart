import 'package:flutter/material.dart';

getSurity(context) async {
  bool response = false;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            titlePadding: EdgeInsets.symmetric(horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.delete_forever,
                              color: Colors.red, size: 35),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Are you sure?",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    )),
                Text(
                  'Do you really want to delete this\nitem permanently?',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('Yes', style: TextStyle(color: Color(0xff5c39f8))),
                onPressed: () {
                  response = true;
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                  child: Text('No', style: TextStyle(color: Color(0xff5c39f8))),
                  onPressed: () {
                    response = false;
                    Navigator.of(context).pop();
                  })
            ]);
      });
  return response;
}
