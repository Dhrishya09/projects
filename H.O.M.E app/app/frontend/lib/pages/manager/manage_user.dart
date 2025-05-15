import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'bottom_nav_manager.dart';
import 'add_user.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';
import 'package:flutter_application_1/main.dart'; // <-- add this to import routeObserver

class ManageUsersPage extends StatefulWidget {
  final String email; // Add email parameter
  const ManageUsersPage({super.key, required this.email});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> with RouteAware {
  late final String _managerEmail; // store trimmed email
  String selectedHousehold = ''; // will store the House document ID
  Map<String, List<Map<String, String>>> householdUsers = {};
  List<Map<String, String>> households = [];
  bool _showPopup = false;

  @override
  void initState() {
    super.initState();
    // Fallback to session email if widget.email is empty
    _managerEmail = widget.email.trim().isEmpty 
        ? (BackendService.session.email ?? "") 
        : widget.email.trim();
    print("ManageUsersPage: Using manager email: $_managerEmail");
    _fetchHouseholds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the global RouteObserver defined in main.dart
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh data when returning to this page from another
    _fetchHouseholds();
    _fetchHouseholdUsers();
  }

  void _fetchHouseholds() async {
    if (_managerEmail.isEmpty) {
      print("Error: Manager email is empty.");
      return;
    }
    // Use the household name from the session.
    String? currentHousehold = BackendService.session.householdName;
    // If household is null, empty, or "Unknown", fetch managed households from backend.
    if (currentHousehold == null || currentHousehold.isEmpty || currentHousehold == "Unknown") {
      List<String>? managedHouseholds = await BackendService.fetchManagedHouseholds(_managerEmail);
      if (managedHouseholds != null && managedHouseholds.isNotEmpty) {
        currentHousehold = managedHouseholds.first;
        // Update the session with the fetched household name.
        BackendService.session.householdName = currentHousehold;
      } else {
        print("Current household not found for manager: $_managerEmail");
        return;
      }
    }
    print("Fetching house document for household: $currentHousehold");
    final querySnapshot = await FirebaseFirestore.instance
        .collection("Houses")
        .where("household_name", isEqualTo: currentHousehold)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        selectedHousehold = querySnapshot.docs.first.id;
        households = [{'name': currentHousehold!, 'energy': 'N/A'}];
        _fetchHouseholdUsers();
      });
    } else {
      print("No house document found for household: $currentHousehold");
    }
  }

  void _fetchHouseholdUsers() async {
    List<Map<String, String>>? users = await BackendService.fetchHouseholdUsers(_managerEmail, households.isNotEmpty ? households[0]['name']! : "");
    if (users != null) {
      setState(() {
        householdUsers[selectedHousehold] = users;
      });
    }
  }

  void _navigateToAddUserPage() async {
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage(managerEmail: _managerEmail)), // Pass manager email
    );

    if (newUser != null && newUser is Map<String, String>) {
      setState(() {
        householdUsers[selectedHousehold]?.add(newUser);
        _showPopup = true;
      });
    }
  }

  void _removeUser(int index) async {
    bool success = await BackendService.removeUser({
      'manager_email': _managerEmail,
      'household_name': selectedHousehold,
      'user_email': householdUsers[selectedHousehold]![index]['email']!,
    });

    if (success) {
      setState(() {
        householdUsers[selectedHousehold]?.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User removed and email notification sent!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove user. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent Firestore query if selectedHousehold is empty:
    if (selectedHousehold.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users"),
        backgroundColor: const Color.fromARGB(255, 153, 199, 237),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Houses")
            .doc(selectedHousehold) // Now guaranteed non-empty
            .collection("house_user")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final users = snapshot.data!.docs;
          return Column(
            children: [
              Row(
                children: [
                  Text("Users: ${users.length}", style: TextStyle(fontSize: 18)),
                  // ...existing UI elements...
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var userData = users[index].data();
                    String joinDate = userData["joined_at"] ?? "Unknown";
                    return Card(
                      child: ListTile(
                        title: Text(userData["user_name"] ?? ""),
                        subtitle: Text("Joined: $joinDate"),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            _removeUser(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToAddUserPage,
                icon: Icon(Icons.person_add),
                label: Text("Add User"),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 1),
    );
  }
}
