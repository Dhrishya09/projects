// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/pages/user/nav.dart';
// // import 'package:flutter_application_1/pages/device_co.dart';
// import 'package:flutter_application_1/pages/graph.dart';
// import 'package:flutter_application_1/pages/settings/settings_user.dart'; // updated import for house users settings
// import 'package:flutter_application_1/pages/detailed_notifications.dart';
// import 'package:flutter_application_1/BackendServices/backend_service.dart'; // Import BackendService
// import 'package:cloud_firestore/cloud_firestore.dart';

// class HomeuserMain extends StatefulWidget {
//   const HomeuserMain({super.key});

//   @override
//   _HomeuserMainState createState() => _HomeuserMainState();
// }

// class _HomeuserMainState extends State<HomeuserMain> {
//   bool isEnergySaveMode = false;
//   final int _currentIndex = 0;
//   String userName = '';
//   String profilePic = '';
//   List<Map<String, String>> alerts = [];

//   @override
//   void initState() {
//     super.initState();
//     // Print dynamic session values for debugging.
//     print("HomeuserMain: Using session email: ${BackendService.session.email}, household: ${BackendService.session.householdName}");
//     _fetchUserDetails();
//     _fetchNotifications();
//   }

//   Future<void> _fetchUserDetails() async {
//     final email = BackendService.session.email ?? 'default@example.com';
//     final household = BackendService.session.householdName ?? 'DefaultHousehold';
//     final userDetails = await BackendService.fetchUserDetails(
//       email: email,
//       householdName: household,
//     );
//     if (userDetails != null) {
//       setState(() {
//         userName = userDetails['user_name'];
//         profilePic = userDetails['profile_pic'];
//       });
//     }
//   }

//   Future<void> _fetchNotifications() async {
//     final email = BackendService.session.email ?? 'default@example.com';
//     final household = BackendService.session.householdName ?? 'DefaultHousehold';
//     final notifications = await BackendService.fetchNotifications(
//       email: email,
//       householdName: household,
//     );
//     if (notifications != null) {
//       setState(() {
//         alerts = notifications;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return NavPage(
//       currentIndex: 0,
//       child: Column(
//         children: [
//           // Top bar with user welcome using a StreamBuilder
//           StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//             stream: FirebaseFirestore.instance
//                 .collection("Houses")
//                 .doc(BackendService.session.houseId ?? "defaultHouse")
//                 .collection("house_user")
//                 .where("user_email", isEqualTo: BackendService.session.email ?? "defaultEmail")
//                 .limit(1)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               String name = "User";
//               if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//                 var data = snapshot.data!.docs.first.data();
//                 if (data["user_name"] != null) {
//                   name = data["user_name"];
//                 }
//               }
//               return Text(
//                 "Welcome, $name!",
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               );
//             },
//           ),
//           // Rooms list using a StreamBuilder fetching from the "rooms" subcollection
//           Expanded(
//             child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: FirebaseFirestore.instance
//                   .collection("Houses")
//                   .doc(BackendService.session.houseId ?? "defaultHouse")
//                   .collection("rooms")
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return const CircularProgressIndicator();
//                 final rooms = snapshot.data!.docs;
//                 if (rooms.isEmpty) {
//                   return const Center(child: Text("No rooms added yet."));
//                 }
//                 return ListView.builder(
//                   itemCount: rooms.length,
//                   itemBuilder: (context, index) {
//                     var roomData = rooms[index].data();
//                     String roomName = roomData["room_name"] ?? "";
//                     // Determine emoji based on room name (case‑insensitive)
//                     String emoji = "";
//                     String lower = roomName.toLowerCase();
//                     if (lower.contains("living room")) { emoji = "🛋"; }
//                     else if (lower.contains("dining room")) { emoji = "🍽"; }
//                     else if (lower.contains("kitchen")) { emoji = "🍳"; }
//                     else if (lower.contains("bedroom")) { emoji = "🛏"; }
//                     else if (lower.contains("bathroom") || lower.contains("toilet") || lower.contains("washroom")) { emoji = "🛁"; }
                    
