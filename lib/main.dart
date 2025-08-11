import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MainApp());
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
