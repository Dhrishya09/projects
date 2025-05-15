import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/pages/home/terms_conditions.dart';
import 'package:flutter_application_1/pages/home/account_verification.dart';
import 'package:flutter_application_1/pages/home/login_page.dart';

class SignUpPage extends StatefulWidget {
  final String householdName;
  final String userEmail;

  SignUpPage({required this.householdName, required this.userEmail});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController householdNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  final TextEditingController userDobController = TextEditingController();
  final TextEditingController userPhoneController = TextEditingController();

  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    householdNameController.text = widget.householdName; // prefilled from invite
    userEmailController.text = widget.userEmail; // prefilled from invite
  }

  void registerUser() async {
    final response = await http.post(
      Uri.parse('https://home-app-06fba5e133bf.herokuapp.com/register_user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'household_name': householdNameController.text,
        'user_name': userNameController.text,
        'user_email': userEmailController.text,
        'user_password': userPasswordController.text,
        'user_dob': userDobController.text,
        'user_phone': userPhoneController.text,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationPage(
            email: userEmailController.text.trim(),
            name: userNameController.text.trim(),
            password: userPasswordController.text,
            dob: userDobController.text,
            phone: userPhoneController.text.trim(),
            householdName: householdNameController.text.trim(),
            isManager: false,
            houseId: '',
          ),
        ),
      );
    } else {
      print("Failed to register user");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register. Please try again.')),
      );
    }
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'JOIN HOUSEHOLD',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: householdNameController,
                      labelText: 'Household Name',
                      hintText: 'Enter Household Name',
                      enabled: false,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: userEmailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      enabled: false,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: userNameController,
                      labelText: 'User Name',
                      hintText: 'Enter your name',
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: userPasswordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: userDobController,
                      labelText: 'Date of Birth',
                      hintText: 'Enter your date of birth',
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: userPhoneController,
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              children: [
                                const TextSpan(text: "I have read, understood, and agreed with the "),
                                TextSpan(
                                  text: "Terms and Conditions and Privacy Policy",
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isChecked
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade500,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: registerUser,
                              child: const Text(
                                'Join Household',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Container(), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: Implement new manager signup functionality here.

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
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
          borderSide: const BorderSide(color: Color.fromARGB(255, 3, 85, 152), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color.fromARGB(255, 183, 17, 5), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color.fromARGB(255, 183, 17, 5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
    );
  }
}


