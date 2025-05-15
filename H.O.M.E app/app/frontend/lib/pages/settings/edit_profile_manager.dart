import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart'; // <-- added import
import 'package:flutter_application_1/pages/settings/settings_manager.dart'; // <-- was previously from /pages/manager/settings_manager.dart
import 'package:flutter_application_1/pages/manager/homepage_manager.dart';
import 'package:flutter/foundation.dart'; // added for kIsWeb
import 'dart:convert'; // new import for base64 handling

class EditProfileManager extends StatefulWidget {
  const EditProfileManager({super.key});

  @override
  State<EditProfileManager> createState() => _EditProfileManagerState();
}

class _EditProfileManagerState extends State<EditProfileManager> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _profilePic = "";
  final ImagePicker _picker = ImagePicker();
  bool _hasNewProfilePic = false; // NEW FLAG

  @override
  void initState() {
    super.initState();
    _fetchManagerProfile();
  }

  void _fetchManagerProfile() async {
    String email = BackendService.session.email ?? "";
    String household = BackendService.session.householdName ?? "";
    Map<String, dynamic>? details = await BackendService.fetchUserDetails(
      email: email,
      householdName: household,
    );
    if (details != null) {
      // Update controllers and also update session properties if not set.
      setState(() {
        _usernameController.text = details['manager_name'] ?? '';
        _emailController.text = details['manager_email'] ?? '';
        _phoneController.text = details['manager_phone'] ?? '';
        _profilePic = details['manager_profile_pic'] ?? "";
      });
      // Update session so that later API calls have the needed house id and email.
      if (BackendService.session.houseId == null && details['house_id'] != null) {
        BackendService.session.houseId = details['house_id'];
      }
      if (BackendService.session.email == null && details['manager_email'] != null) {
        BackendService.session.email = details['manager_email'];
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profilePic = base64Encode(bytes);
          _hasNewProfilePic = true;
        });
      } else {
        setState(() {
          _profilePic = pickedFile.path;
          _hasNewProfilePic = true;
        });
      }
      // Image preview updates and Save button now appears.
    }
  }

  // New method to save the profile picture.
  Future<void> _saveProfilePic() async {
    // Ensure houseId and email are available before sending the update payload.
    if (BackendService.session.houseId == null || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('House ID or Manager email missing!')),
      );
      return;
    }

    final Map<String, dynamic> payload = {
      'manager_profile_pic': _profilePic,
      'house_id': BackendService.session.houseId,
      'manager_email': _emailController.text.trim(),
    };

    print('Saving profile pic with payload: $payload'); // Debug output

    bool success = await BackendService.updateManagerProfile(payload);
    if (success) {
      setState(() {
        _hasNewProfilePic = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile picture.')),
      );
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      Map<String, String> updateData = {};
      if (_usernameController.text.trim().isNotEmpty) {
        updateData['manager_name'] = _usernameController.text.trim();
      }
      if (_emailController.text.trim().isNotEmpty) {
        updateData['manager_email'] = _emailController.text.trim();
      }
      if (_phoneController.text.trim().isNotEmpty) {
        updateData['manager_phone'] = _phoneController.text.trim();
      }
      if (_passwordController.text.trim().isNotEmpty) {
        updateData['manager_password'] = _passwordController.text.trim();
      }
      bool success = await BackendService.updateManagerProfile(updateData);
      setState(() { _isLoading = false; });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage2()),
        );
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
              MaterialPageRoute(builder: (context) => const SettingsPage2()),
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
                child: _profilePic.isNotEmpty
                    ? (kIsWeb 
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: MemoryImage(base64Decode(_profilePic)),
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(File(_profilePic)),
                          ))
                    : const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Change Picture"),
                ),
                const SizedBox(width: 10),
                if (_hasNewProfilePic)
                  ElevatedButton(
                    onPressed: _saveProfilePic,
                    child: const Text("Save Profile Pic"),
                  ),
              ],
            ),
            _buildTextField("Manager Name", _usernameController),
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