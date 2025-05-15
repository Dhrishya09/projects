import 'package:flutter/material.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool saveLoginInfo = true;

  void _toggleSaveLoginInfo(bool value) async {
    setState(() {
      saveLoginInfo = value;
    });

    // Replace with actual email and household name
    String email = 'user@example.com';
    String householdName = 'Household A';

    bool success = await BackendService.updateSecuritySettings({
      'email': email,
      'household_name': householdName,
      'save_login_info': saveLoginInfo,
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update security settings. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text("Security", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 10),
          _buildTile("Security alerts", Icons.security, onTap: () {}),
          _buildTile("Manage devices", Icons.devices, onTap: () {}),
          _buildTile("2-step verification", Icons.verified_user, trailing: Text("Off", style: TextStyle(color: Colors.grey)), onTap: () {}),
          _buildSwitchTile("Save login info", saveLoginInfo, _toggleSaveLoginInfo),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              "Log in to your account on all iCloud devices without entering credentials. Turning off removes saved info.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          SizedBox(height: 20),
          Text("Permissions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 10),
          _buildTile("Apps and services permissions", Icons.app_settings_alt, onTap: () {}),
          _buildTile("Browser settings", Icons.web, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon, color: Colors.black),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
