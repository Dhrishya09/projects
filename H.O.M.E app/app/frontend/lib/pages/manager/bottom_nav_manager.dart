import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/settings/settings_manager.dart';
import 'homepage_manager.dart';
import 'manage_user.dart';
import 'graphs_homemanager.dart';

// Updated function signature to make 'currentUserEmail' optional with a default value.
BottomNavigationBar buildBottomNavigationBar(BuildContext context, int currentIndex, [String currentUserEmail = '']) {
 return BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    onTap: (index) {
      if (index != currentIndex) {  
        Widget? nextPage;
        switch (index) {
          case 0:
            nextPage = HomeManagerPage(email: currentUserEmail);
            break;
          case 1:
            nextPage = ManageUsersPage(email: currentUserEmail);
            break;
          case 2:
            nextPage = EnergyAnalyticsApp();
            break;
          case 3:
            nextPage = SettingsPage2();
            break;
        }
        if (nextPage != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextPage!),
          );
        }
      }
    },
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.people), label: "Manage Users"),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Graphs"),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
    ],
  );
}
