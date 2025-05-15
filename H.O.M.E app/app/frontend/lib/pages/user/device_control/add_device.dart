import 'package:flutter/material.dart';

class AddDevicePopup extends StatefulWidget {
  final Function(String, IconData) onAddDevice;
  final List<String> existingDeviceNames; // List of existing device names

  const AddDevicePopup({
    super.key,
    required this.onAddDevice,
    required this.existingDeviceNames,
  });

  @override
  _AddDevicePopupState createState() => _AddDevicePopupState();
}

class _AddDevicePopupState extends State<AddDevicePopup> {
  final TextEditingController _deviceNameController = TextEditingController();
  IconData? _selectedIcon;
  String? _errorMessage; // State variable for error message

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Device"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _deviceNameController,
            decoration: InputDecoration(
              labelText: "Device Name",
              errorText: _errorMessage, // Display error message here
            ),
            onChanged: (value) {
              // Clear the error message when the user starts typing
              setState(() {
                _errorMessage = null;
              });
            },
          ),
          SizedBox(height: 20),
          Text("Select Icon:"),
          Wrap(
            spacing: 10,
            children: [
              IconButton(
                icon: Icon(Icons.lightbulb),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Light";
                    _selectedIcon = Icons.lightbulb;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.tv),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Smart TV";
                    _selectedIcon = Icons.tv;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.ac_unit),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Air Conditioning";
                    _selectedIcon = Icons.ac_unit;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.speaker),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Speaker";
                    _selectedIcon = Icons.speaker;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.microwave),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Microwave";
                    _selectedIcon = Icons.microwave;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.kitchen),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Refrigerator";
                    _selectedIcon = Icons.kitchen;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.laptop),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Laptop";
                    _selectedIcon = Icons.laptop;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.whatshot),
                onPressed: () {
                  setState(() {
                    _deviceNameController.text = "Heater";
                    _selectedIcon = Icons.whatshot;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final deviceName = _deviceNameController.text.trim();
            if (deviceName.isEmpty) {
              setState(() {
                _errorMessage = "Device name cannot be empty";
              });
              return;
            }

            if (widget.existingDeviceNames.contains(deviceName)) {
              setState(() {
                _errorMessage = "Device already exists";
              });
              return;
            }

            if (_selectedIcon == null) {
              setState(() {
                _errorMessage = "Please select an icon";
              });
              return;
            }

            // If everything is valid, call the onAddDevice callback
            widget.onAddDevice(deviceName, _selectedIcon!);
            Navigator.pop(context);
          },
          child: Text("Create Device"),
        ),
      ],
    );
  }
}