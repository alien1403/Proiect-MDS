import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter/material.dart';

import '../View/selectCoin.dart';
import '../main.dart';

class Notification {
  final int id;
  final String title;
  final String body;
  final String payload;

  Notification({
    this.id = 0,
    this.title = "Title",
    this.body = "Body",
    this.payload = "Payload",
  });
}

class NotificationAPI {
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationAPI(this.navigatorKey);


  static final notifFactory = FlutterLocalNotificationsPlugin();

  final BehaviorSubject<Notification> didReceiveLocalNotificationSubject =
  BehaviorSubject<Notification>();

  Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationSubject.add(Notification(
          id: id,
          title: title ?? "Title",
          body: body ?? "Body",
          payload: payload ?? "Payload",
        ));
      },
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notifFactory.initialize
    (
        initializationSettings,
        onSelectNotification: onSelect
    );
  }

  Future<void> onSelect(String? payload) async {
    print("onSelect start; payload = $payload");

    if (payload != null) {
      var coinFromPayload;

      coinMarketNotif = await getCoinMarketNotif();
      print("Length of market in API: ${coinMarketNotif!.length}");

      for (var coin in coinMarketNotif!) {
        print(".");
        if (coin.id == payload) {
          coinFromPayload = coin;
          print("Coin from payload: ${coinFromPayload.id}");
          break;
        }
      }

      print("Pushing to navigator");
      if (navigatorKey.currentState == null)
        print("currentState is null...");
      else
      {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
              builder: (context) => SelectCoin(selectItem: coinFromPayload)),
        );
        print("Pushed to navigator");
      }
    }
  }


  static Future<NotificationDetails> notifDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        'channel description',
        importance: Importance.max,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future<void> showNotification({
    int id = 0,
    String? title = "",
    String? body,
    String? payload,
  }) async {
    await notifFactory.show(
      id,
      title,
      body,
      await notifDetails(),
      payload: payload,
    );
  }
}