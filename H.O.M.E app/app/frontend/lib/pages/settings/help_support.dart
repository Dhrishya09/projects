import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the Settings screen
          },
        ),
        title: const Text(
          "Help & Support",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text("Contact Support"),
              subtitle: const Text("Email us at support@example.com"),
              onTap: () {
                // Implement email functionality (optional)
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.blue),
              title: const Text("FAQs"),
              subtitle: const Text("Find answers to common questions"),
              onTap: () {
                // Navigate to a FAQ page if you have one
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.blue),
              title: const Text("Live Chat"),
              subtitle: const Text("Chat with a support agent"),
              onTap: () {
                // Implement chat functionality if needed
              },
            ),
          ],
        ),
      ),
    );
  }
}
