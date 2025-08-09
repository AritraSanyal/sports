import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/unified_model.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import '../widgets/custom_dropdown.dart';
import '../providers/user_provider.dart';

class UnifiedCreateRequirementScreen extends StatefulWidget {
  final CompanionType type;

  const UnifiedCreateRequirementScreen({super.key, required this.type});

  @override
  State<UnifiedCreateRequirementScreen> createState() =>
      _UnifiedCreateRequirementScreenState();
}

class _UnifiedCreateRequirementScreenState
    extends State<UnifiedCreateRequirementScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedActivity;
  String? _selectedModeOfTransport; // New field

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _eventVenueController = TextEditingController();
  final TextEditingController _meetVenueController = TextEditingController();
  String? _selectedCity;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? _selectedDescription;
  String? _selectedGender;
  String? _selectedAge;
  String? _selectedType;
  DateTime? _selectedDate;
  double _timerHours = 1;
  String? _selectedSubcategory;

  late List<String> _activityOptions;
  late String _activityLabel;
  late String _title;
  late String _activityKey;

  final List<String> _cityOptions = [
    'Ahmedabad',
    'Bangalore',
    'Bhopal',
    'Chandigarh',
    'Chennai',
    'Delhi',
    'Hyderabad',
    'Indore',
    'Jaipur',
    'Kanpur',
    'Kochi',
    'Kolkata',
    'Lucknow',
    'Mumbai',
    'Nagpur',
    'Patna',
    'Pune',
    'Ranchi',
    'Surat',
    'Visakhapatnam',
  ];
  final List<String> _descriptionOptions = [
    'Looking for professional companion',
    'Looking for a solo companion',
    'Looking for an online companion',
    'Looking for multiple companions',
  ];
  final List<String> _genderOptions = ['All', 'Male', 'Female'];
  final List<String> _ageOptions = ['18-25', '26-33', '34-40', '40+'];
  final List<String> _typeOptions = ['Paid', 'Unpaid'];

  final List<String> _travelModes = [
    // New list
    'Car',
    'Bike',
    'Train',
    'Flight',
    'Bus',
    'Walk',
    'Cruise',
    'Public Transport',
  ];

  final Map<String, List<String>> subcategories = {
    "Gym": [
      "Cardio Gym",
      "Strength Training Gym",
      "Powerlifting Gym",
      "Bodybuilding Gym",
      "Functional Training Gym",
      "CrossFit Gym",
      "Calisthenics Gym",
      "Zumba Gym",
      "Aerobic Gym",
      "Weight Training Gym",
      "Edurance training Gym",
      "Pilates Gym",
      "HIIT Gym",
      "Spinning Gym",
      "Circuit Training",
    ],
    "Badminton": [
      "Singles Badminton",
      "Doubles Badminton",
      "Mixed Doubles Badminton",
      "Indoor Badminton",
      "Outdoor (Recreational)",
    ],
    "Basketball": [
      "5-on-5 Full Court Basketball",
      "3x3 Basketball",
      "Street Basketball",
      "Skill Training (Dribbling, Shooting)",
    ],
    "Boxing": [
      "Amateur Boxing",
      "Professional Boxing",
      "Shadow Boxing",
      "Pad Work",
      "Sparring",
    ],
    "Chess": [
      "Classical Chess",
      "Rapid Chess",
      "Blitz Chess",
      "Bullet Chess",
      "Online Chess",
      "Chess960 (Fischer Random)",
    ],
    "Cricket": [
      "Test Matches",
      "One Day Internationals (ODIs)",
      "T20 Cricket",
      "Street/Box Cricket",
      "Indoor Cricket",
    ],
    "Cycling": [
      "Road Cycling",
      "Mountain Biking",
      "Track Cycling",
      "Cyclocross",
      "BMX",
      "Spinning/Indoor Cycling",
    ],
    "Football": [
      "11-a-side Football",
      "Futsal",
      "5-a-side Football",
      "Street Football",
      "Freestyle Football",
    ],
    "Hockey": [
      "Field Hockey",
      "Ice Hockey",
      "Street Hockey",
      "Roller Hockey",
      "Indoor Hockey",
    ],
    "Kabaddi": [
      "Standard Style Kabaddi",
      "Circle Style Kabaddi",
      "Beach Kabaddi",
      "Indoor Kabaddi",
    ],
    "Martial Arts": [
      "Karate",
      "Taekwondo",
      "Judo",
      "Brazilian Jiu-Jitsu",
      "Muay Thai",
      "Kickboxing",
      "Mixed Martial Arts (MMA)",
      "Kung Fu",
    ],
    "Running": [
      "Sprints",
      "Middle Distance Running",
      "Long Distance Running",
      "Trail Running",
      "Marathons",
      "Ultra-marathons",
      "Treadmill Running",
    ],
    "Skating": [
      "Inline Skating",
      "Roller Skating",
      "Ice Skating",
      "Speed Skating",
      "Figure Skating",
      "Skateboarding (Street, Vert)",
    ],
    "Swimming": [
      "Freestyle",
      "Breaststroke",
      "Backstroke",
      "Butterfly",
      "Open Water Swimming",
      "Synchronized Swimming",
      "Competitive Racing",
    ],
    "Table Tennis": [
      "Singles Table Tennis",
      "Doubles Table Tennis",
      "Mixed Doubles Table Tennis",
      "Speed Training",
      "Spin Techniques",
    ],
    "Tennis": [
      "Singles Tennis",
      "Doubles Tennis",
      "Mixed Doubles Tennis",
      "Grass Court Tennis",
      "Clay Court Tennis",
      "Hard Court",
    ],
    "Volleyball": [
      "Indoor Volleyball",
      "Beach Volleyball",
      "Sitting Volleyball (Para-sports)",
      "Recreational/Street Volleyball",
    ],
    "Weightlifting": [
      "Olympic Lifts (Snatch, Clean & Jerk)",
      "Powerlifting (Squat, Bench, Deadlift)",
      "Bodybuilding",
      "Functional Weight Training",
    ],
    "Yoga": [
      "Hatha Yoga",
      "Vinyasa Yoga",
      "Power Yoga",
      "Ashtanga Yoga",
      "Restorative Yoga",
      "Hot Yoga",
      "Prenatal Yoga",
    ],
  };

  @override
  void initState() {
    super.initState();
    _setupTypeSpecificOptions();
  }

  void _setupTypeSpecificOptions() {
    switch (widget.type) {
      case CompanionType.sport:
        _title = 'Create Sport Requirement';
        _activityLabel = 'Sport';
        _activityKey = 'sport';
        _activityOptions = [
          'Badminton',
          'Basketball',
          'Boxing',
          'Chess',
          'Cricket',
          'Cycling',
          'Football',
          'Gym',
          'Hockey',
          'Kabaddi',
          'Martial Arts',
          'Running',
          'Skating',
          'Swimming',
          'Table Tennis',
          'Tennis',
          'Volleyball',
          'Weightlifting',
          'Yoga',
        ];

        break;
      case CompanionType.food:
        _title = 'Create Food Requirement';
        _activityLabel = 'Cuisine/Meal';
        _activityKey = 'food';
        _activityOptions = [
          'Food and Beverage',
          'Drinks and Juice',
          'Snacks',
          'Lunch',
          'Dinner',
          'Breakfast',
          'Brunch',
          'Coffee',
          'Dessert',
          'Street Food',
          'Fine Dining',
          'Buffet',
          'BBQ',
          'Vegan',
          'Vegetarian',
          'Non-Vegetarian',
          'Seafood',
          'Italian',
          'Chinese',
          'Indian',
        ];
        break;
      case CompanionType.travel:
        _title = 'Create Travel Requirement';
        _activityLabel = 'Destination';
        _activityKey = 'travel';
        _activityOptions = [
          'Beach',
          'Mountain',
          'City Tour',
          'Historical Places',
          'Adventure',
          'Wildlife',
          'Road Trip',
          'Camping',
          'Hiking',
          'Trekking',
          'Backpacking',
          'Luxury Travel',
          'Budget Travel',
          'Solo Travel',
          'Group Travel',
          'Cultural Tour',
          'Religious Tour',
          'Photography Tour',
          'Food Tour',
          'Shopping Tour',
        ];
        break;
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      controller.text = picked.format(context);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _showAlert(String title, String message) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  String _getDatabasePath() {
    switch (widget.type) {
      case CompanionType.sport:
        return 'requirements';
      case CompanionType.food:
        return 'food';
      case CompanionType.travel:
        return 'travel';
    }
  }

  String _getGroupsPath() {
    switch (widget.type) {
      case CompanionType.sport:
        return 'groups';
      case CompanionType.food:
        return 'food_groups';
      case CompanionType.travel:
        return 'travel_groups';
    }
  }

  Future<void> _submitForm() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null || user.id == null || user.id.isEmpty) {
      await _showAlert(
        "Authentication Error",
        "User is not logged in. Please restart the app.",
      );
      return;
    }

    if (_formKey.currentState!.validate() &&
        _selectedActivity != null &&
        _selectedCity != null &&
        _selectedDescription != null &&
        _selectedGender != null &&
        _selectedAge != null &&
        _selectedType != null &&
        _selectedDate != null &&
        _startTimeController.text.isNotEmpty &&
        _endTimeController.text.isNotEmpty &&
        (widget.type != CompanionType.travel ||
            _selectedModeOfTransport != null)) {
      final requirementId = DateTime.now().millisecondsSinceEpoch.toString();
      final timestamp = DateTime.now().toIso8601String();

      final requirementData = {
        _activityKey: _selectedActivity,
        "groupName": _groupNameController.text.trim(),
        "eventVenue": _eventVenueController.text.trim(),
        "meetVenue": _meetVenueController.text.trim(),
        "city": _selectedCity,
        "description": _selectedDescription,
        "gender": _selectedGender,
        "ageLimit": _selectedAge,
        "type": _selectedType,
        "date": DateFormat('yyyy-MM-dd').format(_selectedDate!),
        "startTime": _startTimeController.text,
        "endTime": _endTimeController.text,
        "timer": _timerHours.toInt(),
        "createdBy": user.id,
        "groupId": requirementId,
        "timestamp": timestamp,
        "imageUrl": "",
      };

      if (widget.type == CompanionType.travel) {
        requirementData["modeOfTransport"] = _selectedModeOfTransport;
      }
      if (widget.type == CompanionType.sport && _selectedSubcategory != null) {
        requirementData["subcategory"] = _selectedSubcategory;
      }

      final groupData = {
        "groupName": requirementData["groupName"],
        "createdBy": user.id,
        "members": [user.id],
        "requests": {},
      };

      const firebaseProjectId = "sportsapp1-31d70-default-rtdb";

      final requirementUrl = Uri.parse(
        "https://$firebaseProjectId.firebaseio.com/${_getDatabasePath()}/$requirementId.json",
      );
      final groupUrl = Uri.parse(
        "https://$firebaseProjectId.firebaseio.com/${_getGroupsPath()}/$requirementId.json",
      );

      try {
        final reqResponse = await http.put(
          requirementUrl,
          body: jsonEncode(requirementData),
        );
        if (reqResponse.statusCode >= 400) {
          await _showAlert(
            "Requirement Upload Failed",
            "Status: ${reqResponse.statusCode}\n${reqResponse.body}",
          );
          return;
        }

        final groupResponse = await http.put(
          groupUrl,
          body: jsonEncode(groupData),
        );
        if (groupResponse.statusCode >= 400) {
          await _showAlert(
            "Group Creation Failed",
            "Status: ${groupResponse.statusCode}\n${groupResponse.body}",
          );
          return;
        }

        await _showAlert(
          "Success",
          "Your requirement has been posted successfully.",
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        await _showAlert("An Error Occurred", "An exception was thrown: $e");
      }
    } else {
      await _showAlert(
        "Form Incomplete",
        "Please fill all the fields correctly.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.lightSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomDropdown(
                label: _activityLabel,
                items: _activityOptions,
                value: _selectedActivity,
                onChanged: (val) {
                  setState(() {
                    _selectedActivity = val;
                    _selectedSubcategory = null; // reset subcategory
                  });
                },
              ),
              if (widget.type == CompanionType.travel) ...[
                const SizedBox(height: 10),
                CustomDropdown(
                  label: "Mode of Transport",
                  items: _travelModes,
                  value: _selectedModeOfTransport,
                  onChanged:
                      (val) => setState(() => _selectedModeOfTransport = val),
                ),
              ],

              if (widget.type == CompanionType.sport &&
                  _selectedActivity != null &&
                  subcategories.containsKey(_selectedActivity)) ...[
                const SizedBox(height: 10),
                CustomDropdown(
                  label: "Subcategory",
                  items: subcategories[_selectedActivity]!,
                  value: _selectedSubcategory,
                  onChanged:
                      (val) => setState(() => _selectedSubcategory = val),
                ),
              ],

              const SizedBox(height: 10),
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
                validator: (value) => value!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _eventVenueController,
                decoration: const InputDecoration(
                  labelText: 'Event Venue',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _meetVenueController,
                decoration: const InputDecoration(
                  labelText: 'Meet Venue',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                label: 'City',
                items: _cityOptions,
                value: _selectedCity,
                onChanged: (val) => setState(() => _selectedCity = val),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                label: "Description",
                items: _descriptionOptions,
                value: _selectedDescription,
                onChanged: (val) => setState(() => _selectedDescription = val),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                label: "Gender",
                items: _genderOptions,
                value: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                label: "Age Limit",
                items: _ageOptions,
                value: _selectedAge,
                onChanged: (val) => setState(() => _selectedAge = val),
              ),
              const SizedBox(height: 10),
              CustomDropdown(
                label: "Type",
                items: _typeOptions,
                value: _selectedType,
                onChanged: (val) => setState(() => _selectedType = val),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDate != null
                      ? "Date: ${DateFormat('yMMMMd').format(_selectedDate!)}"
                      : "Select Date",
                  style: const TextStyle(color: AppTheme.primaryColor),
                ),
                trailing: const Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryColor,
                ),
                onTap: _selectDate,
              ),
              TextFormField(
                style: const TextStyle(color: AppTheme.primaryColor),
                controller: _startTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
                onTap: () => _selectTime(_startTimeController),
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: const TextStyle(color: AppTheme.primaryColor),
                controller: _endTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
                onTap: () => _selectTime(_endTimeController),
              ),
              const SizedBox(height: 16),
              Text("Card Duration (hours): ${_timerHours.toInt()}"),
              Slider(
                value: _timerHours,
                min: 1,
                max: 72,
                divisions: 71,
                label: _timerHours.toInt().toString(),
                onChanged: (value) => setState(() => _timerHours = value),
                inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.send),
                label: const Text("Submit Requirement"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
