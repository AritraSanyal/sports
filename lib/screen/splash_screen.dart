import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screen/home_screen.dart.dart';
import 'package:video_player/video_player.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/intro.mp4');
    
    try {
      await _videoController.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
      
      // Start playing the video
      await _videoController.play();
      
      // Listen for video completion
      _videoController.addListener(() {
        if (_videoController.value.position >= _videoController.value.duration) {
          _navigateToNextScreen();
        }
      });
      
      // Fallback: Navigate after video duration + buffer
      Future.delayed(Duration(milliseconds: (_videoController.value.duration.inMilliseconds + 500)), () {
        if (mounted) {
          _navigateToNextScreen();
        }
      });
      
    } catch (e) {
      print('Error initializing video: $e');
      // Fallback to original splash screen behavior
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _navigateToNextScreen();
        }
      });
    }
  }

  void _navigateToNextScreen() {
    final user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      if (user != null && user.emailVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Center(
          child: _isVideoInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fallback logo while video loads
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Fit Traveller',
                      style: AppTheme.headingLarge.copyWith(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          const Shadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Run, Roam & Relish',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.black54,
                        fontSize: 16,
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
