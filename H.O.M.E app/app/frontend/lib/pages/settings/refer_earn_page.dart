import 'package:flutter/material.dart';
import '../user/nav.dart';

class ReferAndEarnPage extends StatelessWidget {
  const ReferAndEarnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavPage(
      currentIndex: 3, // Profile section (assuming Refer & Earn is inside profile)
      child: Scaffold(
        appBar: AppBar(title: const Text("Refer & Earn")),
        body: const Center(child: Text("Refer & Earn Content")),
      ),
    );
  }
}

