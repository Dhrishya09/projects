import 'package:flutter/material.dart';
import 'settings_item.dart'; // Import the SettingsItem model

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;
 
  const SettingsSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          color: Colors.blueGrey[50],
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: items
                .map((item) => ListTile(
                      leading: Icon(item.icon, color: Colors.black),
                      title: Text(item.text),
                      onTap: item.onTap, // Add navigation or functionality later
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