//                     return ListTile(
//                       title: Text("$emoji $roomName"),
//                       subtitle: FutureBuilder<int>(
//                         future: _countDevicesInRoom(roomName),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return Text("${snapshot.data} devices");
//                           } else {
//                             return Text("Counting devices...");
//                           }
//                         },
//                       ),
//                       onTap: () {
//                         // Navigate to device control page with roomName passed.
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DeviceControlPage(roomName: roomName),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           // ...existing UI elements...
//         ],
//       ),
//     );
//   }

//   // Counts documents in the user_devices subcollection where device_location equals roomName.
//   Future<int> _countDevicesInRoom(String roomName) async {
//     QuerySnapshot<Map<String, dynamic>> qs = await FirebaseFirestore.instance
//         .collection("Houses")
//         .doc(BackendService.session.houseId ?? "defaultHouse")
//         .collection("house_user")
//         .where("user_email", isEqualTo: BackendService.session.email)
//         .get();
//     if (qs.docs.isEmpty) return 0;
//     DocumentReference userRef = qs.docs.first.reference;
//     QuerySnapshot<Map<String, dynamic>> devices = await userRef
//         .collection("user_devices")
//         .where("device_location", isEqualTo: roomName)
//         .get();
//     // Exclude the dummy init document if present.
//     return devices.docs.where((doc) => doc.id != "init").length;
//   }

//   Widget _buildProfileHeader(BuildContext context) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundImage: AssetImage(profilePic),
//             ),
//             SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   userName,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text("Home User", style: TextStyle(fontSize: 14, color: Colors.black87)),
//               ],
//             ),
//             Spacer(),
//             IconButton(
//               icon: Icon(Icons.notifications, color: Colors.black),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
//               },
//             ),
//             IconButton(
//               icon: Icon(Icons.logout, color: Colors.black),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWeatherWidget() {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text("Current Weather: 25°C, Sunny", style: TextStyle(fontSize: 16)),
//             Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEnergyConsumptionGraph(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => Graph()));
//       },
//       child: Card(
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Today's Energy Consumption", style: TextStyle(fontSize: 16)),
//               SizedBox(height: 10),
//               SizedBox(
//                 height: 100,
//                 child: _buildTestGraph(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//  Widget _buildTestGraph() {
//   return LineChart(
//     LineChartData(
//       lineBarsData: [
//         LineChartBarData(
//           spots: [
//             FlSpot(0, 1),
//             FlSpot(1, 3),
//             FlSpot(2, 2),
//             FlSpot(3, 5),
//           ],
//           isCurved: true,
//           color: Color.fromARGB(255, 33, 150, 243),
//           barWidth: 4,
//         ),
//       ],
//     ),
//   );
// }


//   Widget _buildModesToggle() {
//     return ElevatedButton(
//       onPressed: () {
//         setState(() {
//           isEnergySaveMode = !isEnergySaveMode;
//         });
//       },
//       child: Text(isEnergySaveMode ? "Energy Save Mode: ON" : "Enable Energy Save Mode"),
//     );
//   }

//   Widget _buildNotifications() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Notifications",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             if (alerts.isNotEmpty)
//               ElevatedButton.icon(
//                 onPressed: _clearAllNotifications,
//                 icon: Icon(Icons.delete),
//                 label: Text("Clear All"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color.fromARGB(255, 250, 161, 159),
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//           ],
//         ),
//         SizedBox(height: 10),
//         alerts.isEmpty
//             ? Center(
//                 child: Text(
//                   "No notifications",
//                   style: TextStyle(color: Colors.black87, fontSize: 16),
//                 ),
//               )
//             : ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: alerts.length,
//                 itemBuilder: (context, index) {
//                   return Card(
//                     color: Colors.red.shade100,
//                     child: ListTile(
//                       leading: Icon(Icons.warning, color: Colors.red),
//                       title: Text(alerts[index]['text'] ?? ""),
//                       subtitle: Text("Time: ${alerts[index]['time'] ?? "N/A"}"),
//                     ),
//                   );
//                 },
//               ),
//       ],
//     );
//   }

