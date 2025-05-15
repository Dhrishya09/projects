import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'user/nav.dart';

class Graph extends StatelessWidget {
  const Graph({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavPage(
        currentIndex: 2, // Graphs tab index
        child: EnergyAnalyticsPage(),
      ),
    );
  }
}

class EnergyAnalyticsPage extends StatefulWidget {
  const EnergyAnalyticsPage({super.key});

  @override
  _EnergyAnalyticsPageState createState() => _EnergyAnalyticsPageState();
}

class _EnergyAnalyticsPageState extends State<EnergyAnalyticsPage> {
  String selectedPeriod = 'Week';
  String selectedValue = 'Week 1';
  String selectedHousehold = 'House 1';
  String selectedRoom = 'Living Room';
  String selectedDevice = 'Lights';

  final List<String> periods = ['Week', 'Month', 'Year'];
  final List<String> rooms = [
    'Bedroom',
    'Living Room',
    'Dining Room',
    'Kitchen'
  ];

  final Map<String, List<String>> roomDevices = {
    'Bedroom': ['Lights', 'AC', 'Robot'],
    'Living Room': ['Lights', 'TV', 'AC'],
    'Dining Room': ['Lights', 'AC'],
    'Kitchen': ['Fridge', 'Lights', 'Oven'],
  };

  final Map<String, List<String>> dropdownOptions = {
    'Week': List.generate(4, (index) => 'Week ${index + 1}'),
    'Month': [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ],
    'Year': ['2023', '2024', '2025', '2026'],
  };

  Map<String, Map<String, List<double>>> energyUsage = {
    'Week': {
      'Lights': [10, 12, 11, 10],
      'Robots': [5, 6, 4, 5],
      'AC': [20, 18, 21, 19],
      'TV': [8, 7, 9, 7],
    },
    'Month': {
      'Lights': [50, 55, 53, 50, 58, 60, 62, 64, 68, 70, 75, 80],
      'Robots': [20, 22, 19, 18, 25, 28, 30, 32, 35, 40, 45, 50],
      'AC': [150, 145, 160, 155, 170, 180, 185, 190, 200, 210, 220, 230],
      'TV': [40, 38, 42, 40, 45, 47, 50, 52, 55, 60, 65, 70],
    },
    'Year': {
      'Lights': [600, 620, 610, 590],
      'Robots': [200, 210, 190, 180],
      'AC': [2000, 1950, 2050, 1950],
      'TV': [480, 460, 490, 470],
    },
  };

  double predictEnergyConsumption(List<double> pastData) {
    double growthFactor = 0.05;
    return pastData.last * (1 + growthFactor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        title: Text('Energy Statistics', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    color: Colors.black,
                    fillColor: Colors.deepPurple,
                    borderColor: Colors.purple,
                    constraints: BoxConstraints(minWidth: 110, minHeight: 40),
                    isSelected:
                        periods.map((p) => p == selectedPeriod).toList(),
                    onPressed: (index) {
                      setState(() {
                        selectedPeriod = periods[index];
                        selectedValue = dropdownOptions[selectedPeriod]!.first;
                      });
                    },
                    children: periods
                        .map((p) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(p, style: TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 15),
                _buildPeriodAndHouseholdSelections(),
                SizedBox(height: 15),
                Text("Select Room:", style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                _buildRoomSelection(),
                SizedBox(height: 15),
                Text("Select Device:", style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                _buildDeviceSelection(),
                SizedBox(height: 15),
                _buildGraphSection(),
              ],
            ),
          ),
        ),
      ),
      // Bottom navigation is now handled by NavPage
    );
  }

  // Helper method for period and household selections
  Widget _buildPeriodAndHouseholdSelections() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select $selectedPeriod:'),
            DropdownButton<String>(
              value: selectedValue,
              onChanged: (newValue) {
                setState(() => selectedValue = newValue!);
              },
              items: dropdownOptions[selectedPeriod]!
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
            ),
          ],
        ),
        
      ],
    );
  }

  // Room selection method
  Widget _buildRoomSelection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return _buildRoomCard(rooms[index]);
        },
      ),
    );
  }

  // Device selection method
  Widget _buildDeviceSelection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: roomDevices[selectedRoom]!.length,
        itemBuilder: (context, index) {
          return _buildDeviceCard(roomDevices[selectedRoom]![index]);
        },
      ),
    );
  }

  // Graph section method
  Widget _buildGraphSection() {
    return Column(
      children: [
        _buildGraphCard('Energy Usage', Colors.blue, _buildLineChart),
        SizedBox(height: 10),
        _buildGraphCard(
            'Projected Energy Consumption', Colors.red, _buildPredictionGraph),
      ],
    );
  }

  // Room card widget
  Widget _buildRoomCard(String room) {
    bool isSelected = selectedRoom == room;

    // Define icons for each room using image URLs
    Map<String, String> roomIcons = {
      "Bedroom": "https://cdn-icons-png.flaticon.com/128/494/494970.png",
      "Living Room": "https://cdn-icons-png.flaticon.com/128/494/494973.png",
      "Kitchen": "https://cdn-icons-png.flaticon.com/128/2607/2607254.png",
      "Dining Room": "https://cdn-icons-png.flaticon.com/128/6937/6937721.png",
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRoom = room;
          selectedDevice = roomDevices[room]!.first;
        });
      },
      child: Container(
        width: 100,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              roomIcons[room]!,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.red);
              },
            ),
            SizedBox(height: 8),
            Text(
              room,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Define a map for device icons
  Map<String, dynamic> deviceIcons = {
    'Lights': Icons.lightbulb_outline,
    'AC': Icons.ac_unit,
    'TV': Icons.tv,
    'Fridge': Icons.kitchen,
    'Oven': Icons.local_fire_department,
    'Robot':
        'https://cdn-icons-png.flaticon.com/128/2432/2432846.png', // URL for robot icon
  };

  Widget _buildDeviceCard(String device) {
    bool isSelected = selectedDevice == device;
    dynamic iconData = deviceIcons[device];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDevice = device;
        });
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Check if iconData is a URL string or an IconData
            iconData is String
                ? Image.network(
                    iconData,
                    height: 30,
                    width: 30,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error, size: 30, color: Colors.red),
                  )
                : Icon(
                    iconData ?? Icons.devices,
                    color: isSelected ? Colors.white : Colors.black54,
                    size: 30,
                  ),
            SizedBox(height: 8),
            Text(
              device,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Graph card widget
  Widget _buildGraphCard(String title, Color color, Widget Function() graph) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(height: 200, child: graph()),
          ],
        ),
      ),
    );
  }

  // Line chart widget
  Widget _buildLineChart() {
    List<double> data =
        energyUsage[selectedPeriod]?[selectedDevice] ?? [0, 0, 0, 0];
    List<String> xLabels = dropdownOptions[selectedPeriod]!;

    List<FlSpot> spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < xLabels.length) {
                  return Text(xLabels[value.toInt()],
                      style: TextStyle(fontSize: 10));
                }
                return Text('');
              },
            ),
          ),
        ),
      ),
    );
  }

  // Prediction graph widget
  Widget _buildPredictionGraph() {
    List<double> data =
        energyUsage[selectedPeriod]?[selectedDevice] ?? [0, 0, 0, 0];
    double predictedValue = predictEnergyConsumption(data);
    List<FlSpot> spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
    spots.add(FlSpot(spots.length.toDouble(), predictedValue));

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}