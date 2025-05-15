import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';
import 'package:flutter_application_1/pages/settings/settings_user.dart'; // Assumed user settings page
import 'package:flutter_application_1/pages/user/homeuser_main.dart'; // added import

class EditProfileUser extends StatefulWidget {
  const EditProfileUser({super.key});

  @override
  State<EditProfileUser> createState() => _EditProfileUserState();
}

class _EditProfileUserState extends State<EditProfileUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _profilePic = "";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    String email = BackendService.session.email ?? "";
    String household = BackendService.session.householdName ?? "";
    Map<String, dynamic>? details = await BackendService.fetchUserDetails(
      email: email,
      householdName: household,
    );
    if (details != null) {
      setState(() {
        _usernameController.text = details['user_name'] ?? '';
        _emailController.text = details['user_email'] ?? '';
        _phoneController.text = details['user_phone'] ?? '';
        _profilePic = details['profile_pic'] ?? "";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _profilePic = pickedFile.path;
      });
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Map<String, String> updateData = {};
      if (_usernameController.text.trim().isNotEmpty) {
        updateData['user_name'] = _usernameController.text.trim();
      }
      if (_emailController.text.trim().isNotEmpty) {
        updateData['user_email'] = _emailController.text.trim();
      }
      if (_phoneController.text.trim().isNotEmpty) {
        updateData['user_phone'] = _phoneController.text.trim();
      }
      if (_passwordController.text.trim().isNotEmpty) {
        updateData['user_password'] = _passwordController.text.trim();
      }
      bool success = await BackendService.updateUserProfile(updateData);
      setState(() {
        _isLoading = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeuserMain(email: '',)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsUserPage()),
            );
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: _profilePic.isNotEmpty && File(_profilePic).existsSync()
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(File(_profilePic)),
                      )
                    : const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Change Picture"),
              ),
            ),
            _buildTextField("User Name", _usernameController),
            _buildTextField("Email", _emailController),
            _buildTextField("Phone Number", _phoneController),
            _buildPasswordField(),
            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text("Update Profile"),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.blue[50],
        ),
        validator: (value) => (value == null || value.trim().isEmpty) ? '$label cannot be empty' : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: "Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.blue[50],
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}