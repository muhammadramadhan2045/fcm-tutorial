import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fm_tutor/myhomepage.dart';
import 'package:fm_tutor/secondpage.dart';
import 'package:fm_tutor/thirdpage.dart';
import 'global.dart' as global;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  print("ini merupakan token cloud messaging ${fcmToken}  terkahir");
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // It is assumed that all messages contain a data field with the key 'type'  }

  @override
  void initState() {
    super.initState();
    // Run code required to handle interacted messages in an async function
    // as initState() must not be async

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          print('${message.notification}');

          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
                playSound: true,
                color: Colors.blue,
              ),
            ),
            payload: message.data['route'],
          );
          if (message != null) {
            print(message.notification?.body);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message.notification!.body!)));
            var routeName = message.data['route'];
            Navigator.of(context).pushNamed(routeName);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MyHomePage(title: "Flutter Demo Home Page"),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const MyHomePage(title: 'title'),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => SecondPage(),
        '/third': (context) => ThirdPage(),
      },
    );
  }

  Future<void> requestPermisi() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }
}
