import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/sport_text_field.dart';
import '../widgets/sport_button.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../model/user_model.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  List<String> _selectedHobbies = [];
  List<String> _selectedLifestyle = [];

  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  File? _selfieLeft;
  File? _selfieRight;
  File? _selfieCenter;
  String? _selfieBase64;
  bool _isDetectingFace = false;
  String? _selfieError;
  int _selfieStep = 0; // 0: left, 1: right, 2: center
  final List<double?> _yawAngles = [null, null, null];
  final List<String> _selfieInstructions = [
    'Turn your head RIGHT and take a selfie',
    'Turn your head LEFT and take a selfie',
    'Face CENTER and take a selfie',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickSelfieLiveness() async {
    setState(() {
      _selfieError = null;
    });
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _isDetectingFace = true;
    });
    final imageFile = File(picked.path);
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
      ),
    );
    final faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();
    if (faces.isNotEmpty) {
      final face = faces.first;
      final double? yaw = face.headEulerAngleY;
      _yawAngles[_selfieStep] = yaw;
      if (_selfieStep == 0) {
        // Left
        _selfieLeft = imageFile;
      } else if (_selfieStep == 1) {
        // Right
        _selfieRight = imageFile;
      } else if (_selfieStep == 2) {
        // Center
        _selfieCenter = imageFile;
        final bytes = await imageFile.readAsBytes();
        _selfieBase64 = base64Encode(bytes);
      }
      setState(() {
        _isDetectingFace = false;
        _selfieError = null;
        if (_selfieStep < 2) {
          _selfieStep++;
        }
      });
    } else {
      setState(() {
        _selfieError = 'No face detected. Please try again.';
        _isDetectingFace = false;
      });
    }
  }

  bool get _isLivenessValid {
    // Yaw: left < -15, right > 15, center between -10 and 10
    final left = _yawAngles[0];
    final right = _yawAngles[1];
    final center = _yawAngles[2];
    return left != null &&
        right != null &&
        center != null &&
        left < -5 &&
        right > 5 &&
        center > -10 &&
        center < 10 &&
        _selfieBase64 != null;
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }
    if (!_isLivenessValid) {
      print("Liveness validation failed: $_yawAngles");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
          final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim());
      final bio = _bioController.text.trim();
      final location = _locationController.text.trim();
      final phone = _phoneController.text.trim();
      
      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await userCredential.user?.sendEmailVerification();

        // Save user profile to Firebase Realtime Database
        final userId = userCredential.user?.uid ?? const Uuid().v4();
        final userModel = UserModel(
          id: userId,
          name: name,
          email: email,
          password: password,
          age: age,
          imageUrl:
              _selfieBase64 != null
                  ? 'data:image/jpeg;base64,$_selfieBase64'
                  : '',
          bio: bio.isNotEmpty ? bio : null,
          location: location.isNotEmpty ? location : null,
          phoneNumber: phone.isNotEmpty ? phone : null,
          gender: _selectedGender,
          hobbies: _selectedHobbies.isNotEmpty ? _selectedHobbies : null,
          lifestyle: _selectedLifestyle.isNotEmpty ? _selectedLifestyle : null,
        );
      final db = FirebaseDatabase.instance.ref();
      await db.child('users/$userId').set(userModel.toJson());

      // Set user in provider
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).setUser(userModel);
      }

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OtpVerificationScreen(
                email: email,
                otp: '', // Not used, as Firebase handles email verification
              ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    if (!emailRegex.hasMatch(value)) return 'Invalid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    final alnum = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{8,}');
    if (!alnum.hasMatch(value)) return 'Must be alphanumeric';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Enter a valid name';
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final age = int.tryParse(value.trim());
    if (age == null || age < 10 || age > 120) return 'Enter a valid age';
    return null;
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender (optional)',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = 'Male'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Male' 
                        ? AppTheme.primaryColor 
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedGender == 'Male' 
                          ? AppTheme.primaryColor 
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    'Male',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedGender == 'Male' 
                          ? Colors.white 
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = 'Female'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Female' 
                        ? AppTheme.primaryColor 
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedGender == 'Female' 
                          ? AppTheme.primaryColor 
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    'Female',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedGender == 'Female' 
                          ? Colors.white 
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = 'Other'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Other' 
                        ? AppTheme.primaryColor 
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedGender == 'Other' 
                          ? AppTheme.primaryColor 
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    'Other',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedGender == 'Other' 
                          ? Colors.white 
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHobbiesSelector() {
    final availableHobbies = [
      'Fitness', 'Travel', 'Photography', 'Cooking', 'Reading', 
      'Music', 'Gaming', 'Sports', 'Art', 'Technology'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hobbies & Interests (optional)',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableHobbies.map((hobby) {
            final isSelected = _selectedHobbies.contains(hobby);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedHobbies.remove(hobby);
                  } else {
                    _selectedHobbies.add(hobby);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  hobby,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLifestyleSelector() {
    final availableLifestyle = [
      'Active', 'Traveler', 'Foodie', 'Gamer', 'Reader', 
      'Musician', 'Photographer', 'Cook', 'Tech Enthusiast'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifestyle (optional)',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableLifestyle.map((lifestyle) {
            final isSelected = _selectedLifestyle.contains(lifestyle);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedLifestyle.remove(lifestyle);
                  } else {
                    _selectedLifestyle.add(lifestyle);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  lifestyle,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 500 ? 400.0 : double.infinity;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing * 2),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(AppTheme.spacing * 2),
                    decoration: AppTheme.glassmorphismDecoration(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create Account',
                            style: AppTheme.headingLarge.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join the sports community!',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.lightTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacing * 2),
                          SportTextField(
                            label: 'Name',
                            hint: 'Enter your full name',
                            controller: _nameController,
                            prefixIcon: Icons.person_outline,
                            validator: _validateName,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          SportTextField(
                            label: 'Age',
                            hint: 'Enter your age',
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.cake_outlined,
                            validator: _validateAge,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          SportTextField(
                            label: 'Bio',
                            hint: 'Tell us about yourself (optional)',
                            controller: _bioController,
                            maxLines: 3,
                            prefixIcon: Icons.info_outline,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          SportTextField(
                            label: 'Location',
                            hint: 'Enter your city/country (optional)',
                            controller: _locationController,
                            prefixIcon: Icons.location_on_outlined,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          SportTextField(
                            label: 'Phone Number',
                            hint: 'Enter your phone number (optional)',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          _buildGenderSelector(),
                          const SizedBox(height: AppTheme.spacing),
                          _buildHobbiesSelector(),
                          const SizedBox(height: AppTheme.spacing),
                          _buildLifestyleSelector(),
                          const SizedBox(height: AppTheme.spacing),
                          SportTextField(
                            label: 'Email',
                            hint: 'Enter your email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: _validateEmail,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          SportTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon:
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            validator: _validatePassword,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          SportTextField(
                            label: 'Confirm Password',
                            hint: 'Re-enter your password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon:
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                            validator: _validateConfirmPassword,
                            fillColor: Colors.purple.shade50,
                          ),
                          const SizedBox(height: AppTheme.spacing * 1.5),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppTheme.accentColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Text(
                            'Selfie Liveness Verification',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _selfieStep == i
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap:
                                _isDetectingFace ? null : _pickSelfieLiveness,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.purple.shade50,
                                border: Border.all(
                                  color:
                                      _isLivenessValid
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade300,
                                  width: 3,
                                ),
                              ),
                              child:
                                  _isDetectingFace
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : (() {
                                        if (_selfieStep == 0 &&
                                            _selfieLeft != null) {
                                          return ClipOval(
                                            child: Image.file(
                                              _selfieLeft!,
                                              fit: BoxFit.contain,
                                              width: 110,
                                              height: 110,
                                            ),
                                          );
                                        } else if (_selfieStep == 1 &&
                                            _selfieRight != null) {
                                          return ClipOval(
                                            child: Image.file(
                                              _selfieRight!,
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        } else if (_selfieStep == 2 &&
                                            _selfieCenter != null) {
                                          return ClipRRect(
                                            child: Image.file(
                                              _selfieCenter!,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          );
                                        } else {
                                          return const Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          );
                                        }
                                      })(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selfieInstructions[_selfieStep],
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selfieError != null)
                            Text(
                              _selfieError!,
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                              ),
                            ),
                          if (!_isLivenessValid)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Please complete all three selfies (left, right, center) for verification',
                                style: TextStyle(color: AppTheme.accentColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: AppTheme.spacing),
                          SportButton(
                            text: 'Register',
                            onPressed: _isLoading ? null : _register,
                            isLoading: _isLoading,
                            icon: Icons.person_add_alt_1,
                            style: SportButtonStyle.primary,
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      Navigator.pop(context);
                                    },
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
