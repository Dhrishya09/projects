import 'package:flutter/material.dart';
import 'terms_conditions.dart';
import '../user/homeuser_main.dart';
import '../manager/homepage_manager.dart';
import 'package:flutter/gestures.dart';
import 'user_type_page.dart';
import 'account_verification.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart'; // Import the backend service
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // New controllers for additional fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _householdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Add this line
  final FocusNode passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>(); 
  
  String? selectedUserType;
  bool showNextButton = false;
  bool isTermsAccepted = false;
  bool showPasswordCriteria = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;
  bool passwordsMatch = true;
  bool confirmPasswordInteracted = false;

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() {
      if (!passwordFocusNode.hasFocus) {
        setState(() {
          showPasswordCriteria = false;
        });
      }
    });
  }
  void _selectUserType(String userType) {
  setState(() {
    selectedUserType = userType;
    showNextButton = true; 
  });
  print("Selected Role: $selectedUserType, Show Next Button: $showNextButton");
}

  void _checkPasswordMatch() {
    setState(() {
      passwordsMatch = passwordController.text == confirmPasswordController.text;
    });
  }
  void _onFieldTapped() {
    if (hasUppercase && hasLowercase && hasNumber && hasSpecialChar && hasMinLength) {
      setState(() {
        showPasswordCriteria = false;
      });
    }
  }
  void _validatePassword(String value) {
  setState(() {
    hasUppercase = value.contains(RegExp(r'[A-Z]'));
    hasLowercase = value.contains(RegExp(r'[a-z]'));
    hasNumber = value.contains(RegExp(r'[0-9]'));
    hasSpecialChar = value.contains(RegExp(r'[@\$!%*?&#]'));
    hasMinLength = value.length >= 6;

    bool allCriteriaMet = hasUppercase && hasLowercase && hasNumber && hasSpecialChar && hasMinLength;
    showPasswordCriteria = !allCriteriaMet; 
  });

  _checkPasswordMatch();
}

