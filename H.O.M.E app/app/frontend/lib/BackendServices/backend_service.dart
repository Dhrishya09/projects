import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

// New session data container for dynamic session management.
class SessionData {
  String? email;
  String? householdName;
  String? houseId; // new field to store actual house document ID
  String? accountType;
  String? userId; // New field for user id
  String? managerName; // new field for manager name
  // ...other fields as needed...
}

class BackendService {
  static const String baseUrl = 'https://home-app-06fba5e133bf.herokuapp.com';
  static const String apiKey = 'AIzaSyChxt9MC19V6rRcM75NnYb93v9KgGVExCw';

  // Static session container for dynamic session values.
  static SessionData session = SessionData();

  static void updateSession({
    required String accountType,
    required String email,
    required String householdName,
    required String houseId, // New parameter
  }) {
    session.accountType = accountType;
    session.email = email;
    session.householdName = householdName;
    session.houseId = houseId; // Store the house document ID
  }

  static void clearSession() {
    session = SessionData();
  }

  // Add this method for debugging API endpoints.
  static void logApiConfig() {
    print("Base URL: $baseUrl");
    print("Login endpoint: $baseUrl/login");
    // ...log other endpoints as needed...
  }

  // Call logApiConfig() early on app startup for quick diagnostics.

  // ---- Login Endpoint (Unified) ----
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({'email': email, 'password': password});
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: body,
      );

      print("Raw login response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        session.email = email;
        session.accountType = responseData["account_type"];
        // If the response has a house_id field (e.g., for managers):
        if (responseData.containsKey("house_id")) {
          session.houseId = responseData["house_id"];
        }
        // Also update session.householdName if available:
        if (responseData.containsKey("manager")) {
          session.householdName =
              responseData["manager"]["household_name"] ?? "";
        }
        return responseData;
      } else {
        // Handle error appropriately.
        print('Error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // ---- Registration Endpoints for Manager and User ----
  static Future<Map<String, dynamic>?> registerManager(Map<String, dynamic> managerData) async {
    final url = Uri.parse('$baseUrl/register_manager');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonEncode(managerData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        session.email = managerData['email'];
        session.householdName = responseData["household_name"];
        session.houseId = responseData["house_id"]; // assign houseId
        return responseData; // Now returns a Map with e.g. {"message": "Verification code sent to email", "house_id": "..."}
      } else {
        // Handle error
        print('Error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during registerManager: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> registerUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/register_user');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        session.email = userData['email'];
        session.householdName = responseData["household_name"];
        session.houseId = responseData["house_id"]; // assign houseId
        return responseData; // Returns the response with house_id
      } else {
        // Handle error
        print('Error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during registerUser: $e');
      return null;
    }
  }

  // ---- Verification Endpoints for Manager and User ----
  // (Create similar methods for verifyManager and verifyUser)
  static Future<bool> verifyManager(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/verify_manager');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        // Handle error
        print('Error: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during verifyManager: $e');
      return false;
    }
  }

  static Future<bool> verifyUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/verify_user');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        // Handle error
        print('Error: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during verifyUser: $e');
      return false;
    }
  }

  // ---- Resend Verification Code ----
  static Future<bool> resendVerificationCode(String email) async {
    final url = Uri.parse('$baseUrl/resend_verification_code');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200;
  }

  // ---- Fetch Devices (in a specific room) ----
  // This now sends a POST request with required fields.
  static Future<List<dynamic>?> getDevices({
    required String householdName,
    required String accountType,
    required String email,
    required String roomId,
  }) async {
    final url = Uri.parse('$baseUrl/fetch_devices_in_room');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({
        'household_name': householdName,
        'account_type': accountType,
        'email': email,
        'room_id': roomId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['devices'];
    } else {
      // Handle error
      return null;
    }
  }

  // ---- Fetch Rooms ----
  static Future<List<dynamic>?> fetchRooms({
    required String householdName,
    required String accountType,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/fetch_rooms');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({
        'household_name': householdName,
        'account_type': accountType,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['rooms'];
    } else {
      // Handle error
      return null;
    }
  }

  // ---- Toggle Device Status ----
  // Expects: household_name, account_type, email, room_id, device_name, device_type, and the desired new status.
  static Future<bool> toggleDevice({
    required String householdName,
    required String accountType,
    required String email,
    required String roomId,
    required String deviceName,
    required String deviceType,
    required bool deviceStatus,
  }) async {
    final url = Uri.parse('$baseUrl/toggle_device_status');
    final body = jsonEncode({
      'household_name': householdName,
      'account_type': accountType,
      'email': email,
      'room_id': roomId,
      'device_name': deviceName,
      'device_type': deviceType,
      'device_status': deviceStatus,
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: body,
    );

    return response.statusCode == 200;
  }

  // ---- Room Management Endpoints ----

  static Future<bool> addRoom({
    required String householdName,
    required String accountType,
    required String email,
    required String roomName,
  }) async {
    final url = Uri.parse('$baseUrl/add_room');
    final body = jsonEncode({
      'household_name': householdName,
      'account_type': accountType,
      'email': email,
      'room_name': roomName,
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: body,
    );

    return response.statusCode == 201;
  }

  static Future<bool> removeRoom({
    required String householdName,
    required String roomId,
  }) async {
    final url = Uri.parse('$baseUrl/remove_room');
    final body = jsonEncode({
      'household_name': householdName,
      'room_id': roomId,
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: body,
    );
    return response.statusCode == 200;
  }

  // ---- Password Reset, Account Deletion, and Invite Endpoints ----
  static Future<bool> forgetPassword(String email) async {
    final url = Uri.parse('$baseUrl/forget_password');
    final body = jsonEncode({'email': email});
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: body,
    );
    return response.statusCode == 200;
  }

  static Future<bool> resetPassword(Map<String, dynamic> data) async {
    // Data should include email, new password, and verification code
    final url = Uri.parse('$baseUrl/reset_password');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAccount(Map<String, dynamic> data) async {
    // Data should include email, household_name, and account_type
    final url = Uri.parse('$baseUrl/delete_account');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> sendInvite(Map<String, dynamic> data) async {
    // Data should include sender details and the invitee email or phone number.
    final url = Uri.parse('$baseUrl/send_invite');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  // ---- Add Device ----
  static Future<bool> addDevice(Map<String, dynamic> deviceData) async {
    final url = Uri.parse('$baseUrl/add_device');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(deviceData),
    );

    return response.statusCode == 201;
  }

  // ---- Fetch User Details ----
  static Future<Map<String, dynamic>?> fetchUserDetails({
    required String email,
    required String householdName,
  }) async {
    final url = Uri.parse('$baseUrl/fetch_user_details');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({
        'email': email,
        'household_name': householdName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user_details'];
    } else {
      // Handle error
      return null;
    }
  }

  // ---- Fetch Notifications ----
  static Future<List<Map<String, String>>?> fetchNotifications({
    required String email,
    required String householdName,
  }) async {
    final url = Uri.parse('$baseUrl/fetch_notifications');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({
        'email': email,
        'household_name': householdName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, String>>.from(data['notifications']);
    } else {
      // Handle error
      return null;
    }
  }

  static Future<List<String>?> fetchManagedHouseholds(String managerEmail) async {
    final url = Uri.parse('$baseUrl/fetch_managed_households');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({'manager_email': managerEmail}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['managed_households']);
    } else {
      // Handle error
      return null;
    }
  }

  static Future<bool> addHousehold(Map<String, dynamic> householdData) async {
    final url = Uri.parse('$baseUrl/add_household');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(householdData),
    );

    return response.statusCode == 201;
  }

  static Future<List<Map<String, String>>?> fetchHouseholdUsers(String managerEmail, String householdName) async {
    final url = Uri.parse('$baseUrl/fetch_household_users');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({
        'manager_email': managerEmail,
        'household_name': householdName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, String>>.from(data['users']);
    } else {
      // Handle error
      return null;
    }
  }

  static Future<bool> removeUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/remove_user');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(userData),
    );

    return response.statusCode == 200;
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify_otp');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    final url = Uri.parse('$baseUrl/update_user_profile');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'X-API-KEY': apiKey,},
      body: jsonEncode(profileData),
    );
    return response.statusCode == 200;
  }

  // SINGLE updateManagerProfile method declaration (remove duplicate declarations)
  static Future<bool> updateManagerProfile(Map<String, dynamic> updateData) async {
    final url = Uri.parse('$baseUrl/update_manager_profile');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonEncode(updateData),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Update failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  static Future<bool> updateSecuritySettings(Map<String, dynamic> securityData) async {
    final url = Uri.parse('$baseUrl/update_security_settings');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: jsonEncode(securityData),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> checkApiStatus() async {
    final url = Uri.parse('$baseUrl/status'); // Use the correct base URL
    try {
      final response = await http.get(url, headers: {'X-API-KEY': apiKey});
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error checking API status: $e');
    }
    return null;
  }

  static Future<String?> getRoomIdByName({
    required String householdName,
    required String roomName,
  }) async {
    try {
      if (householdName.isEmpty) {
        throw Exception("Household name must not be empty.");
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection("Houses")
          .doc(householdName)
          .collection("rooms")
          .where("room_name", isEqualTo: roomName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // Return the roomId
      }
      return null; // Room not found
    } catch (e) {
      print("Error fetching roomId: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchManagedHouseholdsExtended(String managerEmail) async {
    final url = Uri.parse('$baseUrl/fetch_managed_households');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'X-API-KEY': apiKey},
      body: jsonEncode({'manager_email': managerEmail}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Get the list of household names from the response.
      List<String> householdNames = List<String>.from(data['managed_households']);
      List<Map<String, dynamic>> result = [];
      // For each household name, query Firestore for the document ID and additional info.
      for (String householdName in householdNames) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("Houses")
            .where("household_name", isEqualTo: householdName)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          result.add({
            'id': doc.id,
            'name': doc.get("household_name") ?? householdName,
            'energy': "N/A", // or retrieve energy if available
          });
        }
      }
      return result;
    } else {
      print("Error fetching managed households: ${response.statusCode} ${response.body}");
      return null;
    }
  }
}


