import 'package:flutter/material.dart';
import 'add_device.dart';
import 'dart:math' as math;
// import 'package:flutter_application_1/pages/user/device_control/add_device.dart';
import 'package:flutter_application_1/pages/user/nav.dart';

class device_co extends StatelessWidget {
  final List<String> rooms;

  const device_co({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return NavPage(
      currentIndex: 1,
      child: HomePage(rooms: rooms),
    );
  }
}

// class HomePage extends StatefulWidget { //displays the list of rooms and allows users to add new rooms
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

class HomePage extends StatefulWidget {
  final List<String> rooms;

  const HomePage({super.key, required this.rooms});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showDropdown = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController devicesController = TextEditingController();
  List<Room> rooms = [
    Room("Bedroom", 4, Icons.bed),
    Room("Living Room", 10, Icons.chair),
    Room("Dining Room", 5, Icons.dining),
    Room("Kitchen", 4, Icons.kitchen),
    Room("Study Room", 3, Icons.computer),
    Room("Bathroom", 2, Icons.bathtub),
  ];

  void addRoom() { //adds room which is added to rooms list
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Room"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Room Name"),
              ),
              // TextField(
              //   controller: devicesController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(labelText: "Number of Devices"),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Get the number of devices from the input
                int deviceCount = int.tryParse(devicesController.text) ?? 0;
                setState(() {
                  rooms.add(Room(
                    nameController.text,
                    deviceCount,
                    Icons.bed, // Default icon can be changed later
                  ));
                });
                // Close the dialog
                Navigator.pop(context);
              },
              child: Text("Add Room"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

void removeRoom() { //removes room which is added to rooms list
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Room"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Room Name"),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
              // Get the room name from the input
              String roomName = nameController.text.trim();
              if (roomName.isNotEmpty) {
                setState(() {
                  // Remove the room from the list if it exists
                  rooms.removeWhere((room) => room.name == roomName);
                });
                // Clear the text field
                nameController.clear();
              }
                // Close the dialog
                Navigator.pop(context);
              },
              child: Text("Remove Room"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 149, 205, 248),
        elevation: 0,
        title: Text("  Device control",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        //actions: [
          //IconButton(
          //  icon: Icon(Icons.person, color: Colors.black),
           // onPressed: () {},
         // ),
        //],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.room, size: 40, color: Colors.black),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Devices",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("35 devices"),
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Rooms",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.black),
                          onPressed: addRoom),
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.black),
                          onPressed: removeRoom, // Trigger the add room dialog
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailPage(
                          roomName: rooms[index].name,
                          devices: getDevicesForRoom(rooms[index].name),
                        ),
                      ),
                    );
                  },
                  child: RoomCard(
                    key: ValueKey(rooms[index].name),
                    room: rooms[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////ROOM///////////////////////////////////////////
class RoomDetailPage extends StatefulWidget {
  final String roomName;
  final List<Device> devices;

  const RoomDetailPage({super.key, required this.roomName, required this.devices});

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  List<Device> devices = [];

  @override
  void initState() {
    super.initState();
    devices = widget.devices;
  }

  void addDevice(String name, IconData icon) {
    setState(() {
      devices.add(Device(name: name, count: 1, icon: icon));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 236, 241),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            color: const Color.fromARGB(255, 207, 230, 249),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Text(
                    widget.roomName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  child: Icon(Icons.bed, size: 50, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                SizedBox(height: 10),
                Text(
                  widget.roomName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (devices[index].name.toLowerCase().contains("light")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LightDevicePage(selectedRoom: widget.roomName),
                            ),
                          );
                        }
                      else if (devices[index].name.toLowerCase().contains("tv")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SmartTvPage(selectedRoom: widget.roomName),
                          ),
                        );
                      }
                      else if (devices[index].name.toLowerCase().contains("air")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AirConditionerPage(),
                          ),
                        );
                      }
                      else if (devices[index].name.toLowerCase().contains("game")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RobotStatusPage(),
                          ),
                        );
                      }
                    },
                      child: DeviceCard(device: devices[index]),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddDevicePopup(
                            onAddDevice: addDevice, existingDeviceNames: getDevicesForRoom(widget.roomName).map((device) => device.name).toList(),
                          );
                        },
                      );
                    },
                    child: Icon(Icons.add, color: Colors.white),
                    backgroundColor: const Color.fromARGB(255, 214, 227, 236),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Room {
  final String name;
  final int devices;
  final IconData icon;

  Room(this.name, this.devices, this.icon);
}


