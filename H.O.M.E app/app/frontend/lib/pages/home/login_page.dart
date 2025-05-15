import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/manager/homepage_manager.dart';
import 'package:flutter_application_1/pages/user/homeuser_main.dart';
import 'forgot_password.dart'; 
// import 'sign_up.dart';
import '../../BackendServices/backend_service.dart';
import 'sign_up_user_manager.dart'; // Import the backend service

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _householdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool staySignedIn = false;
  bool _showForgotPassword = false;

  String? validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final response = await BackendService.login(email, password);
      print("Login API response: $response");
      if (response != null && response['message'] != null) {
        if (response['message'] == 'Manager logged in successfully') {
          // Manager uses real data fetched from the backend/database.
          BackendService.updateSession(
            accountType: response["account_type"],
            email: email,
            householdName: response["manager"]?["household_name"] ?? "",
            houseId: response.containsKey("house_id") ? response["house_id"] : "",
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeManagerPage(email: email)),
          );
        } else if (response['message'] == 'User logged in successfully') {
          // User uses dummy login logic.
          const dummyUserEmail = "avsd2000@hw.ac.uk";
          BackendService.updateSession(
            accountType: "user",
            email: dummyUserEmail,
            householdName: "Dummy Household", // dummy static value
            houseId: "dummy_house_id",        // dummy static value
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeuserMain(email: dummyUserEmail)),
          );
        } else {
          setState(() => _showForgotPassword = true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed due to incomplete data.")));
      }
    }
  }

  Future<void> _checkApiStatus() async {
    final response = await BackendService.checkApiStatus();
    if (response != null && response['status'].toString().toLowerCase() == 'ok') {
      print('API is live and running');
    } else {
      print('API is not reachable');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkApiStatus(); // Check API status when the page initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bg.jpeg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withAlpha(200),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _householdController,
                        labelText: 'Household Name',
                        hintText: 'Enter Household Name',
                        validator: (value) =>
                            validateField(value, 'Household Name'),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        validator: (value) => validateField(value, 'Email'),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        obscureText: true,
                        validator: validatePassword,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade500,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_showForgotPassword)
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage()),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: staySignedIn,
                            onChanged: (value) {
                              setState(() {
                                staySignedIn = value!;
                              });
                            },
                            activeColor: Colors.blueGrey,
                          ),
                          const Text('Stay Signed In',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {   
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SignUpPage()), 
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => AuthService().signInWithGoogle(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/google_logo.png',
                                height: 24,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color.fromARGB(208, 245, 240, 240)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white.withOpacity(0.24), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 3, 85, 152), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 183, 17, 5), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 183, 17, 5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
    );
  }
}
