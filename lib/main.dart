import 'dart:convert';

import 'package:clix_flutter/clix_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:push_notifications/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingHandler);

  await Clix.initialize(
    ClixConfig(
      projectId: dotenv.env['CLIX_PROJECT_ID']!,
      apiKey: dotenv.env['CLIX_PUBLIC_API_KEY']!,
    ),
  );

  await dotenv.load();

  runApp(const MainApp());
}

Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling message: ${message.messageId}");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReminderApp(),
    );
  }
}

class ReminderApp extends StatefulWidget {
  const ReminderApp({super.key});

  @override
  State<ReminderApp> createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  // Clix API details - found in the settings for the project
  final clixApiKey = dotenv.env['CLIX_SECRET_API_KEY']!;
  final clixUrl = "https://api.clix.so/api/v1/send-push-notifications";
  final clixProjectId = dotenv.env['CLIX_PROJECT_ID']!;

  // Reminders data
  final List<Map<String, String>> reminders = [
    {"title": "Drink Water", "emoji": "💧"},
    {"title": "Read a Book", "emoji": "📚"},
    {"title": "Meditate", "emoji": "🧘🏾‍♀"},
    {"title": "Journal", "emoji": "📓"},
    {"title": "Meal Prep", "emoji": "🥗"},
    {"title": "Plan the Week", "emoji": "🗓️"},
    {"title": "Call Family", "emoji": "📞"},
    {"title": "Go Outdoors", "emoji": "🌳"},
  ];

  late FirebaseMessaging messaging;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    _initFCM();
  }

  Future<void> _initFCM() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      fcmToken = await messaging.getToken();
      if (kDebugMode) {
        print("FCM Token: $fcmToken");
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        Fluttertoast.showToast(
          msg: message.notification!.title ?? '',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    });
  }

  Future<void> _triggerPush(String title) async {
    final deviceId = await Clix.getDeviceId();
    if (deviceId == null) {
      if (kDebugMode) {
        print("No Clix device ID available.");
      }
      return;
    }

    final body = {
      "push_notifications": [
        {
          "target": {"device_id": deviceId},
          "title": title,
          "body":
              "As part of your daily wellness challenge, this is your reminder to ${title.toLowerCase()}",
        },
      ],
    };

    final res = await http.post(
      Uri.parse(clixUrl),
      headers: {
        "Content-Type": "application/json",
        "X-Clix-API-Key": clixApiKey,
        "X-Clix-Project-ID": clixProjectId,
      },
      body: json.encode(body),
    );

    if (kDebugMode) {
      print("Push response: ${res.statusCode} ${res.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Reminders"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final item = reminders[index];
            return GestureDetector(
              onTap: () {
                Fluttertoast.showToast(
                  msg: "Reminder for '${item['title']}' has been set",
                  toastLength: Toast.LENGTH_SHORT,
                );

                _triggerPush(item['title']!);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['emoji']!, style: TextStyle(fontSize: 40)),
                    SizedBox(height: 8),
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
