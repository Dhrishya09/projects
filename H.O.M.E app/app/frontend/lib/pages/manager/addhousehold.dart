import 'package:flutter/material.dart';
import 'package:flutter_application_1/BackendServices/backend_service.dart';

class AddHouseholdPage extends StatefulWidget {
  const AddHouseholdPage({super.key});

  @override
  _AddHouseholdPageState createState() => _AddHouseholdPageState();
}

class _AddHouseholdPageState extends State<AddHouseholdPage> {
  final _formKey = GlobalKey<FormState>();
  String _householdName = '';
  String _houseNumber = '';
  String _houseType = 'Flat';
  String _streetNumber = '';
  String _location = '';
  int _numRooms = 1;

  void _saveHousehold() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool success = await BackendService.addHousehold({
        'household_name': _householdName,
        'house_number': _houseNumber,
        'house_type': _houseType,
        'street_number': _streetNumber,
        'location': _location,
        'num_rooms': _numRooms,
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Household Saved!')),
        );
        Navigator.pop(context, {
          'name': _householdName,
          'number': _houseNumber,
          'type': _houseType,
          'street': _streetNumber,
          'location': _location,
          'rooms': _numRooms,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save household. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Household')),
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white.withAlpha(225),
                BlendMode.lighten,
              ),
              child: Image.asset(
                'assets/bg.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField('Household Name', (value) {
                                _householdName = value!;
                              }),

                              _buildTextField('House Number', (value) {
                                _houseNumber = value!;
                              }),

                              _buildTextField('Location', (value) {
                                _location = value!;
                              }),

                              _buildDropdown(),

                              _buildTextField('Street Number', (value) {
                                _streetNumber = value!;
                              }),

                              _buildTextField(
                                'Number of Rooms',
                                (value) {
                                  if (value != null && value.isNotEmpty) {
                                    _numRooms = int.parse(value);
                                  }
                                },
                                keyboardType: TextInputType.number,
                              ),

                              SizedBox(height: screenHeight * 0.03),

                              SizedBox(
                                width: screenWidth > 600 ? 400 : double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveHousehold,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02,
                                    ),
                                    textStyle: TextStyle(fontSize: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Save Household'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSave,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        onSaved: onSave,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'House Type',
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400),
          ),
        ),
        value: _houseType,
        items: ['Flat', 'Villa']
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
        onChanged: (value) => setState(() => _houseType = value!),
        validator: (value) =>
            value == null ? 'Please select a house type' : null,
      ),
    );
  }
}
