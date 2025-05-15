import 'package:flutter/material.dart';
import '../user/nav.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavPage(
      currentIndex: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text("About Us")),
        body: const Center(child: Text("About Us Content")),
      ),
    );
  }
}
