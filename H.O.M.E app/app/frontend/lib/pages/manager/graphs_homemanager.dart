import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'bottom_nav_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';

class EnergyAnalyticsApp extends StatelessWidget {
  const EnergyAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EnergyAnalyticsPage(),
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
  List<String> householdList = ['House 1', 'House 2', 'House 3', 'House 4'];

  final List<String> periods = ['Week', 'Month', 'Year'];
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

  // Global data variables
  List<dynamic> day = [];
  List<dynamic> week = [];
  List<dynamic> month = [];
  Map<String, List<double>> energyUsage = {
    'Week': [],
    'Month': [],
    'Year': [],
  };

  @override
  void initState() {
    super.initState();
    _connectToRaspberryPi();
  }

  Future<void> _connectToRaspberryPi() async {
    final url = Uri.parse('http://10.6.157.244:5000/week'); // Replace with your Raspberry Pi's IP address

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('Day') &&
            responseData.containsKey('Month') &&
            responseData.containsKey('Week')) {
          
          setState(() {
            day = List<dynamic>.from(responseData['Day']);
            week = List<dynamic>.from(responseData['Week']);
            month = List<dynamic>.from(responseData['Month']);

            // Convert the dynamic lists to List<double>
            energyUsage['Day'] = day.map((e) => e is num ? e.toDouble() : 0.0).toList();
            energyUsage['Week'] = week.map((e) => e is num ? e.toDouble() : 0.0).toList();
            energyUsage['Month'] = month.map((e) => e is num ? e.toDouble() : 0.0).toList();
          });

        } else {
          _showErrorDialog(context, 'Unexpected response format from Raspberry Pi.');
        }
      } else {
        _showErrorDialog(context, 'Failed to connect to Raspberry Pi.');
      }
    } catch (e) {
      _showErrorDialog(context, 'An error occurred while connecting to Raspberry Pi.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Connection Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  double predictEnergyConsumption(List<double> pastData) {
    if (pastData.isEmpty) return 0;
    double growthFactor = 0.05;
    return pastData.last * (1 + growthFactor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 153, 199, 237),
        elevation: 0,
        leading: Container(),
        title: Text('Energy Statistics', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
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
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Household:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedHousehold,
                  onChanged: (newValue) {
                    setState(() => selectedHousehold = newValue!);
                  },
                  items: householdList
                      .map((house) =>
                          DropdownMenuItem(value: house, child: Text(house)))
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: [
                  _buildGraphCard('Energy Usage', Colors.blue, _buildBarChart),
                  SizedBox(height: 10),
                  _buildGraphCard('Projected Energy Consumption', Colors.red,
                      _buildPredictionGraph),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 2),
    );
  }

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

  Widget _buildBarChart() {
    List<double> data = energyUsage[selectedPeriod] ?? [];

    // Handle empty data
    if (data.isEmpty) {
      return Center(child: Text('No data available for this period.'));
    }

    List<String> xLabels = dropdownOptions[selectedPeriod]!;

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
                width: 22,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(0),
                    style: TextStyle(fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < xLabels.length) {
                  return Text(xLabels[value.toInt()],
                      style: TextStyle(fontSize: 12));
                }
                return Text('');
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionGraph() {
    List<double> data = energyUsage[selectedPeriod] ?? [];

    // Handle empty data
    if (data.isEmpty) {
      return Center(child: Text('No data available for this period.'));
    }

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
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
            color: Colors.red,
          ),
        ],
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
      ),
    );
  }
}
