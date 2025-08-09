import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../widgets/circular_avatar.dart';
import '../providers/user_provider.dart';
import '../model/unified_model.dart';
import 'profile_screen.dart';
import 'companion_list_screen.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final dynamic initialUser;
  const HomeScreen({super.key, this.initialUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _videoPaths = [
    'assets/videos/sports.mp4',
    'assets/videos/food.mp4',
    'assets/videos/travel.mp4',
    'assets/videos/travel2.mp4',
  ];

  VideoPlayerController? _controller;
  int _currentIndex = 0;

  late AnimationController _gradientController;
  bool _didPrecacheAvatar = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo(_currentIndex);
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecacheAvatar) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final url = user?.imageUrl;
      if (url != null && url.isNotEmpty) {
        precacheImage(NetworkImage(url), context).catchError((_) {});
      }
      _didPrecacheAvatar = true;
    }
  }

  Future<void> _initializeVideo(int index) async {
    _controller?.dispose();
    final controller = VideoPlayerController.asset(_videoPaths[index]);
    _controller = controller;

    await controller.initialize();
    controller.setVolume(0);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && controller.value.isInitialized) {
        controller.play();
      }
    });

    controller.addListener(() {
      final vp = controller.value;
      if (vp.isInitialized && vp.position >= vp.duration && !vp.isPlaying) {
        _playNextVideo();
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  void _playNextVideo() {
    _currentIndex = (_currentIndex + 1) % _videoPaths.length;
    _initializeVideo(_currentIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  // Helper method to determine device type
  bool _isTablet(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 600;
  }

  // Responsive sizing methods
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 600) {
      return baseFontSize * 1.2; // Tablet
    } else if (screenWidth >= 400) {
      return baseFontSize; // Large phone
    } else {
      return baseFontSize * 0.9; // Small phone
    }
  }

  double _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 600) {
      return 32.0; // Tablet
    } else if (screenWidth >= 400) {
      return 20.0; // Large phone
    } else {
      return 16.0; // Small phone
    }
  }

  double _getAvatarSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 600) {
      return 70.0; // Tablet
    } else if (screenWidth >= 400) {
      return 60.0; // Large phone
    } else {
      return 50.0; // Small phone
    }
  }

  double _getCardHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 600) {
      return screenHeight * 0.2; // Tablet - larger cards
    } else if (screenHeight >= 800) {
      return 140.0; // Tall phone
    } else {
      return 120.0; // Short phone
    }
  }

  double _getVideoHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 600) {
      return screenHeight * 0.3; // Tablet
    } else if (screenHeight >= 800) {
      return screenHeight * 0.25; // Tall phone
    } else {
      return screenHeight * 0.2; // Short phone
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = _isTablet(context);
    final responsivePadding = _getResponsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            ),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.help_outline_outlined, color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: _gradientController,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    // Header with text + profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback:
                                    (bounds) => const LinearGradient(
                                      colors: [Colors.white, Colors.white70],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                child: const Text(
                                  "Choose Your\nCompanion Type",
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    height: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "One destination to find your perfect companion",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              ),
                          child: Container(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircularAvatar(
                              imageUrl: user?.imageUrl,
                              userId: user?.id,
                              radius: screenWidth * 0.07,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    // Sports Explorer Card
                    _buildCompanionCard(
                      context,
                      title: "Sports Explorer",
                      subtitle: "Find friends to play sports",
                      imagePath:
                          "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const CompanionListScreen(
                                    type: CompanionType.sport,
                                    imagePath: 'assets/images/sportsfilter.jpg',
                                    caption: 'Find People to tavel with.',
                                  ),
                            ),
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Food Companion Card
                    _buildCompanionCard(
                      context,
                      title: "Food Companion",
                      subtitle: "Discover foodie buddies",
                      imagePath:
                          "https://plus.unsplash.com/premium_photo-1680539024823-81159b3eb2ce?q=80&w=1077&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const CompanionListScreen(
                                    type: CompanionType.food,
                                    imagePath: 'assets/images/foodfilter.jpg',
                                    caption: 'Find People to tavel with.',
                                  ),
                            ),
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Travel Partner Card
                    _buildCompanionCard(
                      context,
                      title: "Travel Partner",
                      subtitle: "Meet travel partners",
                      imagePath:
                          "https://images.unsplash.com/photo-1527631746610-bca00a040d60?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const CompanionListScreen(
                                    type: CompanionType.travel,
                                    imagePath: 'assets/images/travelfilter.jpg',
                                    caption: 'Find People to tavel with.',
                                  ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 40),
                    _buildVideoSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        builder: (context, child) {
          return Container(decoration: const BoxDecoration(), child: child);
        },
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    final videoHeight = _getVideoHeight(context);
    final responsivePadding = _getResponsivePadding(context);

    return _controller != null && _controller!.value.isInitialized
        ? Container(
          height: videoHeight,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: responsivePadding / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
        )
        : SizedBox(
          height: videoHeight,
          child: const Center(child: CircularProgressIndicator()),
        );
  }

  Widget _buildCompanionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final cardHeight = _getCardHeight(context);
    final isTablet = _isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imagePath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error, color: Colors.white),
                    ),
              ),
              Container(color: Colors.black.withOpacity(0.35)),
              Padding(
                padding: EdgeInsets.all(_getResponsivePadding(context) * 0.75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 16),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