//   void _clearAllNotifications() {
//     setState(() {
//       alerts.clear();
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("All notifications cleared!")),
//     );
//   }
// }

// // Stub DeviceControlPage widget definition
// class DeviceControlPage extends StatelessWidget {
//   final String roomName;
//   const DeviceControlPage({super.key, required this.roomName});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Devices in $roomName")),
//       body: Center(child: Text("Device control page for '$roomName'")),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter_application_1/pages/manager/addhousehold.dart';
import 'package:flutter_application_1/pages/user/device_control/device_co.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import '../dummy_data.dart';
// import 'addhousehold.dart';
import '../detailed_notifications.dart';
import 'nav.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';
import 'package:flutter/widgets.dart'; // For RouteObserver
import 'package:flutter_application_1/main.dart'; // <-- add this to import routeObserver

class HomeuserMain extends StatefulWidget {
  final String email; // Add email parameter
  const HomeuserMain({super.key, required this.email});

  @override
  _HomeManagerPageState createState() => _HomeManagerPageState();
}

class _HomeManagerPageState extends State<HomeuserMain> with RouteAware {
  bool isEnergySaveMode = false;
  final int _currentIndex = 0;
  String profilePic = '';
  List<Map<String, String>> households = [];
  List<Map<String, String>> alertsu = DummyData.alerts_user; // Use dummy data for alerts
  Map<String, dynamic>? weatherData;
  // String weather = DummyData.weather; // Use dummy data for weather
  late final String _managerEmail; // Store the trimmed email

  @override
  void initState() {
    super.initState();
    // Use session email if widget.email is empty. Ensure that the session is updated on login.
    _managerEmail = widget.email.trim().isNotEmpty 
        ? widget.email.trim() 
        : (BackendService.session.email ?? "");
    if (_managerEmail.isEmpty) {
      print("Warning: Manager email is empty. Check that the session is updated on login.");
    } else {
      print("HomeManagerPage: Using manager email: $_managerEmail");
    }
    _fetchManagedHouseholds();
    _fetchWeather();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the RouteObserver defined in main.dart
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed.
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this page from another.
    _fetchManagedHouseholds();
  }

  Future<void> _fetchWeather() async {
  const apiKey = '2f74f46048cf7eccc601b44d62f8815d'; // Your OpenWeatherMap API key
  const city = 'Dubai';//lace with dynamic city if needed
  const url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  } catch (e) {
    print("Error fetching weather: $e");
  }
}