/////////////////////////////DEVICES//////////////////////////////////////////
class Device {
  final String name;
  final int count;
  final IconData icon;

  Device({required this.name, required this.count, required this.icon});
}

class RoomCard extends StatelessWidget { //a grid of rooms
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 216, 227, 235),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(room.icon, size: 50, color: const Color.fromARGB(255, 19, 7, 94)),
          SizedBox(height: 10),
          Text(
            room.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text("${room.devices} devices"),
        ],
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: const Color.fromARGB(255, 191, 229, 241), blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(device.icon, size: 40, color: Colors.black),
          SizedBox(height: 10),
          Text(
            device.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text("${device.count} devices", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// Light Device Page (Third page in the flow)
class LightDevicePage extends StatefulWidget {
  final String selectedRoom;  // Added parameter to know which room was selected

  LightDevicePage({super.key, required this.selectedRoom});

  @override
  _LightDevicePageState createState() => _LightDevicePageState();
}

class _LightDevicePageState extends State<LightDevicePage> {
  final Map<String, List<String>> roomsWithDevices = {
    "Bedroom": ["Light - 1"],
    "Living Room": ["Light - 2"],
    "Bathroom": ["Light - 3"],
    "Kitchen": ["Light - 4"],
    "Study Room": ["Light - 5"],
    "Dining Room": ["Light - 6"],
  };

  // Function to add device to the selected room
  void addDeviceToRoom(String room, String deviceName) {
    setState(() {
      roomsWithDevices[room]?.add(deviceName);
    });
  }

  // Function to remove a device from the selected room
  void removeDeviceFromRoom(String room, String deviceName) {
    setState(() {
      roomsWithDevices[room]?.remove(deviceName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 218, 229, 238),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
                    Navigator.pop(context);
                  },
        ),
        //actions: [
        //  IconButton(
          //  icon: Icon(Icons.person, color: Colors.black),
          //  onPressed: () {},
          //),
        //],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: const Color.fromARGB(255, 106, 174, 229),
            child: Column(
              children: [
                Text(
                  "Light",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Icon(Icons.lightbulb, size: 50, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: 
            ListView(
              padding: EdgeInsets.all(16),
              children: roomsWithDevices.keys.map((room) {
              // children: roomsWithDevices.keys.where((room) => rooms.contains(room)).map((room) {
                // Only display devices for the selected room if specified
                if (widget.selectedRoom.isNotEmpty && room != widget.selectedRoom) {
                  return SizedBox.shrink(); // Skip rooms that don't match the selection
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      color: const Color.fromARGB(255, 173, 208, 238),
                      child: Text(room, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10),
                    ...roomsWithDevices[room]!.map((device) => GestureDetector(
                      onTap: () {
                        // Navigate to Light Control Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LightControlPage(device: device),
                          ),
                        );
                      },
                      child: Center(child: LightDeviceCard(device: device)),
                    )),
                    SizedBox(height: 8),
                    // Add Device Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Show dialog to add a new device to the selected room
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String deviceName = ''; // Device name input
                                return AlertDialog(
                                  title: Text('Add Device to $room'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        onChanged: (value) {
                                          deviceName = value;
                                        },
                                        decoration: InputDecoration(hintText: "Enter device name"),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (deviceName.isNotEmpty) {
                                          addDeviceToRoom(room, deviceName);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Add Device'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          label: Text("Add device"),
                        ),
                        // Remove Device Button
                        TextButton.icon(
                          onPressed: () {
                            // Show dialog to remove a device from the selected room
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String deviceToRemove = ''; // Device to remove
                                return AlertDialog(
                                  title: Text('Remove Device from $room'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButton<String>(
                                        hint: Text("Select device to remove"),
                                        value: deviceToRemove.isEmpty ? null : deviceToRemove,
                                        onChanged: (value) {
                                          setState(() {
                                            deviceToRemove = value!;
                                          });
                                        },
                                        items: roomsWithDevices[room]!.map((device) {
                                          return DropdownMenuItem<String>(
                                            value: device,
                                            child: Text(device),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (deviceToRemove.isNotEmpty) {
                                          removeDeviceFromRoom(room, deviceToRemove);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Remove Device'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          label: Text("Remove device"),
                        ),
                      ],
                    ),
                    SizedBox(height: 30), // Adjust for more spacing
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Renamed to avoid conflict with DeviceCard from the first part
class LightDeviceCard extends StatelessWidget {
  final String device;
  LightDeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      width: 200, // Center the card with fixed width
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 212, 235, 241),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text(device, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class LightControlPage extends StatefulWidget {
  final String device;

  LightControlPage({required this.device});

  @override
  _LightControlPageState createState() => _LightControlPageState();
}

class _LightControlPageState extends State<LightControlPage> {
  double brightness = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 165, 199, 241),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          Icon(Icons.person),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Light Controls for ${widget.device}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 111, 207, 238),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.device,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 70),
              ElevatedButton(
                onPressed: null,
                child: Text("HUE"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.white,
                  disabledForegroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(200, 200),
                    painter: LightColorArcPainter(),
                  ),
                  Text(
                    "Brightness: ${brightness.toInt()}%",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: null,
                child: Text("Brightness"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.white,
                  disabledForegroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 50),
              Slider(
                value: brightness,
                min: 0,
                max: 100,
                divisions: 4,
                label: "${brightness.toInt()}%",
                onChanged: (value) {
                  setState(() {
                    brightness = value;
                  });
                },
              ),
            ],
          ),
        ),
      )
      
    );
  }
}


class LightColorArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.white,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple
    ];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 360 / colors.length;
    double startAngle = -math.pi / 2;

    for (var color in colors) {
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle,
        sweepAngle * (math.pi / 180),
        false,
        paint,
      );
      startAngle += sweepAngle * (math.pi / 180);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

List<Device> getDevicesForRoom(String roomName) {
  if (roomName == "Bedroom") {
    return [
      Device(name: "Light", count: 2, icon: Icons.lightbulb),
      Device(name: "Smart TV", count: 1, icon: Icons.tv),
      Device(name: "Air Conditioning", count: 1, icon: Icons.ac_unit),
    ];
  } else if (roomName == "Living Room") {
    return [
      Device(name: "Light", count: 4, icon: Icons.lightbulb),
      Device(name: "Smart TV", count: 1, icon: Icons.tv),
      Device(name: "Speaker", count: 2, icon: Icons.speaker),
      Device(name: "Air Conditioning", count: 2, icon: Icons.ac_unit),
      Device(name: "Game Console", count: 1, icon: Icons.gamepad),
    ];
  } else if (roomName == "Dining Room") {
    return [
      Device(name: "Light", count: 2, icon: Icons.lightbulb),
      Device(name: "Smart Display", count: 1, icon: Icons.monitor),
      Device(name: "Speaker", count: 2, icon: Icons.speaker),
    ];
  } else if (roomName == "Kitchen") {
    return [
      Device(name: "Light", count: 2, icon: Icons.lightbulb),
      Device(name: "Microwave", count: 1, icon: Icons.microwave),
      Device(name: "Refrigerator", count: 1, icon: Icons.kitchen),
    ];
  } else if (roomName == "Study Room") {
    return [
      Device(name: "Light", count: 2, icon: Icons.lightbulb),
      Device(name: "Laptop", count: 1, icon: Icons.laptop),
    ];
  } else if (roomName == "Bathroom") {
    return [
      Device(name: "Light", count: 1, icon: Icons.lightbulb),
      Device(name: "Heater", count: 1, icon: Icons.whatshot),
    ];
  }
  return [];
}

// Smart TV Page (Similar to LightDevicePage but for TVs)
class SmartTvPage extends StatefulWidget {
  final String selectedRoom; // To know which room was selected

  SmartTvPage({super.key, required this.selectedRoom});

  @override
  _SmartTvPageState createState() => _SmartTvPageState();
}

class _SmartTvPageState extends State<SmartTvPage> {
  final Map<String, List<String>> roomsWithTvs = {
    "Bedroom": ["TV - 1"],
    "Living Room": ["TV - 2"],
    "Dining Room": ["TV - 3"],
  };

  // Function to add a TV to the selected room
  void addTvToRoom(String room, String tvName) {
    setState(() {
      roomsWithTvs[room]?.add(tvName);
    });
  }

  // Function to remove a TV from the selected room
  void removeTvFromRoom(String room, String tvName) {
    setState(() {
      roomsWithTvs[room]?.remove(tvName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 191, 224, 247),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        )
       // actions: [
         // IconButton(
           // icon: Icon(Icons.person, color: Colors.black),
            //onPressed: () {},
         // ),
        //],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: const Color.fromARGB(255, 146, 196, 237),
            child: Column(
              children: [
                Text(
                  "Smart TVs",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Icon(Icons.tv, size: 50, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: roomsWithTvs.keys.map((room) {
                // Only display TVs for the selected room
                if (widget.selectedRoom.isNotEmpty && room != widget.selectedRoom) {
                  return SizedBox.shrink(); // Skip rooms that don't match the selection
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      color: Colors.blue[200],
                      child: Text(room, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10),
                    ...roomsWithTvs[room]!.map((tv) => GestureDetector(
                      onTap: () {
                        // Navigate to Smart TV Control Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SmartTvControlPage(device: tv),
                          ),
                        );
                      },
                      child: Center(child: TvDeviceCard(device: tv)),
                    )),
                    SizedBox(height: 8),
                    // Add TV Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Show dialog to add a new TV to the selected room
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String tvName = ''; // TV name input
                                return AlertDialog(
                                  title: Text('Add TV to $room'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        onChanged: (value) {
                                          tvName = value;
                                        },
                                        decoration: InputDecoration(hintText: "Enter TV name"),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (tvName.isNotEmpty) {
                                          addTvToRoom(room, tvName);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Add TV'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          label: Text("Add TV"),
                        ),
                        // Remove TV Button
                        TextButton.icon(
                          onPressed: () {
                            // Show dialog to remove a TV from the selected room
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String tvToRemove = ''; // TV to remove
                                return AlertDialog(
                                  title: Text('Remove TV from $room'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButton<String>(
                                        hint: Text("Select TV to remove"),
                                        value: tvToRemove.isEmpty ? null : tvToRemove,
                                        onChanged: (value) {
                                          setState(() {
                                            tvToRemove = value!;
                                          });
                                        },
                                        items: roomsWithTvs[room]!.map((tv) {
                                          return DropdownMenuItem<String>(
                                            value: tv,
                                            child: Text(tv),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (tvToRemove.isNotEmpty) {
                                          removeTvFromRoom(room, tvToRemove);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Remove TV'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          label: Text("Remove TV"),
                        ),
                      ],
                    ),
                    SizedBox(height: 30), // Adjust for more spacing
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// TV Device Card (Similar to LightDeviceCard but for TVs)
class TvDeviceCard extends StatelessWidget {
  final String device;
  TvDeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      width: 200, // Center the card with fixed width
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 184, 232, 240),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text(device, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

// Smart TV Control Page (Similar to LightControlPage but for TVs)
class SmartTvControlPage extends StatefulWidget {
  final String device;

  SmartTvControlPage({super.key, required this.device});

  @override
  _SmartTvControlPageState createState() => _SmartTvControlPageState();
}

class _SmartTvControlPageState extends State<SmartTvControlPage> {
  bool isTvOn = false;
  int volume = 50;
  String selectedChannel = "Channel 1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "TV Controls for ${widget.device}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.device,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 70),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isTvOn = !isTvOn;
                });
              },
              child: Text(isTvOn ? "Device Off" : "Device On"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: isTvOn ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
            SizedBox(height: 30),
            Text("Volume"),
            Slider(
              value: volume.toDouble(),
              min: 0,
              max: 100,
              divisions: 10,
              label: "$volume",
              onChanged: !isTvOn ? (value) {
                setState(() {
                  volume = value.toInt();
                }
                );
              }:null
            ),
            SizedBox(height: 30),
            Text("Channel"),
            DropdownButton<String>(
              value: selectedChannel,
              onChanged: (String? newValue) {
                setState(() {
                  selectedChannel = newValue!;
                });
              },
              items: <String>['Channel 1', 'Channel 2', 'Channel 3', 'Channel 4']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
         ],),
        ),
      );
  }
}

class ACDeviceCard extends StatelessWidget {
  final String device;

  ACDeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      width: 200,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 200, 240, 243),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.ac_unit, size: 40),
          SizedBox(height: 8),
          Text(device,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ACControlPage extends StatefulWidget {
  final String deviceName;

  ACControlPage({required this.deviceName});

  @override
  _ACControlPageState createState() => _ACControlPageState();
}

class _ACControlPageState extends State<ACControlPage> {
  double temperature = 24;
  String mode = "Cool";
  bool power = true;
  int fanSpeed = 2;

  List<String> modes = ["Cool", "Heat", "Fan", "Dry", "Auto"];

  // Get icon for specific mode
  IconData getModeIcon(String mode) {
    switch (mode) {
      case "Cool":
        return Icons.ac_unit;
      case "Heat":
        return Icons.whatshot;
      case "Fan":
        return Icons.toys;
      case "Dry":
        return Icons.water_drop;
      case "Auto":
        return Icons.autorenew;
      default:
        return Icons.ac_unit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 187, 221, 240),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //actions: [
          //Icon(Icons.person),
          //SizedBox(width: 16),
        //],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "AC Controls for ${widget.deviceName}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 124, 181, 238),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.deviceName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Power"),
                  Switch(
                    value: power,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          power = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 50),

              // Temperature Arc Widget
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(200, 200),
                    painter: TemperatureArcPainter(
                      temperature: temperature,
                      minTemp: 16,
                      maxTemp: 30,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${temperature.toInt()}°C",
                        style: TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle, size: 40),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          if (temperature > 16) temperature--;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 40),
                  IconButton(
                    icon: Icon(Icons.add_circle, size: 40),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          if (temperature < 30) temperature++;
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 40),

              // Mode Selection with Icons
              Column(
                children: [
                  Text("Mode",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Wrap(
                    // Use Wrap instead of Row to prevent overflow
                    alignment: WrapAlignment.center,
                    spacing: 16.0,
                    children: modes.map((modeOption) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            mode = modeOption;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: mode == modeOption
                                    ? const Color.fromARGB(255, 67, 143, 170)
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                getModeIcon(modeOption),
                                color: mode == modeOption
                                    ? Colors.white
                                    : Colors.black,
                                size: 24,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              modeOption,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: mode == modeOption
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Fan Speed Selection with Icons
              Column(
                children: [
                  Text("Fan Speed",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Wrap(
                    // Using Wrap instead of Row to prevent overflow
                    alignment: WrapAlignment.center,
                    spacing: 16.0,
                    children: [1, 2, 3, 4, 5].map((speed) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            fanSpeed = speed;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: fanSpeed == speed
                                    ? const Color.fromARGB(255, 170, 239, 248)
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$speed",
                                style: TextStyle(
                                  color: fanSpeed == speed
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for temperature arc
class TemperatureArcPainter extends CustomPainter {
  final double temperature;
  final double minTemp;
  final double maxTemp;

  TemperatureArcPainter({
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Calculate the angle based on temperature
    final normalizedTemp = (temperature - minTemp) / (maxTemp - minTemp);
    final sweepAngle =
        normalizedTemp * 270; // 270 degrees for the arc (3/4 of a circle)

    // Draw background arc
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = Colors.grey[300]!;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -225 * (3.14159 / 180), // Start at -225 degrees in radians
      270 * (3.14159 / 180), // Sweep 270 degrees in radians
      false,
      backgroundPaint,
    );

    // Draw filled arc based on temperature
    final tempPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Create gradient color based on temperature
    if (normalizedTemp < 0.3) {
      tempPaint.color = Colors.blue;
    } else if (normalizedTemp < 0.7) {
      tempPaint.color = Colors.orange;
    } else {
      tempPaint.color = Colors.red;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -225 * (3.14159 / 180), // Start at -225 degrees in radians
      sweepAngle *
          (3.14159 / 180), // Sweep angle in radians based on temperature
      false,
      tempPaint,
    );

    // Draw tick marks and labels
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw minimum and maximum temperature labels
    _drawTemperatureLabel(canvas, center, radius, -225,
        minTemp.toInt().toString() + "°", textPainter);
    _drawTemperatureLabel(canvas, center, radius, 45,
        maxTemp.toInt().toString() + "°", textPainter);
  }

  void _drawTemperatureLabel(Canvas canvas, Offset center, double radius,
      double angleDegrees, String text, TextPainter painter) {
    final angleRadians = angleDegrees * (3.14159 / 180);
    final x = center.dx + (radius - 40) * math.cos(angleRadians);
    final y = center.dy + (radius - 40) * math.sin(angleRadians);

    painter.text = TextSpan(
      text: text,
      style: TextStyle(color: Colors.black, fontSize: 14),
    );

    painter.layout();
    painter.paint(
        canvas, Offset(x - painter.width / 2, y - painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant TemperatureArcPainter oldDelegate) {
    return temperature != oldDelegate.temperature;
  }
}

// Air Conditioner Page from second code
class AirConditionerPage extends StatefulWidget {
  @override
  _AirConditionerPageState createState() => _AirConditionerPageState();
}

class _AirConditionerPageState extends State<AirConditionerPage> {
  Map<String, List<String>> roomsWithDevices = {
    "Bedroom": ["Room AC UNIT-1"],
  };

  void _addDevice(String room) {
    TextEditingController deviceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Device"),
          content: TextField(
            controller: deviceController,
            decoration: InputDecoration(hintText: "Enter device name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (deviceController.text.isNotEmpty) {
                    roomsWithDevices[room]?.add(deviceController.text);
                  }
                });
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _removeDevice(String room) {
    if (roomsWithDevices[room]!.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        String? selectedDevice;
        return AlertDialog(
          title: Text("Remove Device"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text("Select device"),
                value: selectedDevice,
                onChanged: (value) {
                  setState(() {
                    selectedDevice = value;
                  });
                },
                items: roomsWithDevices[room]!
                    .map((device) => DropdownMenuItem(
                          value: device,
                          child: Text(device),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (selectedDevice != null) {
                  setState(() {
                    roomsWithDevices[room]!.remove(selectedDevice);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToControlPage(String device) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ACControlPage(deviceName: device)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 176, 222, 243),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        //actions: [
          //Icon(Icons.person),
          //SizedBox(width: 16),
       // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Air Conditioners",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: roomsWithDevices.keys.map((room) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        color: Colors.teal,
                        child: Text(
                          room,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 30),
                      ...roomsWithDevices[room]!.map(
                        (device) => GestureDetector(
                          onTap: () => _navigateToControlPage(device),
                          child: ACDeviceCard(device: device),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () => _addDevice(room),
                            icon: Icon(Icons.add_circle, color: Colors.green),
                            label: Text("Add device"),
                          ),
                          SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: () => _removeDevice(room),
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            label: Text("Remove device"),
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RobotStatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 146, 170),
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Robot menu bar with a back arrow
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 146, 211, 235),
            padding: EdgeInsets.all(10),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous page
                    },
                  ),
                ),
                Center(
                  child: Text(
                    'Robot',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          BatteryStatus(),
          SizedBox(height: 20),
          CurrentMode(),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Image.network(
      //           'https://cdn-icons-png.flaticon.com/128/25/25694.png',
      //           width: 30,
      //           height: 30),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.network(
      //           'https://cdn-icons-png.flaticon.com/128/2567/2567943.png',
      //           width: 30,
      //           height: 30),
      //       label: 'Stats',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.network(
      //           'https://cdn-icons-png.flaticon.com/128/16600/16600277.png',
      //           width: 30,
      //           height: 30),
      //       label: 'Settings',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.network(
      //           'https://cdn-icons-png.flaticon.com/512/847/847969.png',
      //           width: 30,
      //           height: 30),
      //       label: 'More',
      //     ),
      //   ],
      // ),
    );
  }
}

class BatteryStatus extends StatelessWidget {
  final double batteryLevel = 40; // Battery percentage (0-100)

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(
            'Battery',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Stack(
            clipBehavior: Clip.none, // Allows small rectangle to go outside
            children: [
              // Battery Border
              Container(
                width: 110,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
              // Battery Fill (Yellow-Green)
              Positioned(
                left: 4,
                top: 6,
                child: Container(
                  width: (batteryLevel / 100) * 100, // Dynamic width
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E84A), // Bright yellow-green
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Battery Terminal (Small Rectangle)
              Positioned(
                right: -14, // Moves it outside but attached
                top: 12,
                child: Container(
                  width: 14,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Battery Life : 3 Hours 11 Minutes',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class CurrentMode extends StatefulWidget {
  @override
  _CurrentModeState createState() => _CurrentModeState();
}

class _CurrentModeState extends State<CurrentMode> {
  String selectedMode = "Active"; // Default selected mode

  void setMode(String mode) {
    setState(() {
      selectedMode = mode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mode changed to $mode')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(
            'Current Mode',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              modeButton(
                'Sleep',
                'https://cdn-icons-png.flaticon.com/128/3511/3511280.png',
              ),
              modeButton(
                'Active',
                'https://cdn-icons-png.flaticon.com/128/6502/6502370.png',
              ),
              modeButton(
                'Charging',
                'https://cdn-icons-png.flaticon.com/128/3103/3103277.png',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget modeButton(String mode, String iconUrl) {
    bool isSelected = selectedMode == mode;

    return GestureDetector(
      onTap: () => setMode(mode),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: Image.network(iconUrl, width: 30, height: 30),
          ),
          SizedBox(height: 5),
          Text(mode),
        ],
      ),
    );
  }
}

