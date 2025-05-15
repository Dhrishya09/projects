import 'package:flutter/material.dart';
import 'dummy_data.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, String>> todayNotifications = [];
  List<Map<String, String>> yesterdayNotifications = [];
  List<Map<String, String>> earlierNotifications = [];

  @override
  void initState() {
    super.initState();
    _categorizeNotifications();
  }

  void _categorizeNotifications() {
    String today = DummyData.getTodayDate();
    String yesterday = DummyData.getYesterdayDate();

    todayNotifications.clear();
    yesterdayNotifications.clear();
    earlierNotifications.clear();

    for (var alert in DummyData.alerts) {
      if (alert['date'] == today) {
        todayNotifications.add(alert);
      } else if (alert['date'] == yesterday) {
        yesterdayNotifications.add(alert);
      } else {
        earlierNotifications.add(alert);
      }
    }
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear All Notifications?"),
        content: Text("Are you sure you want to delete all notifications?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                DummyData.alerts.clear();
                _categorizeNotifications();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("All notifications cleared!")),
              );
            },
            child: Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 253, 254),
      appBar: AppBar(
        title: Text("Notifications"),
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 157, 202, 241), const Color.fromARGB(255, 158, 207, 247)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),  
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        actions: [
          if (DummyData.alerts.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: _clearAllNotifications,
            ),
        ],
      ),
      body: DummyData.alerts.isEmpty
          ? Center(
              child: Text(
                "No notifications available.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildNotificationSection("Today", todayNotifications, const Color.fromARGB(255, 255, 225, 225)),
                _buildNotificationSection("Yesterday", yesterdayNotifications, const Color.fromARGB(255, 255, 225, 225)),
                _buildNotificationSection("Earlier", earlierNotifications, const Color.fromARGB(255, 255, 225, 225)),
              ],
            ),
    );
  }

  Widget _buildNotificationSection(String title, List<Map<String, String>> notifications, Color color) {
    if (notifications.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),  // Made heading bold
          ),
        ),
        ...notifications.map((notification) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: color,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.notifications, color: Colors.red),
              ),
              title: Text(
                notification['text'] ?? "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🕒 ${notification['time']}  |  📅 ${notification['date']}",
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification['description'] ?? "No description available.",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
            ),
          );
        }),
      ],
    );
  }
}