Widget _buildWeatherSection() {
  if (weatherData == null) {
    return Center(child: CircularProgressIndicator());
  }

  final temperature = weatherData!['main']['temp'];
  final weatherDescription = weatherData!['weather'][0]['description'];
  final iconCode = weatherData!['weather'][0]['icon'];
  final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  final cityName = weatherData!['name']; // City name from the API

  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade50, Colors.blue.shade100], // Softer blue gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 5,
          spreadRadius: 2,
          color: Colors.black.withOpacity(0.1),
        ),
      ],
    ),
    child: Row(
      children: [
        // Weather icon from the API with a smooth fade-in effect
        FadeInImage.assetNetwork(
          placeholder: 'assets/trans.jpeg',//ansparent placeholder
          image: iconUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) {
            // Fallback widget if the image fails to load
            return Icon(
              Icons.wb_sunny, // Default weather icon
              size: 60,
              color: Colors.orange,
            );
          },
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City name
            Text(
              cityName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900, // Darker blue for contrast
              ),
            ),
            SizedBox(height: 5),
            // Weather description
            Text(
              weatherDescription.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade800, // Slightly darker blue
              ),
            ),
            SizedBox(height: 5),
            // Temperature with a small icon
            Row(
              children: [
                Icon(
                  Icons.thermostat, // Temperature icon
                  size: 20,
                  color: Colors.blue.shade900,
                ),
                SizedBox(width: 5),
                Text(
                  "${temperature.toStringAsFixed(1)}°C",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900, // Darker blue for contrast
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

  // Modified _managerStream: catch synchronous errors and return an empty stream in case of error.
  Stream<QuerySnapshot<Map<String, dynamic>>> _managerStream() {
    String houseId = "house_002"; // Replace with actual logic if needed
    try {
      final stream = FirebaseFirestore.instance
          .collection("Houses")
          .doc(houseId)
          .collection("house_manager")
          .where("manager_email", isEqualTo: _managerEmail)
          .snapshots();
      stream.listen((data) {
        print("Fetched manager stream data: ${data.docs.map((doc) => doc.data()).toList()}");
      });
      return stream.handleError((error) {
        print("Async error in _managerStream: $error");
      });
    } catch (e) {
      print("Synchronous error in _managerStream: $e");
      // Return an empty stream so UI can load
      return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
  }

  void _fetchManagedHouseholds() async {
    if (_managerEmail.isEmpty) {
      print("Error: Manager email is empty. Cannot fetch households.");
      return;
    }
    // Log the stored email for debugging.
    print("Fetching managed households with email: $_managerEmail");
    List<String>? fetched = await BackendService.fetchManagedHouseholds(_managerEmail);
    print("Fetched households: $fetched");
    if (fetched != null && fetched.isNotEmpty) {
      setState(() {
        households = fetched.map((name) => {'name': name, 'energy': 'N/A'}).toList();
      });
    } else {
      print("No households fetched for email: $_managerEmail");
    }
  }

  void _clearAllNotifications() {
    setState(() {
      DummyData.alerts_user.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All notifications cleared!")),
    );
  }

  void _addNewHousehold() async {
    final newHousehold = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHouseholdPage()),
    );

    if (newHousehold != null) {
      setState(() {
        households.add(newHousehold);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Household '${newHousehold['name']}' added!")),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return NavPage(
    currentIndex: 0, // Set the current index for the bottom navigation
    child: Column(
      children: [
        // Top bar with user welcome using a StreamBuilder
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("Houses")
              .doc(BackendService.session.houseId ?? "defaultHouse")
              .collection("house_user")
              .where("user_email", isEqualTo: BackendService.session.email ?? "dummy@example.com")
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            // String Name = "User";
            // if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            //   var data = snapshot.data!.docs.first.data();
            //   Name = data["user_name"] ?? Name;
            // }
            // return Text(
            //   "Welcome, $Name!",
            //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // );
            return Container();
          },
        ),
        // Main content using a StreamBuilder
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _managerStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error loading data"));
              }
              String Name = "User";
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                var data = snapshot.data!.docs.first.data();
                if (data["user_name"] != null) {
                  Name = data["user_name"];
                }
              }
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color.fromARGB(255, 199, 227, 250), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _buildProfileHeader(Name),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            // Use the streamed managerName here.
                            Text(
                              "Welcome, $Name!",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            _buildWeatherSection(),
                            SizedBox(height: 20),
                            _buildRoomsSection(context,setState),
                            SizedBox(height: 20),
                            _buildNotificationsSection(),
                            _buildEnergyGraphSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildProfileHeader(String managerName) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 237, 246, 253),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 4,
          spreadRadius: 2,
          color: Colors.black.withOpacity(0.1),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.only(top: 20), 
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            // Change the AssetImage path so that it matches your pubspec.yaml.
            backgroundImage: profilePic.isNotEmpty 
                ? NetworkImage(profilePic) 
                : AssetImage('assets/profile.png') as ImageProvider,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // Use the streamed managerName here.
                managerName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Home User",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (DummyData.alerts_user.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _clearAllNotifications,
                icon: Icon(Icons.delete),
                label: Text("Clear All"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 250, 161, 159),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
        DummyData.alerts_user.isEmpty
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.transparent, 
                ),
                child: Center(
                  child: Text(
                    "No notifications",
                    style: TextStyle(color: const Color.fromARGB(255, 35, 34, 34), fontSize: 18),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: DummyData.alerts_user.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.red.shade100,
                    child: ListTile(
                      leading: Icon(Icons.warning, color: const Color.fromARGB(255, 251, 122, 113)),
                      title: Text(DummyData.alerts_user[index]['text'] ?? ""),
                      subtitle: Text("Time: ${DummyData.alerts_user[index]['time'] ?? "N/A"}"),
                    ),
                  );
                },
              ),
      ],
    );
  }

  int _currentGraphIndex = 0; 
