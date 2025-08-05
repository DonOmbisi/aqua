import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../utils/auth_service.dart';
import '../../services/network_service.dart';
import './widgets/app_logo_widget.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/registration_link_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  final AuthService _authService = AuthService();
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate biometric availability check
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isBiometricAvailable = true;
    });
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check network connectivity first (simplified check)
      bool hasConnection = true;
      try {
        await _networkService.initialize();
        hasConnection = await _networkService.checkConnection();
      } catch (e) {
        // If network service fails, assume we have connection and let Supabase handle errors
        debugPrint('Network service error: $e');
        hasConnection = true;
      }
      
      if (!hasConnection) {
        _showErrorMessage(
            "No internet connection. Please check your network and try again.");
        return;
      }

      // Attempt to sign in with Supabase
      final response = await _authService.signInWithEmail(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // Get user profile to determine role and route
        final profile = await _authService.getCurrentUserProfile();
        
        // Debug logging
        debugPrint('User ID: ${response.user!.id}');
        debugPrint('User Email: ${response.user!.email}');
        debugPrint('Profile Data: $profile');
        debugPrint('User Role: ${profile?['role']}');
        
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        // Show success toast
        final userName = profile?['full_name'] ?? profile?['username'] ?? 'User';
        final userRole = profile?['role'] ?? 'community_user';
        
        Fluttertoast.showToast(
          msg: "Welcome back, $userName! (Role: $userRole)",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          textColor: AppTheme.lightTheme.colorScheme.onTertiary,
        );

        // Navigate based on role
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          String route = '/dashboard-screen'; // Default route
          
          debugPrint('Determining route for role: $userRole');
          
          switch (userRole.toString().toLowerCase()) {
            case 'admin':
            case 'manager':
              route = '/analytics-dashboard-screen';
              debugPrint('Routing to analytics dashboard for admin/manager');
              break;
            case 'expert':
              route = '/water-quality-data-entry-screen';
              debugPrint('Routing to data entry for expert');
              break;
            case 'community_user':
            default:
              route = '/map-view-screen';
              debugPrint('Routing to map view for community user or default');
              break;
          }
          
          debugPrint('Final route: $route');
          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        _showErrorMessage(
            "Login failed. Please check your credentials and try again.");
      }
    } on AuthException catch (e) {
      // Handle authentication specific errors
      String errorMessage;
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = "Invalid email or password. Please check your credentials and try again.";
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = "Please check your email and click the confirmation link before signing in.";
      } else {
        errorMessage = "Authentication failed: ${e.message}";
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      // Handle network or other errors
      debugPrint('Login error: $e');
      _showErrorMessage(
          "Unable to connect. Please check your internet connection and try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate biometric authentication
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Simulate successful biometric auth for demo
      HapticFeedback.lightImpact();

      Fluttertoast.showToast(
        msg: "Biometric authentication successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        textColor: AppTheme.lightTheme.colorScheme.onTertiary,
      );

      // Navigate to dashboard (default for biometric)
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
      }
    } catch (e) {
      _showErrorMessage(
          "Biometric authentication failed. Please try again or use your password.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    HapticFeedback.heavyImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: AppTheme.lightTheme.colorScheme.onError,
                size: 4.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  message,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 8.h),

                    // App Logo and Branding
                    const AppLogoWidget(),

                    SizedBox(height: 6.h),

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    // Biometric Authentication
                    BiometricAuthWidget(
                      onBiometricAuth: _handleBiometricAuth,
                      isAvailable: _isBiometricAvailable,
                    ),

                    // Registration Link
                    const RegistrationLinkWidget(),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
