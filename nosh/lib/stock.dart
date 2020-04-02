import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:nosh/database/expiredItem.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database/stockItem.dart';
import 'database/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class Stock extends StatefulWidget {
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> with WidgetsBindingObserver {
  File _imageFile;
  Future<List<StockItem>> _stockItems;
  List<StockItem> _currentStockItems;
  DBhelper _dBhelper;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String _barcode = '';

  final _formKey = GlobalKey<FormState>();
  bool _longPressedEventActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dBhelper = new DBhelper();
    initializeAndCancelNotifications();
    refreshItems();
  }

  initializeAndCancelNotifications() {
    if (flutterLocalNotificationsPlugin == null) {
      //initialize notifications
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin
          .initialize(initializationSettings)
          .then((value) {
        print('initialized');
        flutterLocalNotificationsPlugin.cancelAll().then((value) {
          print('cancelled all notifications');
        });
      });
    } else {
      flutterLocalNotificationsPlugin.cancelAll().then((value) {
        print('canceled all notifications');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        scheduleNotifications();
        break;
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.detached:
        print('detached');
        break;
      case AppLifecycleState.resumed:
        initializeAndCancelNotifications();
        break;
    }
  }

  scheduleNotifications() {
    print(_currentStockItems);
    if (_currentStockItems != null && _currentStockItems.length != 0) {
      for (StockItem item in _currentStockItems) {
        String date = item.getExpiryDate();
        DateTime now = new DateTime.now();
        now = new DateTime(now.year, now.month, now.day);
        int daysLeft = DateTime.parse(date).difference(now).inDays;
        if (daysLeft >= 0) {
          if (daysLeft == 0) {
            //red
            notifyWhenExpires(item);
          } else if (daysLeft <= 2) {
            //amber
            notifyWhenExpires(item);
            notifyWhenJustExpires(item);
          } else {
            //blue
            notifyWhenExpires(item);
            notifyWhenJustExpires(item);
            notifyWhenAboutToExpire(item);
          }
        }
      }
    }
  }

  notifyWhenExpires(StockItem item) {
    DateTime scheduledDate = DateTime.now().add(Duration(seconds: 5));
    //DateTime scheduledDate = DateTime.parse(item.getExpiryDate());
    String groupKey = scheduledDate.toString();
    groupKey = groupKey.substring(0, groupKey.indexOf('.'));
    String groupChannelId = 'Black';
    String groupChannelName = 'Expired Items';
    String groupChannelDescription =
        'This channel is associated with expired items';

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            groupChannelId, groupChannelName, groupChannelDescription,
            importance: Importance.Max,
            priority: Priority.High,
            groupKey: groupKey);
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);

    //schedule notification
    flutterLocalNotificationsPlugin
        .schedule(item.getId(), item.getName(), 'Expired', scheduledDate,
            notificationDetails)
        .then((value) {
      print('Scheduled Notification for ' +
          scheduledDate.toString() +
          ' ' +
          item.getName());
    });
  }

  notifyWhenJustExpires(StockItem item) async {
    //DateTime scheduledDate = DateTime.parse(item.getExpiryDate()).subtract(Duration(days: 1));
    DateTime scheduledDate = DateTime.now().add(Duration(seconds: 5));
    //6 notifications every 4 hrs
    for (int i = 1; i <= 6; i++) {
      String groupKey = scheduledDate.toString();
      groupKey = groupKey.substring(0, groupKey.indexOf('.'));
      String groupChannelId = 'Red';
      String groupChannelName = 'Just Expiring Items';
      String groupChannelDescription =
          'This channel is associated with items expiring in one day';

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              groupChannelId, groupChannelName, groupChannelDescription,
              importance: Importance.Max,
              priority: Priority.High,
              groupKey: groupKey);
      IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
      NotificationDetails notificationDetails = NotificationDetails(
          androidNotificationDetails, iosNotificationDetails);

      await flutterLocalNotificationsPlugin.schedule(
          item.getId(),
          item.getName(),
          'Expiring in 1 day',
          scheduledDate,
          notificationDetails);
      print('Scheduled Notification for ' +
          scheduledDate.toString() +
          ' ' +
          item.getName());
      print(groupKey);
      scheduledDate = scheduledDate.add(Duration(seconds: 4));
    }
  }

  notifyWhenAboutToExpire(StockItem item) async {
    //DateTime scheduledDate = DateTime.parse(item.getExpiryDate()).subtract(Duration(days: 2));
    DateTime scheduledDate = DateTime.now().add(Duration(seconds: 5));
    //3 notifications every 8 hrs
    for (int i = 1; i <= 3; i++) {
      String groupKey = scheduledDate.toString();
      groupKey = groupKey.substring(0, groupKey.indexOf('.'));
      String groupChannelId = 'Amber';
      String groupChannelName = 'About To Expire Items';
      String groupChannelDescription =
          'This channel is associated with items expiring in two days';

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              groupChannelId, groupChannelName, groupChannelDescription,
              importance: Importance.Max,
              priority: Priority.High,
              groupKey: groupKey);
      IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
      NotificationDetails notificationDetails = NotificationDetails(
          androidNotificationDetails, iosNotificationDetails);

      await flutterLocalNotificationsPlugin.schedule(
          item.getId(),
          item.getName(),
          'Expiring in two days',
          scheduledDate,
          notificationDetails);
      print('Scheduled Notification for ' +
          scheduledDate.toString() +
          ' ' +
          item.getName());
      print(groupKey);
      scheduledDate = scheduledDate.add(Duration(seconds: 8));
    }
  }

  refreshItems() {
    setState(() {
      _stockItems = _dBhelper.getItemsFromStock();
    });
  }

  Icon tileColor(String date) {
    DateTime now = new DateTime.now();
    now = new DateTime(now.year, now.month, now.day);
    int daysLeft = DateTime.parse(date).difference(now).inDays;
    if (daysLeft == 0) {
      return Icon(Icons.error_outline, color: Colors.red);
    } else if (daysLeft <= 2) {
      return Icon(Icons.report_problem, color: Colors.amber);
    } else {
      return null;
    }
  }

  createListUI(List<StockItem> items) {
    //filter dates
    for (int i = 0; i < items.length; i++) {
      DateTime now = new DateTime.now();
      now = new DateTime(now.year, now.month, now.day);
      int daysLeft =
          DateTime.parse(items[i].getExpiryDate()).difference(now).inDays;
      if (daysLeft < 0) {
        //move the item to expired list: todo
        ExpiredItem item =
            new ExpiredItem(items[i].getName(), items[i].getExpiryDate());
        _dBhelper.saveExpiredItem(item);
        _dBhelper.deleteItemFromStock(items[i].getName());
        items.remove(items[i]);
      }
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemBuilder: (context, index) {
        return ListTile(
            onLongPress: () {
              setState(() {
                _longPressedEventActive = true;
              });
            },
            leading: _longPressedEventActive
                ? Wrap(children: <Widget>[
                    IconButton(
                      padding: new EdgeInsets.all(0.0),
                      icon: new Icon(Icons.edit, color: Colors.black, size: 22),
                      onPressed: () {
                        DateTime date =
                            DateTime.parse(items[index].getExpiryDate());
                        createAlertDialog(context, false,
                                name: items[index].getName(), initDate: date)
                            .then((onValue) {
                          if (onValue != null) {
                            items[index].setName(onValue[0]);
                            String dateconverted = new DateFormat('yyyy-MM-dd')
                                .format(onValue[1])
                                .toString();
                            items[index].setExpiryDate(dateconverted);
                            _dBhelper.updateItemFromStock(items[index]);
                            refreshItems();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: new Icon(Icons.delete, color: Colors.red),
                      padding: new EdgeInsets.all(0.0),
                      onPressed: () {
                        createDeleteAlert(context).then((onValue) {
                          if (onValue != null && onValue) {
                            _dBhelper
                                .deleteItemFromStock(items[index].getName());
                            refreshItems();
                          }
                        });
                      },
                    )
                  ])
                : Container(
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: FileImage(File(items[index].getImage())),
                    ),
                  ),
            title: new Text(items[index].getName()),
            subtitle: new Text(items[index].getExpiryDate()),
            trailing: tileColor(items[index].getExpiryDate()));
      },
    );
  }

  //make a future builder with the dynamic list view
  displayUI() {
    return FutureBuilder(
      future: _stockItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _currentStockItems = snapshot.data;
          //temporary remove later
          if (snapshot.data == null || snapshot.data.length == 0) {
            return Column(
              children: <Widget>[
                createCounterPanel([]),
                Expanded(
                    child: new Center(
                        child: new Text(
                  'Add food items and track their expiry',
                  style: TextStyle(color: Colors.grey[600]),
                )))
              ],
            );
            //print('no data was there');
          }
          if (snapshot.hasData) {
            //create ListUI
            print(snapshot.data[0].getImage());
            return createUI(snapshot.data);
            //print(snapshot.data[0].NAME);
          }
        } else {
          return new Center(
              child: new CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xff5c39f8))));
        }
      },
    );
  }

  createCounterPanel(List<StockItem> items) {
    int redCounter = 0, amberCounter = 0, blueCounter = 0;
    for (StockItem item in items) {
      String date = item.getExpiryDate();
      DateTime now = new DateTime.now();
      now = new DateTime(now.year, now.month, now.day);
      int daysLeft = DateTime.parse(date).difference(now).inDays;
      if (daysLeft >= 0) {
        if (daysLeft == 0) {
          redCounter = redCounter + 1;
        } else if (daysLeft <= 2) {
          amberCounter = amberCounter + 1;
        } else {
          blueCounter = blueCounter + 1;
        }
      }
    }
    return new Container(
      child: Row(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                Text(redCounter.toString(),
                    style: TextStyle(color: Colors.white)) //dynamic value here
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            height: 40.0,
            width: 80.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(colors: [
                  Colors.red[800],
                  Colors.deepOrange
                ])), //1Day to expire alert
          ),
          Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.report_problem),
                Text(amberCounter.toString()) // dynamic value here
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            height: 40.0,
            width: 80.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(colors: [
                  Colors.amber[700],
                  Colors.yellow
                ])), //2Days to expire alert
          ),
          Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.shopping_cart, color: Colors.white),
                Text(blueCounter.toString(),
                    style: TextStyle(color: Colors.white)) // dynamic value here
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            height: 40.0,
            width: 80.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(colors: [
                  Color(0xFF5C39F8),
                  Colors.blue
                ])), //3Days to expire alert
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(10.0)),
    );
  }

  createUI(List<StockItem> items) {
    return RefreshIndicator(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          createCounterPanel(items),
          Expanded(child: createListUI(items)),
          _longPressedEventActive
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
                        _longPressedEventActive = false;
                      });
                    },
                  ),
                )
              : Container()
        ],
      ),
      onRefresh: () {
        refreshItems();
      },
    );
  }

  Future<void> alertForSource(BuildContext context, StateSetter setState) {
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
                onTap: () {
                  openCamera(context, setState);
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
                onTap: () {
                  openGallery(context, setState);
                },
              )
            ])),
          );
        });
  }

  openGallery(BuildContext context, StateSetter setState) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var cropped_image = await ImageCropper.cropImage(sourcePath: image.path);
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    String file = cropped_image.toString();
    String fileName =
        file.substring(file.lastIndexOf('/') + 1, file.length - 1);
    print(fileName);
    var cropped_saved_img = await cropped_image.copy('$path/' + fileName);
    setState(() {
      _imageFile = cropped_saved_img;
    });
    Navigator.of(context).pop();
  }

  openCamera(BuildContext context, StateSetter setState) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    var cropped_image = await ImageCropper.cropImage(sourcePath: image.path);
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    String file = cropped_image.toString();
    String fileName =
        file.substring(file.lastIndexOf('/') + 1, file.length - 1);
    print(fileName);
    var cropped_saved_img = await cropped_image.copy('$path/' + fileName);
    setState(() {
      _imageFile = cropped_saved_img;
    });
    Navigator.of(context).pop();
  }

  Future<List> createAlertDialog(BuildContext context, bool state,
      {String name = '', String uri = null, DateTime initDate = null}) {
    TextEditingController controller = new TextEditingController();
    CalendarController calendarController = new CalendarController();
    _imageFile = null;
    //initialization of units
    List<String> units = ['kg', 'g', 'l', 'ml', 'unit'];
    List<DropdownMenuItem<String>> menuItems = List();
    for (String unit in units) {
      menuItems.add(DropdownMenuItem(value: unit, child: Text(unit)));
    }
    DateTimePickerTheme dateTimePickerTheme = new DateTimePickerTheme(
        cancel: Text(""), confirm: Text(""), title: Text('Select Expiry Date'));
    DateTime date = DateTime.now();
    String productName = name;
    String submitButtonText = 'Add Item';
    if (state == false) {
      date = initDate;
      productName = name;
      controller.text = productName;
      submitButtonText = 'Update Item';
    }
    if (name != '') controller.text = name;

    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
              contentPadding: EdgeInsets.all(25.0),
              title: new Text(submitButtonText),
              actions: <Widget>[
                new MaterialButton(
                    child: new Text(submitButtonText,
                        style: TextStyle(color: Color(0xff5c39f8))),
                    onPressed: () {
                      //print(productName);
                      //print(date);
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        Navigator.of(context).pop([productName, date]);
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
                        print(_imageFile.toString());
                        return Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                child: _imageFile == null
                                    ? Icon(Icons.fastfood)
                                    : null,
                                backgroundImage: _imageFile == null
                                    ? uri == null ? null : NetworkImage(uri)
                                    : FileImage(_imageFile),
                              ),
                              GestureDetector(
                                child: CircleAvatar(
                                    radius: 20, child: Icon(Icons.camera_alt)),
                                onTap: () {
                                  /*final snackBar = SnackBar(
                            backgroundColor: Colors.white,
                            content: Row(
                              children: <Widget>[
                                Column(children: <Widget>[Icon(Icons.album), Text('Gallery')]),
                                Column(children: <Widget>[Icon(Icons.camera_alt), Text('Camera')])
                              ],
                            ),
                          );
                          Scaffold.of(this.context).showSnackBar(snackBar);*/
                                  alertForSource(context, setState);
                                },
                              ),
                            ]);
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    new TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter a product name';
                        }
                      },
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add product name...',
                      ),
                      onChanged: (String value) {
                        productName = value;
                      },
                    ),
                    /*new TableCalendar(
            calendarController: calendarController,
            builders: CalendarBuilders(),
          )*/
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: new DatePickerWidget(
                        minDateTime: DateTime(2018),
                        maxDateTime: DateTime(2030),
                        initialDateTime: date,
                        locale: DATETIME_PICKER_LOCALE_DEFAULT,
                        pickerTheme: dateTimePickerTheme,
                        onChange: (dateTime, index) {
                          date = dateTime;
                        },
                      ),
                    )
                  ]),
                ),
              ));
        });
    //preventing memory leaks
    controller.dispose();
    //calendarController.dispose();
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

  /*creatFAB() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new FloatingActionButton.extended(
          icon: Icon(Icons.camera_alt),
          label: Text('Scan'),
          onPressed: () async {
            await scan();
            print(_barcode);
          },
        ),
        SizedBox(
          width: 10,
        ),
        new FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: new Color(0xff5c39f8),
            onPressed: () {
              createAlertDialog(context, true).then((onValue) {
                if (onValue != null) {
                  print(onValue[0]);
                  print(onValue[1]);
                  String date = new DateFormat('yyyy-MM-dd')
                      .format(onValue[1])
                      .toString();
                  StockItem item = new StockItem(onValue[0], date, _imageFile.toString());
                  _dBhelper.saveToStock(item);
                  refreshItems();
                }
              });
            })
      ],
    );
  }*/

  createStyledFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22, color: Color(0xff5c39f8)),
      backgroundColor: Colors.white,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: Icon(Icons.filter_center_focus, color: Color(0xff5c39f8)),
            backgroundColor: Colors.white,
            onTap: () async {
              await scan();
              print(_barcode);
            },
            label: 'Scan Barcode',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xff5c39f8),
                fontSize: 16.0),
            labelBackgroundColor: Colors.white
            /*labelWidget: Text('Scan Barcode',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      color: Color(0xff5c39f8),
                      fontSize: 16.0
                    ))*/
            ),
        // FAB 2
        SpeedDialChild(
          child: Icon(
            Icons.add,
            color: Color(0xff5c39f8),
          ),
          backgroundColor: Colors.white,
          onTap: () {
            createAlertDialog(context, true).then((onValue) {
              if (onValue != null) {
                print(onValue[0]);
                print(onValue[1]);
                String date =
                    new DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
                StockItem item =
                    new StockItem(onValue[0], date, _imageFile.path);
                _dBhelper.saveToStock(item);
                refreshItems();
              }
            });
          },
          label: 'Type Manually',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xff5c39f8),
              fontSize: 16.0),
          labelBackgroundColor: Colors.white,
          /*labelWidget: Text('TYPE MANUALLY',
                    style: GoogleFonts.robotoCondensed(
                      fontWeight: FontWeight.w500,
                      color: Color(0xff5c39f8),
                      fontSize: 16.0
                    )
                  )*/
        )
      ],
    );
  }

  showError() {
    final snackBar = SnackBar(
      content: Text('Product not found! Enter manually?'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          createAlertDialog(context, true).then((onValue) {
            if (onValue != null) {
              print(onValue[0]);
              print(onValue[1]);
              String date =
                  new DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
              StockItem item = new StockItem(onValue[0], date, _imageFile.path);
              _dBhelper.saveToStock(item);
              refreshItems();
            }
          });
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      List<String> product = await getProduct(barcode);
      String productName, productImg;
      if (product[0] == null) productName = '';
      if (product[1] != "404") productImg = product[1];
      print(productName);
      if (productName == "404") {
        showError();
      } else {
        createAlertDialog(context, true, name: productName, uri: productImg)
            .then((onValue) {
          if (onValue != null) {
            print(onValue[0]);
            print(onValue[1]);
            String date =
                new DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
            StockItem item = new StockItem(onValue[0], date, _imageFile.path);
            _dBhelper.saveToStock(item);
            refreshItems();
          }
        });
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          _barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() {
          _barcode = 'Unknown error: $e';
        });
      }
    } on FormatException {
      setState(() {
        _barcode =
            'null (User returned using the "back"-button before scanning anything. Result)';
      });
    } catch (e) {
      setState(() {
        _barcode =
            'null (User returned using the "back"-button before scanning anything. Result)';
      });
    }
  }

  Future<List<String>> getProduct(String barcode) async {
    ProductResult result =
        await OpenFoodAPIClient.getProduct(barcode, User.LANGUAGE_EN);

    if (result.status == 1) {
      return [result.product.productName, result.product.imgSmallUrl];
    } else {
      return ["404", "404"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: displayUI(),
      floatingActionButton: createStyledFAB(),
    );
  }
}
