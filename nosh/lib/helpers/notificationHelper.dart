import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nosh/models/StoredItem.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
UniqueNumericId uid;

initializeAndCancelNotifications() async {
  if (flutterLocalNotificationsPlugin == null) {
    //initialize notifications
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin
        .initialize(initializationSettings);
    await flutterLocalNotificationsPlugin.cancelAll();
  } else {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

scheduleNotifications(List<Item> storedItems) {
  uid = UniqueNumericId();
  if (storedItems != null && storedItems.length != 0) {
    for (Item item in storedItems) {
      DateTime date = item.expiry;
      if (date == null) continue;
      DateTime now = DateTime.now();
      now = DateTime(now.year, now.month, now.day);
      int daysLeft = date.difference(now).inDays;
      if (daysLeft >= 0) {
        if (daysLeft == 0) {
          notifyWhenExpires(item);
        } else if (daysLeft <= 1) {
          notifyWhenExpires(item);
          notifyWhenJustExpires(item);
        } else {
          notifyWhenExpires(item);
          notifyWhenJustExpires(item);
          notifyWhenAboutToExpire(item);
        }
      }
    }
  }
}

notifyWhenExpires(Item item) async {
  //DateTime scheduledDate = DateTime.now().add(Duration(seconds: 5));
  DateTime scheduledDate = item.expiry.add(Duration(days: 1));
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
  await flutterLocalNotificationsPlugin
      .schedule(uid.getUid(), item.name, 'Expired', scheduledDate, notificationDetails);
}

notifyWhenJustExpires(Item item) async {
  DateTime scheduledDate = item.expiry;
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
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);

    await flutterLocalNotificationsPlugin.schedule(
        uid.getUid(), item.name, 'Expiring in 1 day', scheduledDate, notificationDetails);
    scheduledDate = scheduledDate.add(Duration(hours: 4));
  }
}

notifyWhenAboutToExpire(Item item) async {
  DateTime scheduledDate = item.expiry.subtract(Duration(days: 1));
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
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);

    await flutterLocalNotificationsPlugin.schedule(uid.getUid(), item.name,
        'Expiring in two days', scheduledDate, notificationDetails);
    scheduledDate = scheduledDate.add(Duration(hours: 8));
  }
}

//for generating unique ids for notifications
class UniqueNumericId {
  int id;
  UniqueNumericId() {
    id = 0;
  }

  getUid() {
    return id++;
  }
}