import 'package:flutter/material.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';

class AddUserPage extends StatefulWidget {
  final String managerEmail; // Add manager email parameter
  const AddUserPage({super.key, required this.managerEmail});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  String selectedHousehold = '';
  String userName = '';
  String userEmail = '';

  List<String> households = [];

  @override
  void initState() {
    super.initState();
    // Optionally, if the manager is tied to a single household, prefill the dropdown.
    String? currentHousehold = BackendService.session.householdName;
    if (currentHousehold != null && currentHousehold.isNotEmpty) {
      setState(() {
        households = [currentHousehold];
        selectedHousehold = currentHousehold;
      });
    } else {
      _fetchHouseholds();
    }
  }

  void _fetchHouseholds() async {
    List<String>? fetchedHouseholds = await BackendService.fetchManagedHouseholds(widget.managerEmail);
    if (fetchedHouseholds != null) {
      setState(() {
        households = fetchedHouseholds;
        if (households.isNotEmpty) {
          selectedHousehold = households[0];
        }
      });
    }
  }

  void _addUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool success = await BackendService.sendInvite({
        'manager_email': widget.managerEmail,
        'household_name': selectedHousehold,
        'user_name': userName,
        'user_email': userEmail,
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User $userName added to $selectedHousehold. Email confirmation sent!")),
        );
        Navigator.pop(context, {'name': userName.trim(), 'email': userEmail.trim(), 'dateAdded': DateTime.now().toString().split(' ')[0]});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add user. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User"),
        backgroundColor: const Color.fromARGB(255, 153, 199, 237),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 199, 227, 250), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Household", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: selectedHousehold,
                  items: households.map((household) {
                    return DropdownMenuItem<String>(
                      value: household,
                      child: Text(household),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHousehold = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text("User Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter user's name",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name cannot be empty";
                    }
                    return null;
                  },
                  onSaved: (value) => userName = value!.trim(),
                ),
                SizedBox(height: 16),
                Text("User Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter user's email",
                  ),
                  validator: (value) {
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (value == null || value.trim().isEmpty) {
                      return "Email cannot be empty";
                    } else if (!emailRegex.hasMatch(value.trim())) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                  onSaved: (value) => userEmail = value!.trim(),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addUser,
                    icon: Icon(Icons.person_add),
                    label: Text("Add User"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade300,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
