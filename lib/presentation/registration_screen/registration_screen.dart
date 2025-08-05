import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../utils/supabase_service.dart';
import '../../utils/auth_service.dart';
import '../../services/network_service.dart';
import './widgets/location_permission_widget.dart';
import './widgets/password_strength_indicator_widget.dart';
import './widgets/profile_photo_upload_widget.dart';
import './widgets/role_selection_widget.dart';
import './widgets/terms_privacy_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Form state
  String _selectedRole = '';
  bool _isLocationEnabled = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  XFile? _selectedImage;

  // Validation state
  bool _isEmailValid = true;
  String _emailValidationMessage = '';

  final ImagePicker _imagePicker = ImagePicker();

  // Mock user data for validation
  final List<Map<String, dynamic>> _existingUsers = [
    {
      "email": "john.doe@watermonitoring.org",
      "fullName": "John Doe",
      "role": "water_professional",
    },
    {
      "email": "sarah.expert@environmental.gov",
      "fullName": "Dr. Sarah Johnson",
      "role": "environmental_expert",
    },
    {
      "email": "community@localwater.com",
      "fullName": "Mike Community",
      "role": "community_member",
    },
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),
                      _buildWelcomeSection(),
                      SizedBox(height: 4.h),
                      _buildFormFields(),
                      SizedBox(height: 3.h),
                      RoleSelectionWidget(
                        selectedRole: _selectedRole,
                        onRoleChanged: (role) {
                          setState(() {
                            _selectedRole = role;
                          });
                        },
                      ),
                      SizedBox(height: 3.h),
                      LocationPermissionWidget(
                        isLocationEnabled: _isLocationEnabled,
                        onLocationToggle: () {
                          setState(() {
                            _isLocationEnabled = !_isLocationEnabled;
                          });
                        },
                      ),
                      SizedBox(height: 3.h),
                      ProfilePhotoUploadWidget(
                        selectedImage: _selectedImage,
                        onImageSelect: _showImagePickerBottomSheet,
                      ),
                      SizedBox(height: 3.h),
                      TermsPrivacyWidget(
                        termsAccepted: _termsAccepted,
                        privacyAccepted: _privacyAccepted,
                        onTermsChanged: (value) {
                          setState(() {
                            _termsAccepted = value;
                          });
                        },
                        onPrivacyChanged: (value) {
                          setState(() {
                            _privacyAccepted = value;
                          });
                        },
                      ),
                      SizedBox(height: 4.h),
                      _buildCreateAccountButton(),
                      SizedBox(height: 2.h),
                      _buildLoginLink(),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 25.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: CustomImageWidget(
              imageUrl:
                  "https://images.unsplash.com/photo-1544551763-46a013bb70d5?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
              width: double.infinity,
              height: 25.h,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.7),
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            top: 2.h,
            left: 4.w,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/login-screen'),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 3.h,
            left: 6.w,
            right: 6.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Water Monitoring',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Community',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Help protect our water resources together',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Your Account',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Join thousands of community members, water professionals, and environmental experts working together to monitor and protect our water resources.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          prefixIcon: 'person',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            if (value.trim().length < 2) {
              return 'Full name must be at least 2 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        _buildEmailField(),
        SizedBox(height: 2.h),
        _buildPasswordField(),
        PasswordStrengthIndicatorWidget(password: _passwordController.text),
        SizedBox(height: 2.h),
        _buildConfirmPasswordField(),
        SizedBox(height: 2.h),
        _buildPhoneField(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: prefixIcon,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      onChanged: (value) {
        if (label == 'Password') {
          setState(() {});
        }
      },
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your email address',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: _emailController.text.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: _isEmailValid ? 'check_circle' : 'error',
                      color: _isEmailValid
                          ? AppTheme.successLight
                          : AppTheme.errorLight,
                      size: 20,
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email address is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          onChanged: _validateEmail,
        ),
        if (!_isEmailValid && _emailValidationMessage.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Text(
            _emailValidationMessage,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.errorLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: 'Password',
      hint: 'Create a strong password',
      prefixIcon: 'lock',
      obscureText: _obscurePassword,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: _obscurePassword ? 'visibility' : 'visibility_off',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: _confirmPasswordController,
      label: 'Confirm Password',
      hint: 'Re-enter your password',
      prefixIcon: 'lock',
      obscureText: _obscureConfirmPassword,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: _obscureConfirmPassword ? 'visibility' : 'visibility_off',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'Phone Number',
      hint: 'Enter phone number for emergency alerts',
      prefixIcon: 'phone',
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number is required for emergency alerts';
        }
        if (value.length < 10) {
          return 'Please enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }

  Widget _buildCreateAccountButton() {
    final bool canCreateAccount = _selectedRole.isNotEmpty &&
        _termsAccepted &&
        _privacyAccepted &&
        _isEmailValid;

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: (canCreateAccount && !_isLoading) ? _createAccount : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canCreateAccount
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          foregroundColor: canCreateAccount
              ? Colors.white
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        child: _isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Create Account',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: canCreateAccount
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login-screen'),
                child: Text(
                  'Sign In',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _isEmailValid = true;
        _emailValidationMessage = '';
        return;
      }

      // Check if email already exists
      final existingUser = _existingUsers.any((user) =>
          (user['email'] as String).toLowerCase() == email.toLowerCase());

      if (existingUser) {
        _isEmailValid = false;
        _emailValidationMessage =
            'This email is already registered. Please use a different email or sign in.';
      } else if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _isEmailValid = true;
        _emailValidationMessage = '';
      } else {
        _isEmailValid = false;
        _emailValidationMessage = 'Please enter a valid email address';
      }
    });
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Photo',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: 'camera_alt',
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildImagePickerOption(
                    icon: 'photo_library',
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 8.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.primaryColor,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image. Please try again.'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check network connectivity first
      final networkService = NetworkService();
      final hasConnection = await networkService.checkConnection();
      
      if (!hasConnection) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No internet connection. Please check your network settings and try again.'),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _createAccount();
              },
            ),
          ),
        );
        return;
      }

      // Use AuthService for consistent authentication handling
      final authResponse = await AuthService().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        username: _fullNameController.text.trim().replaceAll(' ', '').toLowerCase(),
        role: _selectedRole,
      );

      if (authResponse.user != null) {
        // The trigger function will automatically create the user profile
        // But let's ensure it's created with all the details
        final client = await SupabaseService().client;
        
        // Wait a moment for the trigger to execute
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Verify and update profile if needed
        try {
          final existingProfile = await client
              .from('user_profiles')
              .select()
              .eq('id', authResponse.user!.id)
              .maybeSingle();
              
          if (existingProfile == null) {
            // Create profile manually if trigger failed
            final userProfile = {
              'id': authResponse.user!.id,
              'username': _fullNameController.text.trim().replaceAll(' ', '').toLowerCase(),
              'email': _emailController.text.trim(),
              'full_name': _fullNameController.text.trim(),
              'role': _selectedRole,
            };
            
            await client.from('user_profiles').insert(userProfile);
          } else {
            // Update profile with complete information
            await client
                .from('user_profiles')
                .update({
                  'username': _fullNameController.text.trim().replaceAll(' ', '').toLowerCase(),
                  'full_name': _fullNameController.text.trim(),
                  'role': _selectedRole,
                })
                .eq('id', authResponse.user!.id);
          }
        } catch (profileE) {
          debugPrint('Profile creation/update error: $profileE');
          // Don't fail the registration for profile errors
        }

        // Show success message with role-specific welcome
        _showSuccessDialog();
      } else {
        throw Exception('Failed to create user account');
      }
    } on AuthException catch (e) {
      String errorMessage;
      if (e.message.contains('User already registered')) {
        errorMessage = 'An account with this email already exists. Please sign in instead.';
      } else if (e.message.contains('Password should be at least')) {
        errorMessage = 'Password must be at least 6 characters long.';
      } else if (e.message.contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else {
        errorMessage = 'Registration failed: ${e.message}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorLight,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account. Please check your internet connection and try again.'),
          backgroundColor: AppTheme.errorLight,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    String roleTitle = '';
    String welcomeMessage = '';
    String nextSteps = '';

    switch (_selectedRole) {
      case 'community_user':
        roleTitle = 'Community Member';
        welcomeMessage =
            'Welcome to the Aqua Horizon community! You can now report water quality issues and access community data.';
        nextSteps =
            'Start by exploring the map view to see water quality data in your area, or report any water issues you encounter.';
        break;
      case 'manager':
        roleTitle = 'Water Professional';
        welcomeMessage =
            'Welcome, Water Professional! Your expertise is valuable to our community monitoring efforts.';
        nextSteps =
            'You can now verify community reports, manage water system data, and provide professional insights to help protect our water resources.';
        break;
      case 'expert':
        roleTitle = 'Environmental Expert';
        welcomeMessage =
            'Welcome, Environmental Expert! Your scientific expertise will help improve our water monitoring accuracy.';
        nextSteps =
            'Access the analytics dashboard to analyze trends, verify data quality, and provide expert guidance to the community.';
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successLight,
                  size: 48,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Account Created Successfully!',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'Role: $roleTitle',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                welcomeMessage,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nextSteps,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/dashboard-screen');
                },
                child: Text('Get Started'),
              ),
            ),
          ],
        );
      },
    );
  }
}
