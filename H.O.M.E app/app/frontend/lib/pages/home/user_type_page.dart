import 'package:flutter/material.dart';

class UserTypePage extends StatelessWidget {
  const UserTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading
                const Text(
                  'User Type',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'The "User Type" defines how the system should be utilized and specifies the elements that need to be included for effective operation.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),

                // Home User Section
                _userTypeCard(
                  icon: Icons.person_outline,
                  title: "Home User",
                  description:
                      "Select this option if you wish to connect to elements within an individual house, such as lights, air conditioners, and other devices.",
                ),
                const SizedBox(height: 20),

                // Home Manager Section with House Icon
                _userTypeCard(
                  icon: Icons.house,
                  title: "Home Manager",
                  description:
                      "Select this option if you operate a system involving multiple households and want to connect to multiple households to monitor energy generation, consumption, and other related metrics for individual households.",
                ),
              ],
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 52, 61), // Blue-Grey header
        elevation: 4, // Adds a subtle shadow for depth
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'User Type Information',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
    );
  }

  // Custom Card Widget for User Types
  Widget _userTypeCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Semi-transparent card effect
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30), // Light border for subtle separation
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
