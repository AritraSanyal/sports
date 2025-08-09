class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final int? age;
  final String? imageUrl;
  final String? bio;
  final String? location;
  final List<String>? hobbies;
  final List<String>? lifestyle;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.age,
    this.imageUrl,
    this.bio,
    this.location,
    this.hobbies,
    this.lifestyle,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'age': age,
    'image_url': imageUrl,
    'bio': bio,
    'location': location,
    'hobbies': hobbies,
    'lifestyle': lifestyle,
    'phone_number': phoneNumber,
    'date_of_birth': dateOfBirth?.toIso8601String(),
    'gender': gender,
  };

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    // Debug: Print the JSON data to see what's being loaded
    print('UserModel.fromJson: Loading user data: $json');

    final user = UserModel(
      id: id,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      age: json['age'] as int?,
      imageUrl: json['image_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      hobbies:
          json['hobbies'] != null
              ? List<String>.from(json['hobbies'] as List)
              : null,
      lifestyle:
          json['lifestyle'] != null
              ? List<String>.from(json['lifestyle'] as List)
              : null,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'] as String)
              : null,
      gender: json['gender'] as String?,
    );

    print('UserModel.fromJson: Created user with bio: ${user.bio}');
    print('UserModel.fromJson: Created user with hobbies: ${user.hobbies}');
    print('UserModel.fromJson: Created user with lifestyle: ${user.lifestyle}');
    print('UserModel.fromJson: Created user with imageUrl: ${user.imageUrl}');

    return user;
  }

  // Helper method to get default bio if none is provided
  String get displayBio {
    if (bio != null && bio!.isNotEmpty) {
      return bio!;
    }
    return 'Passionate fitness enthusiast and travel lover. Always looking for new adventures and challenges to push my limits. I believe in living life to the fullest and inspiring others to do the same.';
  }

  // Helper method to get default hobbies if none are provided
  List<String> get displayHobbies {
    if (hobbies != null && hobbies!.isNotEmpty) {
      return hobbies!;
    }
    return ['Fitness', 'Travel', 'Photography', 'Cooking', 'Reading', 'Music'];
  }

  // Helper method to get default lifestyle if none is provided
  List<String> get displayLifestyle {
    if (lifestyle != null && lifestyle!.isNotEmpty) {
      return lifestyle!;
    }
    return ['Active', 'Traveler', 'Foodie'];
  }

  // Helper method to get display location
  String get displayLocation {
    if (location != null && location!.isNotEmpty) {
      return location!;
    }
    return 'Location not set';
  }

  // Helper method to get display age
  String get displayAge {
    if (age != null) {
      return '$age years old';
    }
    return 'Age not set';
  }

  // Helper method to get profile image
  String? get profileImage {
    return imageUrl;
  }
}
