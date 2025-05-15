import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import '../dummy_data.dart';
import 'addhousehold.dart';
import '../detailed_notifications.dart';
import 'bottom_nav_manager.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';
import 'package:flutter/widgets.dart'; // For RouteObserver
import 'package:flutter_application_1/main.dart'; // <-- add this to import routeObserver

class HomeManagerPage extends StatefulWidget {
  final String email; // Add email parameter
  const HomeManagerPage({super.key, required this.email});

  @override
  _HomeManagerPageState createState() => _HomeManagerPageState();
}

class _HomeManagerPageState extends State<HomeManagerPage> with RouteAware {
  final int _currentIndex = 0;
  String profilePic = '';
  List<Map<String, dynamic>> households = [];
  List<Map<String, String>> alerts = DummyData.alerts; // Use dummy data for alerts
  Map<String, dynamic>? weatherData;
  late final String _managerEmail; // Store the trimmed email

  @override
  void initState() {
    super.initState();
    // Use session email if widget.email is empty.
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
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
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

// Widget _buildWeatherSection() {
//   if (weatherData == null) {
//     return Center(child: CircularProgressIndicator());
//   }

//   final temperature = weatherData!['main']['temp'];
//   final weatherDescription = weatherData!['weather'][0]['description'];
//   final iconCode = weatherData!['weather'][0]['icon'];
//   final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

//   return Container(
//     padding: EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: Colors.blue.shade50,
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Row(
//       children: [
//         Image.network(iconUrl, width: 40, height: 40),
//         SizedBox(width: 10),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Weather: $weatherDescription",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "Temperature: ${temperature.toStringAsFixed(1)}°C",
//               style: TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

  // Stream to fetch manager details using the session's houseId and _managerEmail.
  Stream<QuerySnapshot<Map<String, dynamic>>> _managerStream() {
    String? houseId = BackendService.session.houseId;
    if (houseId == null || houseId.isEmpty) {
      print("Error: No valid houseId in session.");
      // Return an empty stream.
      return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    final stream = FirebaseFirestore.instance
      .collection("Houses")
      .doc(houseId)
      .collection("house_manager")
      .where("manager_email", isEqualTo: _managerEmail)
      .limit(1)
      .snapshots();
      
    stream.listen((data) {
      print("Fetched manager stream data: ${data.docs.map((doc) => doc.data()).toList()}");
    }, onError: (error) {
      print("Error in manager stream: $error");
    });
    
    return stream;
  }

  void _fetchManagedHouseholds() async {
    if (_managerEmail.isEmpty) {
      print("Error: Manager email is empty. Cannot fetch households.");
      return;
    }
    // Log the stored email for debugging.
    print("Fetching managed households with email: $_managerEmail");
    
    // Assume you update your BackendService.fetchManagedHouseholds to return a list of maps,
    // where each map contains household details including the document ID.
    List<Map<String, dynamic>>? fetched = await BackendService.fetchManagedHouseholdsExtended(_managerEmail);
    
    print("Fetched households: $fetched");
    
    if (fetched != null && fetched.isNotEmpty) {
      setState(() {
        households = fetched.map((house) => {
          'name': house['name'] ?? '',
          'energy': house['energy'] ?? 'N/A'
        }).toList();
        // Update session with the actual house document ID.
        // For example, store the ID of the first household.
        BackendService.session.houseId = fetched.first['id'];
        print("Session updated with houseId: ${BackendService.session.houseId}");
      });
    } else {
      print("No households fetched for email: $_managerEmail");
    }
  }

  void _clearAllNotifications() {
    setState(() {
      DummyData.alerts.clear();
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
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _managerStream(),
          builder: (context, snapshot) {
            String managerName = "Manager";
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              var data = snapshot.data!.docs.first.data();
              managerName = data["manager_name"] ?? managerName;
              profilePic = data['manager_profile_pic'] ?? 'assets/profile.png';
            }
            return Text("Welcome, $managerName!");
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _managerStream(),
        builder: (context, snapshot) {
          String managerName = "Manager";
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var data = snapshot.data!.docs.first.data();
            managerName = data["manager_name"] ?? managerName;
            profilePic = data['manager_profile_pic'] ?? 'assets/profile.png';
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
                  child: _buildProfileHeader(managerName),
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
                          "Welcome, $managerName!",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        _buildWeatherSection(),
                        SizedBox(height: 20),
                        _buildHouseholdSection(),
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
      bottomNavigationBar: buildBottomNavigationBar(context, _currentIndex),
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
              backgroundImage: (profilePic.isNotEmpty)
                  ? (profilePic.startsWith("http")
                      ? NetworkImage(profilePic)
                      : AssetImage(profilePic) as ImageProvider)
                  : AssetImage('assets/profile.png'),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  managerName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Home Manager",
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
              onPressed: () {
                // Implement logout logic here if needed.
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildWeatherSection() {
  //   return Container(
  //     padding: EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.blue.shade50,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.wb_sunny, color: Colors.orange, size: 24),
  //         SizedBox(width: 10),
  //         Text(
  //           "Weather: ${DummyData.weather}",
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHouseholdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Households You Manage",
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
                        households.length.toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.blue, size: 28),
                  onPressed: _addNewHousehold, 
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: households.map((household) {
              return Container(
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
                    Icon(Icons.home, size: 40, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      household['name'] ?? '',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Energy: ${household['energy']}",
                      style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 67, 66, 66)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
            if (DummyData.alerts.isNotEmpty)
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
        DummyData.alerts.isEmpty
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
                itemCount: DummyData.alerts.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.red.shade100,
                    child: ListTile(
                      leading: Icon(Icons.warning, color: const Color.fromARGB(255, 251, 122, 113)),
                      title: Text(DummyData.alerts[index]['text'] ?? ""),
                      subtitle: Text("Time: ${DummyData.alerts[index]['time'] ?? "N/A"}"),
                    ),
                  );
                },
              ),
      ],
    );
  }

  int _currentGraphIndex = 0; 

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
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

