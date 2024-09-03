import 'dart:math';
import 'package:fast_tag/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "dart:developer" as lg;
import 'package:rxdart/rxdart.dart';

class NotificationServices {
  String? callId;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterlocalnotificationplugin =
      FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  void requestNotificationPermission(BuildContext context) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      // PrintMessage.printmessage(
      //     e.toString(),
      //     'requestNotificationPermission',
      //     'Notification Sercive',
      //     context,
      //     Colorfile().errormessagebcColor,
      //     Colorfile().errormessagetxColor);
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    try {
      var androidInitialization =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitialization = const DarwinInitializationSettings();
      var intializationSetting = InitializationSettings(
          android: androidInitialization, iOS: iosInitialization);

      //await flutterlocalnotificationplugin.initialize(intializationSetting);
      await flutterlocalnotificationplugin.initialize(intializationSetting,
          onDidReceiveNotificationResponse: (payload) {
        handleRemoteMessage(context, message);
      });

      final details = await flutterlocalnotificationplugin
          .getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        handleRemoteMessage(context, message);
      }
    } catch (e) {
      // PrintMessage.printmessage(
      //     e.toString(),
      //     'initLocalNotifications',
      //     'Notification Sercive',
      //     context,
      //     Colorfile().errormessagebcColor,
      //     Colorfile().errormessagetxColor);
    }
  }

  void firebaseInit(BuildContext context) {
    try {
      FirebaseMessaging.onMessage.listen((message) {
        //if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
        // } else {
        //   showNotification(message);
        // }
      });
    } catch (e) {
      // PrintMessage.printmessage(
      //     e.toString(),
      //     'firebaseInit',
      //     'Notification Services',
      //     context,
      //     Colorfile().errormessagebcColor,
      //     Colorfile().errormessagetxColor);
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(), 'text_channel',
        importance: Importance.high);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'Your channel Description',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            //  sound: RawResourceAndroidNotificationSound('res_custom_message'),
            ticker: 'ticker');

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      flutterlocalnotificationplugin.show(
        1,
        message.data['title'].toString(),
        message.data['body'].toString(),
        notificationDetails,
      );
    });
  }

  Future<String> getDevicetoken() async {
    String? token = await firebaseMessaging.getToken();
    return token!;
  }

  void isTokenRefresh(BuildContext context) {
    try {
      firebaseMessaging.onTokenRefresh.listen((event) {
        event.toString();
      });
    } catch (e) {
      // PrintMessage.printmessage(
      //     e.toString(),
      //     'isTokenRefresh',
      //     'Notification Sercive',
      //     context,
      //     Colorfile().errormessagebcColor,
      //     Colorfile().errormessagetxColor);
    }
  }

  Future<void> setInteractMessage(BuildContext context) async {
    //when app is termitted
    try {
      RemoteMessage? initialmessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialmessage != null) {
        handleRemoteMessage(context, initialmessage);
      }
      //when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        handleRemoteMessage(context, event);
      });
    } catch (e) {
      // PrintMessage.printmessage(
      //     e.toString(),
      //     'setInteractMessage',
      //     'Notification Sercive',
      //     context,
      //     Colorfile().errormessagebcColor,
      //     Colorfile().errormessagetxColor);
    }
  }

  void handleRemoteMessage(BuildContext context, RemoteMessage message) async {
    print('Handling remote message: ${message.notification?.title}');
    final data = message.data;
    String landingPage =
        message.data['landing_page']?.toString().toLowerCase() ?? '';
    lg.log(landingPage);
    switch (landingPage) {
      case "order_details":
        print('Navigating to Order Details page');
        // navigatorKey.currentState?.push(MaterialPageRoute(
        //   builder: (context) => ViewOrder(
        //     data['order_id'] ?? '',
        //     data['route'] ?? '',
        //     data['order_no'] ?? '',
        //   ),
        // ));
        break;

      // case "query_details":
      //   print('Navigating to Help Detail page');
      //   final ticketId = data['ticket_id'] ?? '';

      //   if (ticketId.isNotEmpty) {
      //     // Call the network function to fetch the latest data
      //     // await NetworkcallforDard(context);

      //     // Check if carddata is available
      //     if (carddata.isNotEmpty) {
      //       final UserQuery? query = getUserQueryById(ticketId);
      //       if (query != null) {
      //         navigatorKey.currentState?.push(MaterialPageRoute(
      //           builder: (context) => helpDetail(carddata: query),
      //         ));
      //       } else {
      //         print('No UserQuery found with the given ticket ID');
      //       }
      //     } else {
      //       print(
      //           'No card data available, cannot navigate to Help Detail page');
      //     }
      //   } else {
      //     print('Ticket ID is missing');
      //   }
      //   break;

      default:
        print('Default route, navigating to home');
        navigatorKey.currentState?.pushNamed('/');
    }
  }
}
