import 'package:flutter/material.dart';
import 'database/listItem.dart';
import 'database/db_helper.dart';
import 'package:intl/intl.dart';
import 'database/stockItem.dart';
import 'database/expiredItem.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Future<List<ListItem>> _listItems;
  DBhelper _dBhelper;
  bool _longPressEventActive = false;
  final _selectedItems = Set<String>();

  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    _dBhelper = new DBhelper();
    refreshItems();
  }

  refreshItems() {
    setState(() {
      _listItems = _dBhelper.getItemsFromList();
    });
  }

  Future<List> createImageAndDateAlertDialog(BuildContext context) {
    DateTimePickerTheme dateTimePickerTheme = new DateTimePickerTheme(
        cancel: Text(""), confirm: Text(""), title: Text('Select Expiry Date'));
    DateTime date = null;
    File imageFile = null;
    bool enable = false;

    return showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: new AlertDialog(
                contentPadding: EdgeInsets.all(25.0),
                title: new Text('Add Item to Stock'),
                actions: <Widget>[
                  new MaterialButton(
                      child: new Text('Add Item to Stock',
                          style: TextStyle(color: Color(0xff5c39f8))),
                      onPressed: () {
                        //print(productName);
                        //print(date);
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          Navigator.of(context).pop(
                              [enable ? date : null, imageFile == null ? '' : imageFile.path]);
                        }
                      },
                      elevation: 5.0)
                ],
                content: new SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: new Column(children: <Widget>[
                      StatefulBuilder(
                        builder: (context, setState) {
                          //print(_imageFile.toString());
                          return Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.grey[100],
                                  radius: 50,
                                  child: imageFile == null
                                      ? Icon(
                                          Icons.fastfood,
                                          color: Colors.grey[900],
                                        )
                                      : null,
                                  backgroundImage: imageFile == null
                                      ? null
                                      : FileImage(imageFile),
                                ),
                                GestureDetector(
                                  child: CircleAvatar(
                                      backgroundColor: Color(0xff5c39f8),
                                      radius: 20,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      )),
                                  onTap: () {
                                    alertForSourceAndGetImage().then((img) {
                                      setState(() {
                                        imageFile = img;
                                      });
                                    });
                                  },
                                ),
                              ]);
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      StatefulBuilder(builder: (context, setState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text("Enter an expiry?"),
                                Checkbox(
                                  activeColor: Color(0xff5c39f8),
                                  value: enable,
                                  onChanged: (value) {
                                    setState(() {
                                      enable = value;
                                      print(enable);
                                    });
                                  },
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                                crossFadeState: enable
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: Duration(milliseconds: 300),
                                firstChild: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    AbsorbPointer(
                                        absorbing: !enable,
                                        child: DatePickerWidget(
                                          minDateTime: DateTime(2018),
                                          maxDateTime: DateTime(2030),
                                          initialDateTime: date,
                                          locale:
                                              DATETIME_PICKER_LOCALE_DEFAULT,
                                          pickerTheme: dateTimePickerTheme,
                                          onChange: (dateTime, index) {
                                            date = dateTime;
                                          },
                                        ))
                                  ],
                                ),
                                secondChild: Text(""))
                          ],
                        );
                      })
                    ]),
                  ),
                )),
          );
        });
  }

  Future<File> alertForSourceAndGetImage() {
    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: Text('Select'),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.camera_alt),
                    SizedBox(width: 10),
                    Text('Camera')
                  ],
                ),
                onTap: () async {
                  var img = await openCamera();
                  Navigator.of(context).pop(img);
                },
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.album),
                    SizedBox(width: 10),
                    Text('Gallery')
                  ],
                ),
                onTap: () async {
                  var img = await openGallery();
                  Navigator.of(context).pop(img);
                },
              )
            ])),
          );
        });
  }

  openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var cropped_image = await ImageCropper.cropImage(sourcePath: image.path);
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    String file = cropped_image.toString();
    String fileName =
        file.substring(file.lastIndexOf('/') + 1, file.length - 1);
    print(fileName);
    var cropped_saved_img = await cropped_image.copy('$path/' + fileName);
    return cropped_saved_img;
  }

  openCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    var cropped_image = await ImageCropper.cropImage(sourcePath: image.path);
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    String file = cropped_image.toString();
    String fileName =
        file.substring(file.lastIndexOf('/') + 1, file.length - 1);
    print(fileName);
    var cropped_saved_img = await cropped_image.copy('$path/' + fileName);
    return cropped_saved_img;
  }

  createListUI(List<ListItem> items) {
    return new ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, builder) {
        return new Divider();
      },
      itemBuilder: (context, index) {
        final name = items[index].getName();
        final alreadySelected = _selectedItems.contains(name);
        return ListTile(
            onTap: () {
              setState(() {
                if (alreadySelected) {
                  _selectedItems.remove(name);
                } else {
                  _selectedItems.add(name);
                }
              });
            },
            onLongPress: () {
              setState(() {
                _longPressEventActive = true;
              });
            },
            leading: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: _longPressEventActive
                    ? new IconButton(
                        icon: new Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          createAlertDialog(context, false,
                                  name: items[index].getName(), initQuantity: items[index].getQuantity())
                              .then((onValue) {
                            if (onValue != null) {
                              items[index].setName(onValue[0]);
                              items[index].setQuantity(onValue[1]);
                              _dBhelper.updateItemFromList(items[index]);
                              refreshItems();
                            }
                          });
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(
                          alreadySelected
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: alreadySelected ? Color(0xff5c39f8) : null,
                        ),
                      )),
            title: new Text(items[index].getName() + '  ' + items[index].getQuantity()),
            trailing: AnimatedSwitcher(
              transitionBuilder: (widget, animation) {
                return SlideTransition(
                  position:
                      Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
                          .animate(animation),
                  child: widget,
                );
              },
              duration: Duration(milliseconds: 200),
              child: _longPressEventActive
                  ? new Wrap(
                      children: <Widget>[
                        new IconButton(
                          icon: new Icon(Icons.add_shopping_cart,
                              color: Colors.grey[800], size: 22),
                          onPressed: () {
                            //shift item : todo
                            createImageAndDateAlertDialog(context)
                                .then((onValue) {
                              if (onValue != null) {
                                if (onValue[0] != null) {
                                  String date = new DateFormat('yyyy-MM-dd')
                                      .format(onValue[0])
                                      .toString();
                                  DateTime now = new DateTime.now();
                                  now = new DateTime(
                                      now.year, now.month, now.day);
                                  int daysLeft = DateTime.parse(date)
                                      .difference(now)
                                      .inDays;
                                  if (daysLeft < 0) {
                                    ExpiredItem item = new ExpiredItem(
                                        items[index].getName(),
                                        date,
                                        onValue[1], items[index].getQuantity());
                                    _dBhelper.saveExpiredItem(item);
                                  } else {
                                    StockItem item = new StockItem(
                                        items[index].getName(),
                                        date,
                                        onValue[1], items[index].getQuantity());
                                    _dBhelper.saveToStock(item);
                                  }
                                } else {
                                  StockItem item = new StockItem(
                                      items[index].getName(), '', onValue[1], items[index].getQuantity());
                                  _dBhelper.saveToStock(item);
                                }
                                _dBhelper
                                    .deleteItemFromList(items[index].getName());
                                refreshItems();
                              }
                            });
                          },
                        ),
                        new IconButton(
                          icon: new Icon(Icons.remove_circle_outline,
                              color: Colors.red, size: 22),
                          onPressed: () {
                            createDeleteAlert(context).then((onValue) {
                              if (onValue != null && onValue) {
                                _dBhelper
                                    .deleteItemFromList(items[index].getName());
                                refreshItems();
                              }
                            });
                          },
                        )
                      ],
                    )
                  : SizedBox(),
            ));
      },
    );
  }

  displayListUI() {
    // refreshItems();
    return FutureBuilder(
      future: _listItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //temporary remove later
          if (snapshot.data == null || snapshot.data.length == 0) {
            return new Center(
                child: new Text(
              'No items in shopping list',
              style: TextStyle(color: Colors.grey[600]),
            ));
            //print('no data was there');
          }
          if (snapshot.hasData) {
            //create ListUI
            return createListUI(snapshot.data);
            //print(snapshot.data[0].NAME);
          }
        } else {
          return new Center(child: new CircularProgressIndicator());
        }
      },
    );
  }

  Future createDeleteAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
              title: new Text("Are you sure?"),
              actions: <Widget>[
                new MaterialButton(
                  child: new Text('Yes',
                      style: TextStyle(color: Color(0xff5c39f8))),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                new MaterialButton(
                    child: new Text('No',
                        style: TextStyle(color: Color(0xff5c39f8))),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    })
              ]);
        });
  }

  Future<List<String>> createAlertDialog(BuildContext context, bool state,
      {String name = '', String initQuantity = ''}) {
    TextEditingController controller = new TextEditingController();
    TextEditingController quantityController = new TextEditingController();
    String productName = '';
    String submitButtonText = 'Add Item';
    String quantity = '';
    bool enable = false;
    if (state == false) {
      productName = name;
      controller.text = productName;
      submitButtonText = 'Update Item';
    }
    if(initQuantity != '') {
      quantity = initQuantity;
      quantityController.text = quantity;
      enable = true;
    }

    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
              contentPadding: EdgeInsets.all(25.0),
              title: new Text(submitButtonText),
              actions: <Widget>[
                new MaterialButton(
                    child: new Text(
                      submitButtonText,
                      style: TextStyle(color: Color(0xFF5C39F8)),
                    ),
                    onPressed: () {
                      //print(productName);
                      //print(date);
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        Navigator.of(context).pop([productName, enable ? quantity : '']);
                      }
                    },
                    elevation: 5.0)
              ],
              content: new SingleChildScrollView(
                  child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a product name';
                      }
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Product name...',
                    ),
                    onChanged: (String value) {
                      productName = value;
                    },
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text("Enter Quantity?"),
                              Checkbox(
                                activeColor: Color(0xff5c39f8),
                                value: enable,
                                onChanged: (value) {
                                  setState(() {
                                    enable = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          enable ?
                          TextFormField(
                            controller: quantityController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Qty',
                            ),
                            onChanged: (String value) {
                              quantity = value;
                            }
                          ) : Container()
                        ]
                      );
                    },
                  )
                ]),
              )));
        });
    //preventing memory leaks
    controller.dispose();
    //calendarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: displayListUI(),
              ),
              _longPressEventActive
                  ? Container(
                      padding: EdgeInsets.all(20.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text("cancel"),
                        color: Color(0xff5c39f8),
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _longPressEventActive = false;
                          });
                        },
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
            child: Icon(Icons.add, color: Color(0xff5c39f8)),
            backgroundColor: Colors.white,
            onPressed: () {
              createAlertDialog(context, true).then((onValue) {
                if (onValue != null) {
                  ListItem item = new ListItem(onValue[0], onValue[1]);
                  _dBhelper.saveToList(item);
                  refreshItems();
                }
              });
            }));
  }
}
