import 'package:flutter/material.dart';

enum CompanionType { sport, food, travel }

class UnifiedCompanionModel {
  final String id;
  final String groupId; // ➡️ Added groupId field
  final String name;
  final String description;
  final String location;
  final String date;
  final String startTime;
  final String endTime;
  final String createdBy;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final CompanionType type;
  final String gender;
  final String ageLimit;
  final String paymentType;
  final int timer;
  final String timestamp;
  final String endTime2;
  final String? modeOfTransport;
  final String? subcategory;

  UnifiedCompanionModel({
    required this.id,
    required this.groupId, // ➡️ Added groupId in constructor
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.gender,
    required this.ageLimit,
    required this.paymentType,
    required this.timer,
    required this.timestamp,
    required this.endTime2,
    this.subcategory,
    this.modeOfTransport,
  });

  factory UnifiedCompanionModel.fromMap(
    Map<String, dynamic> map,
    CompanionType type,
  ) {
    return UnifiedCompanionModel(
      id: map['id'] ?? '',
      groupId: map['groupId'] ?? '', // ➡️ Fetch groupId from map
      name: map['groupName'] ?? '',
      description: map['description'] ?? '',
      location: map['city'] ?? '',
      date: map['date'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      createdBy: map['createdBy'] ?? '',
      imageUrl: map['sportImageUrl'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      type: type,
      gender: map['gender'] ?? 'All',
      ageLimit: map['ageLimit'] ?? '',
      paymentType: map['type'] ?? 'Unpaid',
      timer: map['timer'] ?? 24,
      timestamp: map['timestamp'] ?? DateTime.now().toIso8601String(),
      endTime2: map['endTime'] ?? '',
      subcategory: map['subcategory'],
      modeOfTransport: map['modeOfTransport'],
    );
  }

  IconData get typeIcon {
    switch (type) {
      case CompanionType.sport:
        return Icons.sports_soccer;
      case CompanionType.food:
        return Icons.restaurant;
      case CompanionType.travel:
        return Icons.travel_explore;
    }
  }

  Color get typeColor {
    switch (type) {
      case CompanionType.sport:
        return const Color(0xFF6366F1);
      case CompanionType.food:
        return const Color(0xFFF97316);
      case CompanionType.travel:
        return const Color(0xFF10B981);
    }
  }

  String get databasePath {
    switch (type) {
      case CompanionType.sport:
        return 'requirements';
      case CompanionType.food:
        return 'food';
      case CompanionType.travel:
        return 'travel';
    }
  }

  String get groupsPath {
    switch (type) {
      case CompanionType.sport:
        return 'groups';
      case CompanionType.food:
        return 'food_groups';
      case CompanionType.travel:
        return 'travel_groups';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId, // ➡️ Include groupId in toMap
      'name': name,
      'timestamp': timestamp,
      'location': location,
      'gender': gender,
      'ageLimit': ageLimit,
      'paymentType': paymentType,
      'date': date,
      'timer': timer,
      'endTime': endTime,
      'subcategory': subcategory,
      'modeOfTransport': modeOfTransport,
    };
  }
}