Widget _buildModesToggle() {
  return ElevatedButton(
    onPressed: () {
      setState(() {
        isEnergySaveMode = !isEnergySaveMode; // Toggle the mode
      });
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: isEnergySaveMode ? Colors.green : null, // Green when ON, default when OFF
      foregroundColor: isEnergySaveMode ? Colors.white : null, // White text when ON
    ),
    child: Text(isEnergySaveMode ? "Energy Save Mode: ON" : "Enable Energy Save Mode"),
  );
}


  // Widget _buildEnergyGraphSection() {
  //   if (DummyData.households.isEmpty) {
  //     return Center(
  //       child: Text(
  //         "No household data available",
  //         style: TextStyle(fontSize: 16, color: Colors.grey),
  //       ),
  //     );
  //   }

  //   var household = DummyData.households[_currentGraphIndex];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       SizedBox(height: 20),
  //       Text(
  //         "Energy Consumption Pattern",
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 10),
  //       Container(
  //         padding: EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             BoxShadow(
  //               blurRadius: 5,
  //               spreadRadius: 2,
  //               color: Colors.black.withOpacity(0.1),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           children: [
  //             Text(
  //               household['name'],
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 10),
  //             Container(
  //               height: 150,
  //               color: Colors.blue.shade100,
  //               child: Center(child: Text("Graph for ${household['name']}")),
  //             ),
  //             SizedBox(height: 10),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 IconButton(
  //                   icon: Icon(Icons.arrow_left, size: 32),
  //                   onPressed: _currentGraphIndex > 0
  //                       ? () => setState(() => _currentGraphIndex--)
  //                       : null,
  //                 ),
  //                 Column(
  //                   children: [
  //                     Text(
  //                       "${household['energy']}",
  //                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                     ),
  //                     Text(
  //                       "Energy Used",
  //                       style: TextStyle(fontSize: 14, color: Colors.grey),
  //                     ),
  //                   ],
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.arrow_right, size: 32),
  //                   onPressed: _currentGraphIndex < DummyData.households.length - 1
  //                       ? () => setState(() => _currentGraphIndex++)
  //                       : null,
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