// New helper to send the verification code using the entered email
Future<void> _sendVerificationCode(String email) async {
  final url = Uri.parse('https://home-app-06fba5e133bf.herokuapp.com/resend_verification_code');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'X-API-KEY': BackendService.apiKey, // Add API key header
    },
    body: jsonEncode({ 'email': email }),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to send verification code: ${response.statusCode}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/bg.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: selectedUserType == null ? _roleSelection() : _signUpForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _roleSelection() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select Your Role",
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserTypePage()),
              );
            },
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _roleOption("Home User"),
          const SizedBox(width: 15),
          _roleOption("Home Manager"),
        ],
      ),
      const SizedBox(height: 20),
      if (showNextButton) 
        ElevatedButton(
          onPressed: () {
            print("Navigating to next screen, Selected role: $selectedUserType");
            if (selectedUserType == "Home User") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeuserMain(email: '',)),
              );
            } else if (selectedUserType == "Home Manager") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeManagerPage(email: _emailController.text.trim())), // Pass email
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text("Next", style: TextStyle(color: Colors.white)),
        ),
    ],
  );
}





  Widget _roleOption(String role) {
    return GestureDetector(
      onTap: () => _selectUserType(role),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selectedUserType == role ? Colors.blue : Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        child: Column(
          children: [
            Icon(role == "Home User" ? Icons.person : Icons.home, color: Colors.white, size: 30),
            const SizedBox(height: 5),
            Text(role, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _signUpForm() {
  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Sign Up", style: TextStyle(fontSize: 28, color: Colors.white)),
        const SizedBox(height: 20),
        // Pass controllers to capture user input
        _inputField("Name", controller: _nameController),
        _inputField("Email", keyboardType: TextInputType.emailAddress, controller: _emailController),
        _inputField("Household Name", controller: _householdController),
        _inputField("Phone Number", keyboardType: TextInputType.phone, controller: _phoneController),
        _dobField(),
        if (selectedUserType == "Home Manager") _inputField("Address", controller: addressController),
        _passwordField("Password", passwordController, _validatePassword, required: true),

        
        if (showPasswordCriteria) 
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _passwordCriteria(),
          ),

        
        _passwordField("Confirm Password", confirmPasswordController, (_) {
          setState(() {
            confirmPasswordInteracted = true;
            _checkPasswordMatch();
          });
        }),

        
        if (confirmPasswordInteracted && !passwordsMatch)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              "Passwords do not match",
              style: TextStyle(color: Colors.red[300], fontSize: 14),
            ),
          ),

        _termsAndConditions(),
        const SizedBox(height: 20), 
        _signUpButton(),
      ],
    ),
  );
}


  Widget _inputField(String label, {TextInputType keyboardType = TextInputType.text, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.24),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller, Function(String) onChanged, {bool required = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      focusNode: label == "Password" ? passwordFocusNode : null, 
      controller: controller,
      obscureText: true,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return "$label is required";
        }
        return null;
      },
    ),
  );
}
  Widget _passwordCriteria() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 5), 
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _passwordCriteriaItem("At least 6 characters", hasMinLength),
        const SizedBox(height: 4), 
        _passwordCriteriaItem("At least one uppercase letter", hasUppercase),
        const SizedBox(height: 4),
        _passwordCriteriaItem("At least one lowercase letter", hasLowercase),
        const SizedBox(height: 4),
        _passwordCriteriaItem("At least one number", hasNumber),
        const SizedBox(height: 4),
        _passwordCriteriaItem("At least one special character (@\$!%*?&#)", hasSpecialChar),
      ],
    ),
  );
}

  Widget _passwordCriteriaItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _dobField({bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: _onFieldTapped,
        child: TextFormField(
          controller: dobController,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Date of Birth",
            labelStyle: const TextStyle(color: Colors.white70),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.24),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              dobController.text = "${picked.day}/${picked.month}/${picked.year}";
            }
          },
          validator: (value) {
            if (required && (value == null || value.isEmpty)) {
              return "Date of Birth is required";
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _termsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: isTermsAccepted,
          activeColor: Colors.blue,
          onChanged: (value) => setState(() => isTermsAccepted = value ?? false),
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
    );
  }

  Widget _signUpButton() {
  return Center(
    child: ElevatedButton(
      onPressed: isTermsAccepted
          ? () async {
              if (_formKey.currentState?.validate() ?? false) {
                if (selectedUserType == "Home Manager") {
                  final Map<String, dynamic> managerData = {
                    'household_name': _householdController.text.trim(),
                    'address': addressController.text.trim(),
                    'manager_name': _nameController.text.trim(),
                    'manager_email': _emailController.text.trim(),
                    'manager_password': passwordController.text,
                    'manager_dob': dobController.text,
                    'manager_phone': _phoneController.text.trim(),
                  };
                  final response = await BackendService.registerManager(managerData);
                  if (response != null && response['message'] == 'Verification code sent to email') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerificationPage(
                        email: _emailController.text.trim(),
                        name: _nameController.text.trim(),
                        password: passwordController.text,
                        dob: dobController.text,
                        phone: _phoneController.text.trim(),
                        householdName: _householdController.text.trim(),
                        houseId: response['house_id'], // using backend house_id
                        address: addressController.text.trim(),
                        isManager: true,
                      )),
                    );
                  } else {
                    print('Registration failed for Home Manager account.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration failed. Please check your details and try again.')),
                    );
                  }
                } else if (selectedUserType == "Home User") {
                  final Map<String, dynamic> userData = {
                    'household_name': _householdController.text.trim(),
                    'user_name': _nameController.text.trim(),
                    'user_email': _emailController.text.trim(),
                    'user_password': passwordController.text,
                    'user_dob': dobController.text,
                    'user_phone': _phoneController.text.trim(),
                  };
                  final response = await BackendService.registerUser(userData);
                  if (response != null && response['message'] == 'Verification code sent to email') {
                    BackendService.session.householdName = _householdController.text.trim();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerificationPage(
                        email: _emailController.text.trim(),
                        name: _nameController.text.trim(),
                        password: passwordController.text,
                        dob: dobController.text,
                        phone: _phoneController.text.trim(),
                        householdName: _householdController.text.trim(),
                        houseId: response['house_id'], // using backend house_id
                        address: "", // not required for Home User
                        isManager: false,
                      )),
                    );
                  } else {
                    print('Registration failed for Home User account.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration failed. Please check your details and try again.')),
                    );
                  }
                }
              }
            }
          : null,
      style: ElevatedButton.styleFrom(backgroundColor: isTermsAccepted ? Colors.blue : Colors.grey),
      child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
    ),
  );
  }
}
