import 'package:intl/intl.dart';

class DummyData {
  static const String userName = "John Doe";
  static const String profilePic = "assets/profile.png";
  static const String weather = "Sunny, 25°C";
  static const int totalHouseholds = 3;

  // Get today's and yesterday's dates as strings
  static String getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String getYesterdayDate() {
    return DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(Duration(days: 1)));
  }

  static List<Map<String, String>> alerts_user= [
    {
      "text": "High energy consumption detected!",
      "time": "10:30 AM",
      "date": getTodayDate(),
      "description": "Energy consumption in your home has increased significantly. Please check for any high-energy devices or appliances running."
    }];

  // Sample notifications with dates and descriptions
  static List<Map<String, String>> alerts = [
    {
      "text": "High energy consumption detected!",
      "time": "10:30 AM",
      "date": getTodayDate(),
      "description": "Energy consumption in your home has increased significantly. Please check for any high-energy devices or appliances running."
    },
    {
      "text": "Device XYZ needs maintenance",
      "time": "1:45 PM",
      "date": getTodayDate(),
      "description": "Device XYZ has been flagged for maintenance. Please inspect the device and perform the necessary actions."
    },
    {
      "text": "Household A is offline",
      "time": "3:00 PM",
      "date": getYesterdayDate(),
      "description": "Household A is currently offline. Please check the connection or power supply to restore connectivity."
    },
    {
      "text": "Energy usage is lower than expected",
      "time": "8:00 AM",
      "date": "2024-02-18",
      "description": "Energy consumption is significantly lower than expected. Investigate whether any devices are malfunctioning or turned off unexpectedly."
    },
  ];

  // Sample households
  static List<Map<String, dynamic>> _households = [
    {'name': "Household A", 'energy': "150 kWh"},
    {'name': "Household B", 'energy': "120 kWh"},
    {'name': "Household C", 'energy': "180 kWh"},
  ];

  static List<Map<String, dynamic>> get households => _households;

  static set households(List<Map<String, dynamic>> newHouseholds) {
    _households = newHouseholds;
  }
}
