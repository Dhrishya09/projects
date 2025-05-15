import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isObscure = true;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _showResendButton = false;
  String? _enteredOtp;
  String? _email; // Add email field to store the email address
  
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

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    bool success = await BackendService.verifyOtp(_email!, _enteredOtp!);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        _isOtpVerified = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid verification code!')),
      );
    }
  }

  void _resetPassword() async {
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password fields cannot be empty!')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await BackendService.resetPassword({
      'email': _email,
      'verification_code': _enteredOtp,
      'new_password': password,
    });

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reset password. Please try again.')),
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
                      'RESET PASSWORD',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!_isOtpVerified) ...[
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

                    if (_isOtpVerified) ...[
                      const SizedBox(height: 20),

                      _buildPasswordField("New Password", _passwordController),
                      const SizedBox(height: 15),
                      _buildPasswordField("Confirm Password", _confirmPasswordController),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
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
                                'CONFIRM PASSWORD',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        filled: true,
        fillColor: Colors.black.withAlpha(140),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }
}
