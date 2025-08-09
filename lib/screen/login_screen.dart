import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/screen/home_screen.dart.dart';
import 'package:flutter_app/screen/register_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/sport_button.dart';
import '../widgets/sport_text_field.dart';
import '../providers/user_provider.dart';
import '../utils/helpers.dart';
import '../theme/app_theme.dart';
import 'animated_success1.dart';
import 'animated_failure.dart';
import '../model/user_model.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _login() async {
    if (kDebugMode) {
      print('Login button pressed');
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (!userCredential.user!.emailVerified) {
          setState(() => _isLoading = false);
          await showDialog(
            context: context,
            builder:
                (_) => const AnimatedFailure(
                  message: 'Please verify your email before logging in.',
                ),
          );
          return;
        }
        // Fetch full user profile from Realtime Database
        final userId = userCredential.user!.uid;
        final db = FirebaseDatabase.instance.ref();
        final snapshot = await db.child('users/$userId').get();
        if (snapshot.exists) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map);
          final userModel = UserModel.fromJson(userId, userData);
          if (mounted) {
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).setUser(userModel);
          }
        }
        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (_) =>
                  const AnimatedSuccess(message: 'Welcome to Fit Traveller!'),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              );
            },
          ),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          _error = e.message;
        });
        await showDialog(
          context: context,
          builder: (_) => AnimatedFailure(message: e.message ?? 'Login failed'),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _bypassLogin() {
    final user = UserModel(
      id: const Uuid().v4(),
      name: 'Bypass User',
      email: 'bypass@example.com',
      password: 'BypassPassword123!',
      age: 30,
      imageUrl: '',
    );
    Provider.of<UserProvider>(context, listen: false).setUser(user);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController _forgotEmailController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to receive a password reset link.'),
              const SizedBox(height: 16),
              TextField(
                controller: _forgotEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = _forgotEmailController.text.trim();
                if (email.isEmpty) return;
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Email Sent'),
                          content: const Text(
                            'A password reset link has been sent to your email.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                            'Failed to send reset email. Please check your email and try again.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 500 ? 400.0 : double.infinity;
    return Scaffold(
      body: Container(
        color: AppTheme.lightBackground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/login.jpg',

                      width: cardWidth,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing * 1.5),
                  FadeTransition(
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
                                'Welcome Back!',
                                style: AppTheme.headingLarge.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Log in to your account',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.lightTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spacing * 2),
                              SportTextField(
                                label: 'Email',
                                hint: 'Enter your email address',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator:
                                    (value) => Helpers.validateEmail(value),
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
                                validator:
                                    (value) => Helpers.validatePassword(value),
                                fillColor: Colors.purple.shade50,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed:
                                      () => _showForgotPasswordDialog(context),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
                              SportButton(
                                text: 'Log in',
                                onPressed: _isLoading ? null : _login,
                                isLoading: _isLoading,
                                width: double.infinity,
                                icon: Icons.login,
                                style: SportButtonStyle.primary,
                              ),
                              const SizedBox(height: AppTheme.spacing),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        _isLoading
                                            ? null
                                            : () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder:
                                                      (_, __, ___) =>
                                                          const RegisterScreen(),
                                                  transitionsBuilder: (
                                                    _,
                                                    animation,
                                                    __,
                                                    child,
                                                  ) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: const Offset(
                                                          1.0,
                                                          0.0,
                                                        ),
                                                        end: Offset.zero,
                                                      ).animate(
                                                        CurvedAnimation(
                                                          parent: animation,
                                                          curve:
                                                              Curves.easeInOut,
                                                        ),
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                    child: Text(
                                      'Sign Up',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.purple[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (kDebugMode)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: SportButton(
                                    text: 'Bypass Login (UI Test)',
                                    onPressed: _bypassLogin,
                                    width: double.infinity,
                                    icon: Icons.skip_next,
                                    style: SportButtonStyle.secondary,
                                    color: Colors.purple[800],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
