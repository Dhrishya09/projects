// import 'package:flutter/material.dart';
// import '../user/nav.dart';

// class RateUsPage extends StatelessWidget {
//   const RateUsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return NavPage(
//       currentIndex: 3,
//       child: Scaffold(
//         appBar: AppBar(title: const Text("Rate Us")),
//         body: const Center(child: Text("Rate Us Content")),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../user/nav.dart'; // Ensure this import points to your NavPage

class RateUsPage extends StatelessWidget {
  const RateUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavPage(
      currentIndex: 3, // Assuming 3 is the index for the Rate Us page
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Rate Us"),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
            gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 199, 227, 250), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(    
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 199, 227, 250), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "How would you rate your experience?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const StarRatingWidget(), // Custom widget for star rating
                const SizedBox(height: 20),
                const Text(
                  "Tell us more about your experience",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Write your feedback here...",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedButton(), // Custom animated submit button
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Star Rating Widget
class StarRatingWidget extends StatefulWidget {
  const StarRatingWidget({super.key});

  @override
  _StarRatingWidgetState createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(4),
            transform: index < _rating
                ? (Matrix4.identity()..scale(1.2))
                : Matrix4.identity(),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 40,
            ),
          ),
        );
      }),
    );
  }
}

// Custom Animated Submit Button
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({super.key});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    // Handle submit action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for your feedback!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color.fromARGB(255, 254, 254, 254), const Color.fromARGB(255, 255, 255, 255)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 26, 129, 239).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}