Widget _buildEnergyGraphSection() {
  if (DummyData.households.isEmpty) {
    return Center(
      child: Text(
        "No household data available",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  var household = DummyData.households[_currentGraphIndex];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
    children: [
      SizedBox(height: 20),
      Row(
        children: [
          _buildModesToggle(), // Add the button here
        ],
      ),
      SizedBox(height: 20), // Add some spacing
      Text(
        "Energy Consumption Pattern",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 2,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              household['name'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              color: Colors.blue.shade100,
              child: Center(child: Text("Graph for ${household['name']}")),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, size: 32),
                  onPressed: _currentGraphIndex > 0
                      ? () => setState(() => _currentGraphIndex--)
                      : null,
                ),
                Column(
                  children: [
                    Text(
                      "${household['energy']}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Energy Used",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, size: 32),
                  onPressed: _currentGraphIndex < DummyData.households.length - 1
                      ? () => setState(() => _currentGraphIndex++)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
}

// Widget _buildRoomsSection(BuildContext context, void Function(void Function()) setState) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "Rooms",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade300,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.home, size: 22, color: Colors.white),
//                     SizedBox(width: 6),
//                     Text(
//                       rooms.length.toString(),
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 10),
//               IconButton(
//                 icon: Icon(Icons.add_circle, color: Colors.blue, size: 28),
//                 onPressed: () => _addNewRoom(context, setState), // Wrap in a callback
//               ),
//             ],
//           ),
//         ],
//       ),
//       SizedBox(height: 10),
//       SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: rooms.map((room) {
//             return GestureDetector(
//               onTap: () {
//                 // Navigate to the device control page for the selected room
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => device_co(rooms: [room['name'] ?? '']),
//                   ),
//                 );
//               },
//               child: Container(
//                 margin: EdgeInsets.only(right: 12),
//                 padding: EdgeInsets.all(16),
//                 width: 190,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       blurRadius: 5,
//                       spreadRadius: 2,
//                       color: Colors.black.withOpacity(0.1),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.room, size: 40, color: Colors.blue),
//                     SizedBox(height: 10),
//                     Text(
//                       room['name'] ?? '',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                     Text(
//                       "Devices: ${room['devices'] ?? 'N/A'}",
//                       style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 67, 66, 66)),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     ],
//   );
// }
Widget _buildRoomsSection(BuildContext context, void Function(void Function()) setState) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Rooms",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.home, size: 22, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      rooms.length.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.blue, size: 28),
                onPressed: () => _addNewRoom(context, setState), // Correct: Pass setState as a function reference
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: rooms.map((room) {
            // Determine the icon based on the room name
            IconData roomIcon = _getRoomIcon(room['name'] ?? '');

            return GestureDetector(
              onTap: () {
                // Navigate to the device control page for the selected room
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => device_co(rooms: [room['name'] ?? '']),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.all(16),
                width: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      spreadRadius: 2,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(roomIcon, size: 40, color: Colors.blue), // Use the room-specific icon
                    SizedBox(height: 10),
                    Text(
                      room['name'] ?? '',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Devices: ${room['devices'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 67, 66, 66)),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

void _addNewRoom(BuildContext context, void Function(void Function()) setState) async {
  final TextEditingController roomNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add New Room"),
        content: TextField(
          controller: roomNameController,
          decoration: InputDecoration(hintText: "Enter room name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (roomNameController.text.trim().isNotEmpty) {
                setState(() {
                  rooms.add({
                    'name': roomNameController.text.trim(),
                    'devices': '0', // Default number of devices
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}

List<Map<String, String>> rooms = [
  {'name': 'Bedroom', 'devices': '4'},
  {'name': 'Living Room', 'devices': '6'},
  {'name': 'Dining Room', 'devices': '5'},
  {'name': 'Kitchen', 'devices': '4'},
  {'name': 'Study Room', 'devices': '3'},
  {'name': 'Bathroom', 'devices': '2'},

];

IconData _getRoomIcon(String roomName) {
  String lower = roomName.toLowerCase();

  if (lower.contains("living room")) {
    return Icons.chair; // Icon for living room
  } else if (lower.contains("dining room")) {
    return Icons.dining; // Icon for dining room
  } else if (lower.contains("kitchen")) {
    return Icons.kitchen; // Icon for kitchen
  } else if (lower.contains("bedroom")) {
    return Icons.bed; // Icon for bedroom
  } else if (lower.contains("bathroom") || lower.contains("toilet") || lower.contains("washroom")) {
    return Icons.bathtub; // Icon for bathroom
  } else if (lower.contains("study room")) {
    return Icons.menu_book; // Icon for study room
  } else {
    return Icons.room; // Default icon for other rooms
  }
}