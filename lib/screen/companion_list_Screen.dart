import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/unified_model.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screen/profile_screen.dart';
import 'package:flutter_app/screen/unified_create_requirement.dart';
import 'package:flutter_app/screen/view_groups_screen.dart';
import 'package:flutter_app/services/unified_location_service.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_app/widgets/circular_avatar.dart';
import 'package:flutter_app/widgets/unified_companion_card.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CompanionListScreen extends StatefulWidget {
  final CompanionType type;
  final String imagePath;
  final String caption;
  const CompanionListScreen({
    super.key,
    required this.type,
    required this.imagePath,
    required this.caption,
  });

  @override
  State<CompanionListScreen> createState() => _CompanionListScreenState();
}

class _CompanionListScreenState extends State<CompanionListScreen> {
  String? selectedCity;
  String? selectedActivity;
  String? selectedSubcategory;
  String? selectedTransportMode;
  String gender = 'All';
  String age = 'All';
  String type = 'All';
  DateTime? selectedDate;
  double distance = 0;

  List<UnifiedCompanionModel> allData = [];
  List<UnifiedCompanionModel> filteredData = [];
  List<String> debugLogs = [];

  bool isDistanceActive = false;
  bool isLoading = true;
  bool showLogs = true;

  late List<String> activityOptions;
  late String activityLabel;
  late String screenTitle;

