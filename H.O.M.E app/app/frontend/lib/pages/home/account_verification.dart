import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import '../../BackendServices/backend_service.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final String dob;
  final String phone;
  final String householdName;
  final String houseId; // NEW parameter for the incremental house document id
  final String? address; // optional for Home Manager
  final bool isManager; // new parameter

  const VerificationPage({
    super.key,
    required this.email,
    required this.name,
    required this.password,
    required this.dob,
    required this.phone,
    required this.householdName,
    required this.houseId, // pass the house id from registration
    this.address,
    this.isManager = false,
  });

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _showResendButton = false;
  String? _enteredOtp;
  
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _timerSeconds = 30;
      _showResendButton = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _showResendButton = true;
          _timer?.cancel();
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_enteredOtp == null || _enteredOtp!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final url = widget.isManager
        ? Uri.parse('${BackendService.baseUrl}/verify_manager')
        : Uri.parse('${BackendService.baseUrl}/verify_user');
    final requestBody = widget.isManager
        ? {
            'manager_email': widget.email,
            'verification_code': _enteredOtp,
            'manager_name': widget.name,
            'manager_password': widget.password,
            'manager_dob': widget.dob,
            'manager_phone': widget.phone,
            'house_id': widget.houseId, // use the incremental house id
            'address': widget.address ?? ""
          }
        : {
            'user_email': widget.email,
            'verification_code': _enteredOtp,
            'user_name': widget.name,
            'user_password': widget.password,
            'user_dob': widget.dob,
            'user_phone': widget.phone,
            'house_id': widget.householdName, // for user, householdName remains the lookup key
            'address': widget.address ?? ""
          };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': BackendService.apiKey,
      },
      body: jsonEncode(requestBody),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      setState(() {
        _isOtpVerified = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid verification code!')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          Container(color: Colors.black.withOpacity(0.7)),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Email Verification',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Enter the 6-digit code sent to your email",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    OtpTextField(
                      numberOfFields: 6,
                      borderColor: Colors.blueGrey,
                      focusedBorderColor: Colors.blue,
                      showFieldAsBox: true,
                      fieldWidth: 45,
                      textStyle: const TextStyle(color: Colors.white, fontSize: 18),
                      onSubmit: (String verificationCode) {
                        setState(() {
                          _enteredOtp = verificationCode;
                        });
                      },
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'VERIFY CODE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 15),
                    _showResendButton
                        ? TextButton(
                            onPressed: () {
                              _startResendTimer();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Verification code resent!')),
                              );
                            },
                            child: const Text(
                              "Didn't receive a code? Resend",
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        : Text(
                            "Resend code in $_timerSeconds seconds",
                            style: const TextStyle(color: Colors.white70),
                          ),
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
