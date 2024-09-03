import 'dart:math';
import 'package:fast_tag/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "dart:developer" as lg;
import 'package:rxdart/rxdart.dart';

import 'pages/homeScreen.dart';
import 'pages/notifiation.dart';
import 'pages/report_inssurance.dart';
import 'pages/tickets_details.dart';
import 'pages/tickets_list.dart';
import 'pages/wallet.dart';

class NotificationServices {
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
      print('Error in requestNotificationPermission: $e');
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    try {
      var androidInitialization =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitialization = const DarwinInitializationSettings();
      var initializationSetting = InitializationSettings(
          android: androidInitialization, iOS: iosInitialization);

      await flutterlocalnotificationplugin.initialize(
        initializationSetting,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          handleRemoteMessage(context, message);
        },
      );
    } catch (e) {
      print('Error in initLocalNotifications: $e');
    }
  }

  void firebaseInit(BuildContext context) {
    try {
      FirebaseMessaging.onMessage.listen((message) {
        initLocalNotifications(context, message);
        showNotification(message);
      });
    } catch (e) {
      print('Error in firebaseInit: $e');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'text_channel',
      importance: Importance.high,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Your channel Description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    flutterlocalnotificationplugin.show(
      1,
      message.notification?.title ?? 'Title',
      message.notification?.body ?? 'Body',
      notificationDetails,
    );
  }

  Future<void> setInteractMessage(BuildContext context) async {
    try {
      RemoteMessage? initialmessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialmessage != null) {
        // This handles notification tap when app is opened from terminated state
        handleRemoteMessage(context, initialmessage);
      }

      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        // This handles notification tap when app is in background or foreground
        handleRemoteMessage(context, event);
      });
    } catch (e) {
      print('Error in setInteractMessage: $e');
    }
  }

  void handleRemoteMessage(BuildContext context, RemoteMessage message) async {
    print('Handling remote message: ${message.messageId}');
    print('Notification title: ${message.notification?.title}');
    print('Notification body: ${message.notification?.body}');
    print('Notification data: ${message.data}');

    String pageLink = message.data['page_link']?.toString() ?? '';
    String orderId =
        message.data['order_id']?.toString() ?? ''; // Extract the order_id

    switch (pageLink) {
      case "WalletPage":
        print('Navigating to Wallet Page');
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => WalletPage()),
        );
        break;

      case "ReportIssuancePage":
        print('Navigating to Report Issuance Page');
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => ReportIssuancePage()),
        );
        break;

      case "raiseticketdetailpage":
        if (orderId.isNotEmpty) {
          print('Navigating to Ticket Details Page with ID: $orderId');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (context) => TicketDetailsPage(id: orderId)),
          );
        } else {
          print('Order ID is missing, navigating to Tickets List Page');
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => TicketsListPage()),
          );
        }
        break;

      case "NotificationPage":
        print('Navigating to Notification Page');
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
        break;

      default:
        print('Default route, navigating to home');
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (context) =>
                  MyDashboard()), // Replace MyDashboard with your home page widget
        );
        break;
    }
  }

  Future<String> getDevicetoken() async {
    String? token = await firebaseMessaging.getToken();
    return token!;
  }
}
