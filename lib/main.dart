import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fm_tutor/myhomepage.dart';
import 'package:fm_tutor/secondpage.dart';
import 'global.dart' as global;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.subscribeToTopic("topic");
  if (global.i == 5) {
    await FirebaseMessaging.instance.unsubscribeFromTopic('topic');
  }

  print("ini merupakan token cloud messaging ${fcmToken}  terkahir");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        '/second': (context) => SecondPage()
      },
    );
  }
}
