import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, bool> _settings = {
    "General Notification": false,
    "Sound": false,
    "Vibrate": false,
    "App updates": false,
    "App Reminder": false,
    "Energy consumption tracking": false,
    "Payment Request": false,
    "Tutorial": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection("Common", ["General Notification", "Sound", "Vibrate"]),
          _buildSettingsSection("System & services update", [
            "App updates",
            "App Reminder",
            "Energy consumption tracking",
            "Payment Request"
          ]),
          _buildSettingsSection("Others", ["Tutorial"]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Highlight the settings tab
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.blue), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ""),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          color: Colors.blueGrey[50],
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: items
                .map((item) => SwitchListTile(
                      title: Text(item),
                      value: _settings[item]!,
                      onChanged: (bool value) {
                        setState(() {
                          _settings[item] = value;
                        });
                      },
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
