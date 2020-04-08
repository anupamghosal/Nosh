import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:nosh/database/expiredItem.dart';
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
  final Function incrementExpiredItemCount;
  Stock({this.incrementExpiredItemCount});
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> with WidgetsBindingObserver {
  Future<List<StockItem>> _stockItems;
  List<StockItem> _currentStockItems;
  DBhelper _dBhelper;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String _barcode = '';
  bool LOADING = false;

  final _formKey = GlobalKey<FormState>();
  bool _longPressedEventActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dBhelper = DBhelper();
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
    if (_currentStockItems != null && _currentStockItems.length != 0) {
      for (StockItem item in _currentStockItems) {
        String date = item.getExpiryDate();
        if (date == '') continue;
        DateTime now = DateTime.now();
        now = DateTime(now.year, now.month, now.day);
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
    //DateTime scheduledDate = DateTime.now().add(Duration(seconds: 5));
    DateTime scheduledDate =
        DateTime.parse(item.getExpiryDate()).add(Duration(days: 1));
    print(scheduledDate);
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
    DateTime scheduledDate = DateTime.parse(item.getExpiryDate());
    //DateTime scheduledDate = DateTime.now().add(Duration(seconds: 5));
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
      scheduledDate = scheduledDate.add(Duration(hours: 4));
    }
  }

  notifyWhenAboutToExpire(StockItem item) async {
    DateTime scheduledDate =
        DateTime.parse(item.getExpiryDate()).add(Duration(days: 1));
    //DateTime scheduledDate = DateTime.now().add(Duration(seconds: 5));
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
      scheduledDate = scheduledDate.add(Duration(hours: 8));
    }
  }

  refreshItems() {
    setState(() {
      _stockItems = _dBhelper.getItemsFromStock();
    });
  }

  Icon tileColor(String date) {
    if (date == '') return null;
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
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
            leading: AnimatedCrossFade(
              crossFadeState: _longPressedEventActive
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200),
              firstChild: Container(
                height: 60.0,
                key: ValueKey(1),
                child: Wrap(children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.edit, color: Colors.black, size: 22),
                    onPressed: () {
                      DateTime date = null;
                      if (items[index].getExpiryDate() != '')
                        date = DateTime.parse(items[index].getExpiryDate());
                      createAlertDialog(context, false,
                              name: items[index].getName(),
                              link: items[index].getImage(),
                              initDate: date,
                              initQuantity: items[index].getQuantity())
                          .then((onValue) {
                        if (onValue != null) {
                          items[index].setName(onValue[0]);
                          String dateconverted = '';
                          if (onValue[1] != null)
                            dateconverted = DateFormat('yyyy-MM-dd')
                                .format(onValue[1])
                                .toString();
                          items[index].setExpiryDate(dateconverted);
                          items[index].setImage(onValue[2]);
                          items[index].setQuantity(onValue[3]);
                          _dBhelper.updateItemFromStock(items[index]);
                          refreshItems();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      createDeleteAlert(context).then((onValue) {
                        if (onValue != null && onValue) {
                          _dBhelper.deleteItemFromStock(items[index].getId());
                          //delete image file
                          if (!items[index].getImage().startsWith('https') &&
                              items[index].getImage() != '')
                            File(items[index].getImage()).delete();
                          refreshItems();
                        }
                      });
                    },
                  )
                ]),
              ),
              secondChild: Container(
                key: ValueKey(2),
                child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 30.0,
                    backgroundImage: selectImageType(items[index].getImage()),
                    child: selectImageType(items[index].getImage()) == null
                        ? Icon(
                            Icons.fastfood,
                            color: Colors.white,
                          )
                        : null),
              ),
              layoutBuilder:
                  (topChild, topChildKey, bottomChild, bottomChildKey) {
                return Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Positioned(
                      key: bottomChildKey,
                      top: 0,
                      bottom: 0,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    )
                  ],
                );
              },
            ),
            title: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 6,
                    // width: MediaQuery.of(context).size.width * 0.54,
                    child: Text(
                      items[index].getName(),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  items[index].getQuantity() != ''
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(4.0)),
                          margin: EdgeInsets.only(left: 20.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 3.0),
                          child: Text(
                            items[index].getQuantity(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            subtitle: Text(items[index].getExpiryDate() == ''
                ? 'No expiry date'
                : items[index].getExpiryDate()),
            trailing: tileColor(items[index].getExpiryDate()));
      },
    );
  }

  selectImageType(String link) {
    if (link.startsWith('https'))
      return NetworkImage(link);
    else if (link == '')
      return null;
    else
      return FileImage(File(link));
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
            return Center(
                child: Text(
              'Add food items and track their expiry',
              style: TextStyle(color: Colors.grey[600]),
            ));
            //print('no data was there');
          }
          if (snapshot.hasData) {
            //create ListUI
            print(snapshot.data[0].getImage());
            List<StockItem> items = snapshot.data;
            //filter dates
            for (int i = 0; i < items.length; i++) {
              if (items[i].getExpiryDate() == '') continue;
              DateTime now = DateTime.now();
              now = DateTime(now.year, now.month, now.day);
              int daysLeft = DateTime.parse(items[i].getExpiryDate())
                  .difference(now)
                  .inDays;
              if (daysLeft < 0) {
                //move the item to expired list: todo
                ExpiredItem item = ExpiredItem(
                    items[i].getName(),
                    items[i].getExpiryDate(),
                    items[i].getImage(),
                    items[i].getQuantity());
                _dBhelper.saveExpiredItem(item);
                _dBhelper.deleteItemFromStock(items[i].getId());
                items.remove(items[i]);
              }
            }
            if (items.length == 0) {
              return Column(
                children: <Widget>[
                  createCounterPanel([]),
                  Expanded(
                      child: Center(
                          child: Text(
                    'Add food items and track their expiry',
                    style: TextStyle(color: Colors.grey[600]),
                  )))
                ],
              );
            }
            return createUI(items);
            //print(snapshot.data[0].NAME);
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xff5c39f8))));
        }
      },
    );
  }

  createCounterPanel(List<StockItem> items) {
    int redCounter = 0, amberCounter = 0, blueCounter = 0, total = 0;
    for (StockItem item in items) {
      String date = item.getExpiryDate();
      if (date == '') {
        total = total + 1;
        continue;
      }
      DateTime now = DateTime.now();
      now = DateTime(now.year, now.month, now.day);
      int daysLeft = DateTime.parse(date).difference(now).inDays;
      if (daysLeft >= 0) {
        if (daysLeft == 0) {
          redCounter = redCounter + 1;
        } else if (daysLeft <= 2) {
          amberCounter = amberCounter + 1;
        } else {
          blueCounter = blueCounter + 1;
        }
        total = total + 1;
      }
    }
    return Container(
      child: Row(
        children: <Widget>[
          Container(
              height: 40.0,
              padding: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 0.5)),
              child: Row(
                children: <Widget>[
                  Transform.rotate(
                      angle: -3.1415 / 2,
                      child: Text("TOTAL",
                          style: TextStyle(
                              fontSize: 8, fontWeight: FontWeight.w600))),
                  Text(
                    total.toString(),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  )
                ],
              )),
          Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                Text(redCounter.toString(),
                    style: TextStyle(color: Colors.white)) //dynamic value here
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            height: 40.0,
            width: 75.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                    colors: [Colors.red[800], Colors.deepOrange])),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.report_problem, size: 20),
                Text(amberCounter.toString())
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            height: 40.0,
            width: 75.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient:
                    LinearGradient(colors: [Colors.amber[700], Colors.yellow])),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.thumb_up, color: Colors.white, size: 20),
                Text(blueCounter.toString(),
                    style: TextStyle(color: Colors.white)) // dynamic value here
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            height: 40.0,
            width: 75.0,
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
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
    );
  }

  createUI(List<StockItem> items) {
    return RefreshIndicator(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          createCounterPanel(items),
          Expanded(child: createListUI(items)),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: _longPressedEventActive
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
                : SizedBox(),
          )
        ],
      ),
      onRefresh: () {
        refreshItems();
      },
    );
  }

  Future<File> alertForSourceAndGetImage() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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

  Future<List> createAlertDialog(BuildContext context, bool state,
      {String name = '',
      String link = '',
      DateTime initDate = null,
      String initQuantity = ''}) {
    TextEditingController controller = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    DateTimePickerTheme dateTimePickerTheme = DateTimePickerTheme(
        cancel: Text(""), confirm: Text(""), title: Text('Select Expiry Date'));
    DateTime date = null;
    String productName = name;
    String quantity = initQuantity;
    String submitButtonText = 'Add Item';
    File imageFile = null;
    String uri = null;
    bool enable = false;
    if (link.startsWith('https'))
      uri = link;
    else if (link != '') imageFile = File(link);
    if (state == false) {
      date = initDate;
      productName = name;
      controller.text = productName;
      submitButtonText = 'Update Item';
    }
    if (name != '') controller.text = name;
    if (initQuantity != '') quantityController.text = initQuantity;
    if (date != null) enable = true;

    return showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
            onPanStart: (_) {
              FocusScope.of(context).unfocus();
            },
            child: AlertDialog(
                contentPadding: EdgeInsets.all(25.0),
                title: Text(submitButtonText),
                actions: <Widget>[
                  MaterialButton(
                      child: Text(submitButtonText,
                          style: TextStyle(color: Color(0xff5c39f8))),
                      onPressed: () {
                        //print(productName);
                        //print(date);
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          Navigator.of(context).pop([
                            productName,
                            enable ? date : null,
                            imageFile == null
                                ? uri == null ? '' : uri
                                : imageFile.path,
                            quantity
                          ]);
                        }
                      },
                      elevation: 5.0)
                ],
                content: SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: StatefulBuilder(builder: (context, setState) {
                        return Column(children: <Widget>[
                          Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.grey[100],
                                  radius: 50,
                                  child: imageFile == null && uri == null
                                      ? Icon(
                                          Icons.fastfood,
                                          color: Colors.grey[900],
                                        )
                                      : null,
                                  backgroundImage: imageFile == null
                                      ? uri == null ? null : NetworkImage(uri)
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
                                        uri = null;
                                      });
                                    });
                                  },
                                ),
                              ]),
                          SizedBox(
                            height: 30,
                          ),
                          Row(children: <Widget>[
                            Flexible(
                                flex: 3,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'please enter a product name';
                                    }
                                  },
                                  controller: controller,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'product name',
                                  ),
                                  onChanged: (String value) {
                                    productName = value;
                                  },
                                )),
                            SizedBox(width: 20.0),
                            Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: quantityController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Qty'),
                                  onChanged: (String value) {
                                    quantity = value;
                                  },
                                ))
                          ]),
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
                                    if (enable) date = DateTime.now();
                                  });
                                  FocusScope.of(context).unfocus();
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
                                        locale: DATETIME_PICKER_LOCALE_DEFAULT,
                                        pickerTheme: dateTimePickerTheme,
                                        onChange: (dateTime, index) {
                                          date = dateTime;
                                        },
                                      ))
                                ],
                              ),
                              secondChild: Text(""))
                        ]);
                      })),
                )),
          );
        });
    //preventing memory leaks
    controller.dispose();
    //calendarController.dispose();
  }

  Future createDeleteAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text("Are you sure?"), actions: <Widget>[
            MaterialButton(
              child: Text('Yes', style: TextStyle(color: Color(0xff5c39f8))),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            MaterialButton(
                child: Text('No', style: TextStyle(color: Color(0xff5c39f8))),
                onPressed: () {
                  Navigator.of(context).pop(false);
                })
          ]);
        });
  }

  createStyledFAB() {
    return SpeedDial(
      onOpen: () {
        setState(() {
          _longPressedEventActive = false;
        });
      },
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
              Widget snackbar;
              try {
                final result = await InternetAddress.lookup('google.com');
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  await scan();
                }
              } on SocketException catch (_) {
                snackbar = SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text("Internet connection not eastablished!"),
                  backgroundColor: Color(0xff5c39f8),
                );
              }

              if (snackbar != null) {
                Scaffold.of(context).showSnackBar(snackbar);
              }
            },
            label: 'Scan Barcode',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xff5c39f8),
                fontSize: 16.0),
            labelBackgroundColor: Colors.white),
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
                String date = '';
                if (onValue[1] != null) {
                  date = new DateFormat('yyyy-MM-dd')
                      .format(onValue[1])
                      .toString();
                  DateTime now = new DateTime.now();
                  now = new DateTime(now.year, now.month, now.day);
                  int daysLeft = onValue[1].difference(now).inDays;
                  if (daysLeft < 0) widget.incrementExpiredItemCount();
                }
                StockItem item =
                    StockItem(onValue[0], date, onValue[2], onValue[3]);
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
        )
      ],
    );
  }

  showError() {
    final snackBar = SnackBar(
      duration: Duration(seconds: 6),
      backgroundColor: Color(0xff5c39f8),
      content: Text(
        'Product not found! \nEnter manually?',
        style: TextStyle(color: Colors.grey[50], fontWeight: FontWeight.w300),
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'OK',
        onPressed: () {
          createAlertDialog(context, true).then((onValue) {
            if (onValue != null) {
              print(onValue[0]);
              print(onValue[1]);
              String date = '';
              if (onValue[1] != null)
                date = DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
              StockItem item =
                  StockItem(onValue[0], date, onValue[2], onValue[3]);
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
      setState(() {
        LOADING = true;
      });
      List<String> product = await getProduct(barcode);
      String productName, productImg = '';
      productName = product[0];
      if (product[0] == null) productName = '';
      if (product[1] == null) productImg = '';
      if (product[1] != "404") productImg = product[1];
      print('product img');
      print(product[1]);
      print(productName);
      setState(() {
        LOADING = false;
      });
      if (productName == "404") {
        showError();
      } else {
        createAlertDialog(context, true, name: productName, link: productImg)
            .then((onValue) {
          if (onValue != null) {
            print(onValue[0]);
            print(onValue[1]);
            String date = '';
            if (onValue[1] != null)
              date = DateFormat('yyyy-MM-dd').format(onValue[1]).toString();
            StockItem item =
                StockItem(onValue[0], date, onValue[2], onValue[3]);
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LOADING
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(),
          displayUI(),
        ],
      ),
      floatingActionButton: createStyledFAB(),
    );
  }
}
