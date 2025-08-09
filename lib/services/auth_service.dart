// lib/services/auth_service.dart

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '../model/user_model.dart';

class AuthService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<UserModel?> login(String email, String password) async {
    try {
      print('AuthService: Attempting login with Firebase Database');

      // Get all users from Firebase Database
      final snapshot = await _db.child('users').get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> users =
            snapshot.value as Map<dynamic, dynamic>;
        print('AuthService: Found ${users.length} users in Firebase Database');

        for (var entry in users.entries) {
          final userData = Map<String, dynamic>.from(entry.value as Map);
          print('AuthService: Checking user: ${entry.key}');
          print('AuthService: User data: $userData');

          if (userData['email'] == email && userData['password'] == password) {
            print('AuthService: Found matching user: ${entry.key}');
            final user = UserModel.fromJson(entry.key, userData);
            print('AuthService: Loaded user with bio: ${user.bio}');
            print('AuthService: Loaded user with hobbies: ${user.hobbies}');
            print('AuthService: Loaded user with lifestyle: ${user.lifestyle}');
            print('AuthService: Loaded user with imageUrl: ${user.imageUrl}');
            return user;
          }
        }
        throw Exception('Invalid email or password');
      } else {
        throw Exception('No users found in database');
      }
    } catch (e) {
      print('AuthService: Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final userData = {'name': name, 'email': email, 'password': password};

      await _db.child('users/$userId').set(userData);

      return UserModel(
        id: userId,
        name: name,
        email: email,
        password: password,
      );
    } catch (e) {
      print('AuthService: Sign up failed: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final snapshot = await _db.child('users/$userId').get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromJson(userId, userData);
      }
      return null;
    } catch (e) {
      print('AuthService: Failed to fetch user: $e');
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      final userData = user.toJson();
      print('AuthService: Saving user data to Firebase Database: $userData');
      print('AuthService: User ID: ${user.id}');

      await _db.child('users/${user.id}').update(userData);

      print('AuthService: User data saved successfully to Firebase Database!');
      return true;
    } catch (e) {
      print('AuthService: Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }
}
