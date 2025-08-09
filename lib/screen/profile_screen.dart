import 'package:flutter/material.dart';
import 'package:flutter_app/screen/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../model/user_model.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _parallaxController;
  late AnimationController _carouselController;
  late ScrollController _scrollController;
  late PageController _pageController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _parallaxAnimation;

  bool _isLoading = false;
  bool _isBioExpanded = false;
  bool _isEditing = false;
  int _currentImageIndex = 0;
  List<String> _userImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingAnimation();
    _initializeUserImages();
  }

  void _initializeUserImages() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user?.imageUrl != null && user!.imageUrl!.isNotEmpty) {
      _userImages = [user.imageUrl!];
    }
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scrollController = ScrollController();
    _pageController = PageController();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _parallaxController.repeat(reverse: true);
  }

  void _startLoadingAnimation() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _mainController.forward();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _parallaxController.dispose();
    _carouselController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      final imageUrl = 'data:image/jpeg;base64,$base64String';
      
      setState(() {
        _userImages.add(imageUrl);
        _currentImageIndex = _userImages.length - 1;
      });
      
      // Update user model with new image
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;
      if (currentUser != null) {
        final updatedUser = UserModel(
          id: currentUser.id,
          name: currentUser.name,
          email: currentUser.email,
          password: currentUser.password,
          age: currentUser.age,
          imageUrl: imageUrl,
          bio: currentUser.bio,
          location: currentUser.location,
          hobbies: currentUser.hobbies,
          lifestyle: currentUser.lifestyle,
          phoneNumber: currentUser.phoneNumber,
          dateOfBirth: currentUser.dateOfBirth,
          gender: currentUser.gender,
        );
        userProvider.setUser(updatedUser);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _userImages.removeAt(index);
      if (_currentImageIndex >= _userImages.length) {
        _currentImageIndex = _userImages.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _parallaxAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ModernBackgroundPainter(_parallaxAnimation.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: _isLoading
                ? _buildSkeletonScreen()
                : _buildMainContent(context, user, screenSize),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6),
            const Color(0xFF3B82F6),
            const Color(0xFF1E40AF),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSkeletonAvatar(),
            const SizedBox(height: 24),
            _buildSkeletonText(),
            const SizedBox(height: 16),
            _buildSkeletonText(width: 0.6),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
      ),
      child: const Icon(Icons.person, size: 60, color: Colors.white70),
    );
  }

  Widget _buildSkeletonText({double width = 0.8}) {
    return Container(
      width: MediaQuery.of(context).size.width * width,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, dynamic user, Size screenSize) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Section with Image Carousel
                _buildHeaderSection(user, screenSize),
                
                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Basic Info Section
                        _buildBasicInfoSection(user),
                        const SizedBox(height: 24),
                        
                        // Bio Section
                        _buildBioSection(user),
                        const SizedBox(height: 24),
                        
                        // Personal Details Section
                        _buildPersonalDetailsSection(user),
                        const SizedBox(height: 24),
                        
                        // Hobbies & Interests Section
                        _buildHobbiesSection(),
                        const SizedBox(height: 24),
                        
                        // Lifestyle Section
                        _buildLifestyleSection(),
                        const SizedBox(height: 24),
                        
                        // Action Buttons Section
                        _buildActionButtonsSection(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(dynamic user, Size screenSize) {
    return SliverAppBar(
      expandedHeight: screenSize.height * 0.4,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          child: Stack(
            children: [
              // Image Carousel with proper scroll handling
              Positioned.fill(
                child: _buildImageCarousel(),
              ),
              
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Floating Action Buttons
              Positioned(
                top: 60,
                right: 20,
                child: Row(
                  children: [
                    _buildFloatingActionButton(
                      icon: Icons.add_a_photo,
                      onPressed: _pickImage,
                    ),
                    const SizedBox(width: 8),
                    _buildFloatingActionButton(
                      icon: Icons.edit,
                      onPressed: _toggleEditMode,
                    ),
                  ],
                ),
              ),
              
              // Carousel Indicators
              if (_userImages.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: _buildCarouselIndicators(),
                ),
              
              // Navigation Buttons
              if (_userImages.length > 1)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: _buildNavigationButton(Icons.chevron_left, () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }),
                ),
              
              if (_userImages.length > 1)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: _buildNavigationButton(Icons.chevron_right, () {
                    if (_currentImageIndex < _userImages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (_userImages.isEmpty) {
      return _buildDefaultAvatar();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemCount: _userImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF8B5CF6),
                        const Color(0xFF3B82F6),
                        const Color(0xFF1E40AF),
                      ],
                    ),
                  ),
                  child: _buildUserImage(_userImages[index]),
                ),
                if (_isEditing)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_userImages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentImageIndex == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentImageIndex == index 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 50,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildUserImage(String imageUrl) {
    ImageProvider? provider;
    if (imageUrl.startsWith('data:image')) {
      final base64String = imageUrl.split(',').last;
      provider = MemoryImage(base64Decode(base64String));
    } else if (imageUrl.startsWith('http')) {
      provider = NetworkImage(imageUrl);
    } else {
      provider = AssetImage(imageUrl);
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: onPressed,
            ),
          ),
        );
      },
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Widget _buildBasicInfoSection(dynamic user) {
    return _buildGlassCard(
      child: Column(
        children: [
          Text(
            user?.name ?? 'Anonymous User',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'No email provided',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              user?.displayAge ?? 'Age not set',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (user?.location != null && user.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    user.location!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBioSection(dynamic user) {
    final bioText = user?.displayBio ?? 'No bio available';
    final isLongBio = bioText.length > 100;
    
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'About Me',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isBioExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              isLongBio ? '${bioText.substring(0, 100)}...' : bioText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            secondChild: Text(
              bioText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
          if (isLongBio) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _isBioExpanded = !_isBioExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  _isBioExpanded ? 'Show Less' : 'Read More',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection(dynamic user) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.person, 'Name', user?.name ?? 'N/A'),
          _buildDetailItem(Icons.email, 'Email', user?.email ?? 'N/A'),
          _buildDetailItem(Icons.cake, 'Age', user?.displayAge ?? 'N/A'),
          if (user?.phoneNumber != null && user.phoneNumber!.isNotEmpty)
            _buildDetailItem(Icons.phone, 'Phone', user.phoneNumber!),
          if (user?.gender != null && user.gender!.isNotEmpty)
            _buildDetailItem(Icons.person_outline, 'Gender', user.gender!),
          if (user?.location != null && user.location!.isNotEmpty)
            _buildDetailItem(Icons.location_on, 'Location', user.location!),
          _buildDetailItem(Icons.verified, 'Status', 'Verified', isVerified: true),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildHobbiesSection() {
    final user = Provider.of<UserProvider>(context).user;
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hobbies & Interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (user?.displayHobbies ?? ['Fitness', 'Travel', 'Photography', 'Cooking', 'Reading', 'Music'])
                .map((hobby) => _buildHobbyChip(hobby))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHobbyChip(String hobby) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              hobby,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLifestyleSection() {
    final user = Provider.of<UserProvider>(context).user;
    final lifestyleItems = user?.displayLifestyle ?? ['Active', 'Traveler', 'Foodie'];
    
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifestyle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: lifestyleItems.map((item) => _buildLifestyleItem(_getLifestyleIcon(item), item)).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getLifestyleIcon(String lifestyle) {
    switch (lifestyle.toLowerCase()) {
      case 'active':
      case 'fitness':
        return Icons.fitness_center;
      case 'traveler':
      case 'travel':
        return Icons.flight;
      case 'foodie':
      case 'food':
        return Icons.restaurant;
      case 'gamer':
        return Icons.games;
      case 'reader':
      case 'reading':
        return Icons.book;
      case 'musician':
      case 'music':
        return Icons.music_note;
      case 'photographer':
      case 'photography':
        return Icons.camera_alt;
      case 'cook':
      case 'cooking':
        return Icons.restaurant_menu;
      default:
        return Icons.person;
    }
  }

  Widget _buildLifestyleItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsSection(BuildContext context) {
    return Column(
      children: [
        _buildGradientButton(
          icon: Icons.edit,
          label: 'Edit Profile',
          onPressed: () {
            // TODO: Navigate to edit profile screen
            _showEditProfileDialog(context);
          },
        ),
        const SizedBox(height: 12),
        _buildGradientButton(
          icon: Icons.settings,
          label: 'Settings',
          onPressed: () {
            // TODO: Implement settings functionality
          },
        ),
        const SizedBox(height: 12),
        _buildGradientButton(
          icon: Icons.logout,
          label: 'Logout',
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            }
          },
          isDestructive: true,
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Personal Info'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit personal info screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Manage Photos'),
              onTap: () {
                Navigator.pop(context);
                _toggleEditMode();
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Privacy Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to privacy settings
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDestructive
              ? [Colors.red.shade400, Colors.red.shade600]
              : [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDestructive
              ? Colors.red.shade300
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ModernBackgroundPainter extends CustomPainter {
  final double animationValue;

  ModernBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B5CF6),
          const Color(0xFF3B82F6),
          const Color(0xFF1E40AF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Animated circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final centerX = size.width * 0.5;
    final centerY = size.height * 0.3;

    canvas.drawCircle(
      Offset(centerX + math.sin(animationValue * 2 * math.pi) * 50, centerY),
      30 + math.sin(animationValue * 4 * math.pi) * 10,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(centerX - math.sin(animationValue * 2 * math.pi) * 50, centerY + 100),
      20 + math.cos(animationValue * 4 * math.pi) * 8,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
