import 'package:flutter/material.dart';
import 'homeuser_main.dart';
import 'device_control/device_co.dart';
import '../graph.dart';
import '../settings/settings_user.dart';  // modified import

class NavPage extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const NavPage({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(" ")),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _navigateToPage(context, index), // Navigation is here
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: "Devices"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Graphs"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomeuserMain(email: '',);
        break;
      case 1:
        nextPage = device_co(rooms: [],);
        break;
      case 2:
        nextPage = Graph();
        break;
      case 3:
        nextPage = SettingsUserPage();
        break;
      default:
        nextPage = HomeuserMain(email: '',);
    }

    if (index != currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }
}
