// import 'package:flutter/material.dart';
// import 'backend_service.dart';

// class DeviceControlWidget extends StatefulWidget {
//   const DeviceControlWidget({super.key});

//   @override
//   _DeviceControlWidgetState createState() => _DeviceControlWidgetState();
// }

// class _DeviceControlWidgetState extends State<DeviceControlWidget> {
//   String deviceId = 'abc123'; // Replace with the actual device ID

//   void _toggleDevice() async {
//     bool success = await BackendService.toggleDevice(deviceId, 'on');
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Device toggled successfully!')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to toggle device.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: _toggleDevice,
//         child: const Text('Toggle Device'),
//       ),
//     );
//   }
// }