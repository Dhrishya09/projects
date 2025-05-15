import 'package:flutter/material.dart';
import 'login_page.dart';  
import 'sign_up_user_manager.dart'; 

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
         
          Image.asset(
            'assets/bg.jpeg', 
            fit: BoxFit.cover,
          ),
          
          
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          
          
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 50), 

              
              Column(
                children: [
                  
                  SizedBox(
                    height: screenSize.height * 0.15,
                    child: Image.asset(
                      'assets/home_logo.png',
                      height: screenSize.height * 0.15, 
                    ),
                  ),

                  const SizedBox(height: 20), 

                  
                  const Text(
                    'H.O.M.E',
                    style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
              
              
              Padding(
                padding: EdgeInsets.only(bottom: screenSize.height * 0.1),
                child: Column(
                  children: [
                    
                    CustomGlassButton(
                      text: 'Sign Up',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 15),

                    
                    CustomGlassButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomGlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomGlassButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3), 
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5)), 
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.5),
                Colors.blueAccent.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 158, 200, 235).withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}