  // Dynamic subcategories map for all types
  final Map<String, List<String>> allSubcategories = {
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

  final List<String> cityOptions = [
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
  final List<String> travelModes = [
    'Car',
    'Bike',
    'Train',
    'Flight',
    'Bus',
    'Walk',
    'Cruise',
    'Public Transport',
  ];

  final UnifiedLocationService _locationService = UnifiedLocationService();

  void log(String msg) {
    print(msg);
    setState(() {
      debugLogs.add("[${DateFormat.Hms().format(DateTime.now())}] $msg");
      if (debugLogs.length > 100) debugLogs.removeAt(0);
    });
  }

  @override
  void initState() {
    super.initState();
    _setupTypeSpecificOptions();
    log("INIT: CompanionListScreen Started for ${widget.type}");
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  void _setupTypeSpecificOptions() {
    switch (widget.type) {
      case CompanionType.sport:
        activityOptions = [
          'Gym',
          'Badminton',
          'Basketball',
          'Boxing',
          'Chess',
          'Cricket',
          'Cycling',
          'Football',
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
        activityLabel = 'Sport';
        screenTitle = 'Find Sport Companions';
        break;
      case CompanionType.food:
        activityOptions = [
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
        activityLabel = 'Food';
        screenTitle = 'Find Food Companions';
        break;
      case CompanionType.travel:
        activityOptions = [
          'Beach',
          'Mountains',
          'City Tour',
          'Historical Places',
          'Adventure Park',
          'Wildlife Safari',
          'Camping',
          'Hiking',
          'Trekking',
          'Backpacking',
          'Luxury Resort',
          'Food Tour',
        ];
        activityLabel = 'Destination';
        screenTitle = 'Find Travel Companions';
        break;
    }
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

  List<String> getSubcategoriesForActivity(String? activity) {
    if (activity == null || !allSubcategories.containsKey(activity)) {
      return [];
    }
    return allSubcategories[activity]!;
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    log("Fetching data from Firebase...");

    try {
      final databasePath = _getDatabasePath();
      final url = Uri.parse(
        'https://sportsapp1-31d70-default-rtdb.firebaseio.com/$databasePath.json',
      );
      final response = await http.get(url);
      log("HTTP status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        log("Decoded JSON: ${decoded.runtimeType}");

        if (decoded != null && decoded is Map<String, dynamic>) {
          final now = DateTime.now();

          final items =
              decoded.entries
                  .map((e) {
                    final value = e.value as Map<String, dynamic>? ?? {};
                    final timestamp =
                        DateTime.tryParse(value['timestamp'] ?? '') ?? now;
                    final timer = value['timer'] ?? 0;
                    final endTime = timestamp.add(Duration(hours: timer));
                    if (endTime.isAfter(now)) {
                      return {
                        'id': e.key,
                        ...value,
                        'endTime': endTime.toIso8601String(),
                      };
                    } else {
                      return null;
                    }
                  })
                  .where((e) => e != null)
                  .cast<Map<String, dynamic>>()
                  .toList();

          log("Parsed ${items.length} items");

          final companions =
              items
                  .map(
                    (item) => UnifiedCompanionModel.fromMap(
                      item,
                      CompanionType.values[widget.type.index],
                    ),
                  )
                  .toList();

          setState(() {
            allData = companions;
            filteredData = companions;
          });
        } else {
          log("Empty or malformed response");
        }
      } else {
        log("Non-200 response: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception during fetch: $e");
    } finally {
      setState(() => isLoading = false);
      log("Fetch complete");
    }
  }

  Future<void> applyFilters() async {
    List<UnifiedCompanionModel> results = List.from(allData);

    if (!isDistanceActive && selectedCity != null && selectedCity!.isNotEmpty) {
      results =
          results
              .where(
                (item) => item.location.toLowerCase().contains(
                  selectedCity!.toLowerCase(),
                ),
              )
              .toList();
    }
    if (selectedTransportMode != null && selectedTransportMode!.isNotEmpty) {
      results =
          results
              .where(
                (item) =>
                    item.modeOfTransport?.toLowerCase() ==
                    selectedTransportMode!.toLowerCase(),
              )
              .toList();
    }

    if (selectedActivity != null && selectedActivity!.isNotEmpty) {
      results =
          results
              .where(
                (item) => item.name.toLowerCase().contains(
                  selectedActivity!.toLowerCase(),
                ),
              )
              .toList();
    }

    if (selectedSubcategory != null && selectedSubcategory!.isNotEmpty) {
      results =
          results
              .where(
                (item) =>
                    item.subcategory?.toLowerCase().contains(
                      selectedSubcategory!.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();
    }

    if (gender != 'All') {
      results = results.where((item) => item.gender == gender).toList();
    }

    if (age != 'All') {
      results = results.where((item) => item.ageLimit == age).toList();
    }

    if (type != 'All') {
      results = results.where((item) => item.paymentType == type).toList();
    }

    if (selectedDate != null) {
      results =
          results
              .where(
                (item) =>
                    item.date == DateFormat('yyyy-MM-dd').format(selectedDate!),
              )
              .toList();
    }

    if (isDistanceActive && distance > 0) {
      results = await _locationService.filterByDistance(results, distance);
    }

    log("Filters applied: ${results.length} items");
    log(
      "Active filters - City: $selectedCity, Activity: $selectedActivity, Subcategory: $selectedSubcategory",
    );

    setState(() {
      filteredData = results;
    });
  }

  void resetFilters() {
    selectedCity = null;
    selectedActivity = null;
    selectedSubcategory = null;
    gender = 'All';
    age = 'All';
    type = 'All';
    selectedDate = null;
    distance = 0;
    isDistanceActive = false;
    selectedTransportMode = null;

    setState(() => filteredData = allData);
  }

  selectScreenTitle() {
    if (widget.type == CompanionType.sport) {
      screenTitle = 'Find Sport Buddies';
    }
    if (widget.type == CompanionType.food) {
      screenTitle = 'Find Food Companions';
    }
    if (widget.type == CompanionType.travel) {
      screenTitle = 'Find Travel Partners';
    }
  }

  Widget _buildCustomDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value == 'All' ? null : value,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8B5CF6)),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    selectScreenTitle();
    final user = Provider.of<UserProvider>(context).user;
    final currentSubcategories = getSubcategoriesForActivity(selectedActivity);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (user != null)
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularAvatar(imageUrl: user.imageUrl, userId: user.id),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),

          // Action buttons section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  Container(
                    color: const Color(0xFFF3F0FF),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 64,
                            margin: const EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => UnifiedCreateRequirementScreen(
                                          type:
                                              CompanionType.values[widget
                                                  .type
                                                  .index],
                                        ),
                                  ),
                                );
                                await fetchData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8A50),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 64,
                            margin: const EdgeInsets.only(left: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ViewGroupsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF60A5FA),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Groups',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sports illustration container
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFF8A50).withOpacity(0.1),
                                const Color(0xFF8B5CF6).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Center(child: Image.asset(widget.imagePath)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.caption,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Join others and have fun together',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filters section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                  // City dropdown
                  if (!isDistanceActive)
                    _buildCustomDropdown(
                      value: selectedCity ?? 'All',
                      items: ['All', ...cityOptions],
                      onChanged: (val) => setState(() => selectedCity = val),
                      icon: Icons.location_city,
                      hint: 'City',
                    ),

                  // Activity/Sport dropdown
                  _buildCustomDropdown(
                    value: selectedActivity ?? 'All',
                    items: ['All', ...activityOptions],
                    onChanged: (val) {
                      setState(() {
                        selectedActivity = val;
                        selectedSubcategory = null;
                      });
                    },
                    icon:
                        widget.type == CompanionType.sport
                            ? Icons.sports
                            : widget.type == CompanionType.food
                            ? Icons.restaurant
                            : Icons.travel_explore,
                    hint: activityLabel,
                  ),

                  // Subcategory dropdown
                  if (currentSubcategories.isNotEmpty)
                    _buildCustomDropdown(
                      value: selectedSubcategory ?? 'All',
                      items: ['All', ...currentSubcategories],
                      onChanged:
                          (val) => setState(() => selectedSubcategory = val),
                      icon: Icons.category,
                      hint: '${selectedActivity ?? 'Activity'} Type',
                    ),

                  // Transport mode for travel
                  if (widget.type == CompanionType.travel)
                    _buildCustomDropdown(
                      value: selectedTransportMode ?? 'All',
                      items: ['All', ...travelModes],
                      onChanged:
                          (val) => setState(() => selectedTransportMode = val),
                      icon: Icons.directions,
                      hint: 'Mode of Travel',
                    ),

                  // Gender section
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  _buildCustomDropdown(
                    value: gender,
                    items: ['All', 'Male', 'Female'],
                    onChanged: (val) => setState(() => gender = val!),
                    icon: Icons.person,
                    hint: 'All',
                  ),

                  // Age section
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: const Text(
                      'Age Limit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  _buildCustomDropdown(
                    value: age,
                    items: ['All', '18-25', '26-33', '34-40', '40+'],
                    onChanged: (val) => setState(() => age = val!),
                    icon: Icons.cake,
                    hint: 'All',
                  ),

                  // Type section
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  _buildCustomDropdown(
                    value: type,
                    items: ['All', 'Paid', 'Unpaid'],
                    onChanged: (val) => setState(() => type = val!),
                    icon: Icons.payment,
                    hint: 'All',
                  ),

                  // Date selection
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => selectedDate = picked);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(selectedDate!)
                                : 'Select Date',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Distance section
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Distance:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '${distance.toInt()} km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF8B5CF6),
                        inactiveTrackColor: const Color(0xFFE5E7EB),
                        thumbColor: const Color(0xFF8B5CF6),
                        overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: distance,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (val) {
                          setState(() {
                            distance = val;
                            isDistanceActive = val > 0;
                          });
                        },
                      ),
                    ),
                  ),

                  // Action buttons
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      children: [
                        _buildActionButton(
                          text: 'Reset',
                          onPressed: resetFilters,
                          backgroundColor: const Color(0xFF9CA3AF),
                          textColor: Colors.white,
                          icon: Icons.refresh,
                        ),
                        _buildActionButton(
                          text: 'Apply',
                          onPressed: applyFilters,
                          backgroundColor: const Color(0xFF10B981),
                          textColor: Colors.white,
                          icon: Icons.filter_alt,
                        ),
                      ],
                    ),
                  ),

                  // Results section
                  if (filteredData.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Color(0xFFD1D5DB),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No companions found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredData.map((item) {
                      try {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: UnifiedCompanionCard(
                            companion: item,
                            onDeleted: () async {
                              await fetchData();
                            },
                          ),
                        );
                      } catch (e) {
                        log("Error rendering item: $e");
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Error rendering item",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
