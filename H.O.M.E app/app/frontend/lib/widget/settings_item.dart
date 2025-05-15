import 'package:flutter/material.dart';

class SettingsItem {
  final IconData icon;
  final String text;
  final VoidCallback? onTap; // Added onTap

  SettingsItem({required this.icon, required this.text, this.onTap});
}

