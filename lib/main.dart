import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String teks = '';
  //deklarasi firebase messaging
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  //deklarasi local notification

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  var mymap = {};
  var title = '';
  var body = {};
  var mytoken = '';

  void initState() {
    //TODO : implement initState
    super.initState();

    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android: android, iOS: ios);

    flutterLocalNotificationsPlugin.initialize(platform);
    //konfigurasi firebase messaging
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('On message $message');
      //Jadikan mymap = message
      mymap = message;
      //tampilkan notifikasi
      displayNotifikasi(message);
    }, onResume: (Map<String, dynamic> message) {
      print('On resume $message');
    }, onLaunch: (Map<String, dynamic> message) {
      print('On launch $message');
    });

    _firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(
      sound: true,
      alert: true,
      badge: true,
    ));

    _firebaseMessaging.getToken().then((token) {
      updateToken(token);
    });
  }

  displayNotifikasi(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
        "1", "channelName", "channelDescription");
    var ios = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: ios);

    msg.forEach((nTitle, nBody) {
      title = nTitle;
      body = nBody;
      setState(() {});
    });

    //https://github.com/flutter/flutter/issues/18425
    await flutterLocalNotificationsPlugin.show(
        0, msg['notification']['title'], msg['notification']['body'], platform);
  }

  updateToken(String token) {
    print(token);
    DatabaseReference databaseReference = FirebaseDatabase().reference();

    databaseReference.child('fcm-token/$token').set({"token": token});
    mytoken = token;
    teks = mytoken;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Notif apps'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$teks'),
          ],
        ),
      ),
    );
  }
}
