import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart'; // new import
import 'package:flutter_application_1/pages/home/splash_screen.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';
import 'package:flutter_application_1/pages/home/account_verification.dart'; // Corrected import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // use Firebase options for current platform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'H.O.M.E',
      home: SplashScreen(),
    );
  }
}

// Example usage of BackendService for login
void exampleLogin() async {
  String email = 'example@example.com';
  String password = 'password123';
  var response = await BackendService.login(email, password);
  if (response != null) {
    print('Login successful: $response');
  } else {
    print('Login failed');
  }
}

// New unified sign-up method to handle both Home Manager and Home User
void exampleSignUp(BuildContext context, String accountType, Map<String, dynamic> formData) async {
  Map<String, dynamic>? response;
  if (accountType == 'Home Manager') {
    response = await BackendService.registerManager(formData);
  } else if (accountType == 'Home User') {
    response = await BackendService.registerUser(formData);
  }
  if (response != null && response['message'] == 'Verification code sent to email') {
    final String houseId = response!['house_id']; // non-null assertion operator used here
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationPage(
          email: formData[accountType == 'Home Manager' ? 'manager_email' : 'user_email'],
          name: formData[accountType == 'Home Manager' ? 'manager_name' : 'user_name'],
          password: formData[accountType == 'Home Manager' ? 'manager_password' : 'user_password'],
          dob: formData[accountType == 'Home Manager' ? 'manager_dob' : 'user_dob'],
          phone: formData[accountType == 'Home Manager' ? 'manager_phone' : 'user_phone'],
          householdName: formData['household_name'],
          address: formData['address'] ?? "",
          houseId: houseId, // safely passed actual house id
          isManager: accountType == 'Home Manager',
        ),
      ),
    );
  } else {
    print('Registration failed for $accountType account. Check backend configuration.');
  }
}

// Updated example usage of BackendService for registration with navigation support.
void exampleRegisterManager(BuildContext context) async {
  Map<String, dynamic> managerData = {
    'household_name': 'Example Household',
    'address': '123 Example St',
    'manager_name': 'John Doe',
    'manager_email': 'manager@example.com',
    'manager_password': 'password123',
    'manager_dob': '1990-01-01',
    'manager_phone': '1234567890',
  };
  Map<String, dynamic>? response = await BackendService.registerManager(managerData);
  if (response != null && response['message'] == 'Verification code sent to email') {
    final String houseId = response!['house_id']; // use non-null assertion
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationPage(
          email: managerData['manager_email'],
          name: managerData['manager_name'],
          password: managerData['manager_password'],
          dob: managerData['manager_dob'],
          phone: managerData['manager_phone'],
          householdName: managerData['household_name'],
          address: managerData['address'],
          houseId: houseId, // pass actual house id returned by backend
          isManager: true,
        ),
      ),
    );
  } else {
    print(
      'Manager registration failed. This might be due to a CORS or XMLHttpRequest error. Please check your backend configuration.'
    );
  }
}

Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Image.asset('assets/home_logo.png'), // Ensure the correct path here.
    ),
  );
}