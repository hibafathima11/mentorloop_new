import 'package:flutter/material.dart';
import 'package:mentorloop/screens/Common/login_screen.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/utils/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mentorloop/utils/cloudinary_service.dart';
import 'dart:io';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  String _selectedRole = 'student';
  bool _isLoading = false;
  // Parent-specific fields
  final _studentEmailController = TextEditingController();
  PlatformFile? _parentIdFile;
  String? _parentIdUploadUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate() || !_agreeToTerms) return;

    setState(() => _isLoading = true);

    try {
      // If parent, ensure student email and ID are provided
      if (_selectedRole == 'parent') {
        if (_studentEmailController.text.trim().isEmpty) {
          throw Exception('Please enter your student\'s email');
        }
        if (_parentIdFile == null) {
          throw Exception('Please upload the student ID');
        }
      }

      // Create account
      final cred = await AuthService.registerWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: _selectedRole,
      );

      // If parent, upload ID (if not already) and create verification request
      if (_selectedRole == 'parent') {
        String idUrl = _parentIdUploadUrl ?? '';
        if (idUrl.isEmpty &&
            _parentIdFile != null &&
            _parentIdFile!.path != null) {
          idUrl = await CloudinaryService.uploadFile(
            file: File(_parentIdFile!.path!),
            resourceType: 'auto',
          );
          _parentIdUploadUrl = idUrl;
        }
        await AuthService.createParentVerificationRequest(
          parentId: cred.user!.uid,
          parentEmail: _emailController.text.trim(),
          studentEmail: _studentEmailController.text.trim(),
          idUrl: idUrl,
        );
      }

      // Sign out to require explicit login afterwards
      await AuthService.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground, // Light coffee background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 40,
                    tablet: 50,
                    desktop: 60,
                  ),
                ),
                // Header
                Text(
                  "Sign Up",
                  style: TextStyle(
                    color: const Color(0xFF8B5E3C), // Coffee brown
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 32,
                      tablet: 36,
                      desktop: 40,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 10,
                    tablet: 15,
                    desktop: 20,
                  ),
                ),
                Text(
                  "Enter your details below & free sign up",
                  style: TextStyle(
                    color: const Color.fromARGB(
                      255,
                      188,
                      118,
                      93,
                    ), // Darker coffee
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 40,
                    tablet: 50,
                    desktop: 60,
                  ),
                ),
                // Full Name field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      hintText: "Kristin Cooper",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          ResponsiveHelper.getResponsivePaddingSymmetric(
                            context,
                            horizontal: 20,
                            vertical: 16,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "kristin.cooper@email.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          ResponsiveHelper.getResponsivePaddingSymmetric(
                            context,
                            horizontal: 20,
                            vertical: 16,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Phone Number field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "+1 234 567 8900",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          ResponsiveHelper.getResponsivePaddingSymmetric(
                            context,
                            horizontal: 20,
                            vertical: 16,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Role Selection
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                      context,
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Role",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveMargin(
                            context,
                            mobile: 10,
                            tablet: 15,
                            desktop: 20,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  "Student",
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 14,
                                          tablet: 16,
                                          desktop: 18,
                                        ),
                                  ),
                                ),
                                value: "student",
                                groupValue: _selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                                activeColor: const Color(0xFF8B5E3C),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  "Parent",
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 14,
                                          tablet: 16,
                                          desktop: 18,
                                        ),
                                  ),
                                ),
                                value: "parent",
                                groupValue: _selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                                activeColor: const Color(0xFF8B5E3C),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedRole == 'parent') ...[
                          SizedBox(
                            height: ResponsiveHelper.getResponsiveMargin(
                              context,
                              mobile: 10,
                              tablet: 12,
                              desktop: 14,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveCardRadius(
                                  context,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _studentEmailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (_selectedRole != 'parent') return null;
                                if (value == null || value.isEmpty) {
                                  return 'Student email is required for parents';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Student Email",
                                hintText: "student@email.com",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveCardRadius(
                                      context,
                                    ),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    ResponsiveHelper.getResponsivePaddingSymmetric(
                                      context,
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getResponsiveMargin(
                              context,
                              mobile: 10,
                              tablet: 12,
                              desktop: 14,
                            ),
                          ),
                          Container(
                            padding:
                                ResponsiveHelper.getResponsivePaddingSymmetric(
                                  context,
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveCardRadius(
                                  context,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _parentIdFile?.name ??
                                        'Upload Student ID (image/pdf)',
                                    style: TextStyle(color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    final res = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: const [
                                            'png',
                                            'jpg',
                                            'jpeg',
                                            'pdf',
                                          ],
                                        );
                                    if (res != null && res.files.isNotEmpty) {
                                      setState(
                                        () => _parentIdFile = res.files.first,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5E3C),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Choose File'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Create a strong password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          ResponsiveHelper.getResponsivePaddingSymmetric(
                            context,
                            horizontal: 20,
                            vertical: 16,
                          ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: ResponsiveHelper.getResponsiveIconSize(context),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Confirm Password field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Confirm your password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          ResponsiveHelper.getResponsivePaddingSymmetric(
                            context,
                            horizontal: 20,
                            vertical: 16,
                          ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: ResponsiveHelper.getResponsiveIconSize(context),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Terms and conditions checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF8B5E3C), // Coffee brown
                    ),
                    Expanded(
                      child: Text(
                        "I agree to the Terms & Conditions and Privacy Policy",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                          color: const Color.fromARGB(
                            255,
                            188,
                            118,
                            93,
                          ).withOpacity(0.8), // Darker coffee with opacity
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 40,
                    tablet: 50,
                    desktop: 60,
                  ),
                ),
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.getResponsiveButtonHeight(context),
                  child: ElevatedButton(
                    onPressed: _agreeToTerms && !_isLoading
                        ? _handleSignup
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C), // Coffee brown
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 25,
                    tablet: 30,
                    desktop: 35,
                  ),
                ),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          188,
                          118,
                          93,
                        ), // Darker coffee
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          color: const Color(0xFF8B5E3C), // Coffee brown
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 40,
                    tablet: 50,
                    desktop: 60,
                  ),
                ),
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color.fromARGB(
                          255,
                          188,
                          118,
                          93,
                        ).withOpacity(0.3), // Darker coffee with opacity
                      ),
                    ),
                    Padding(
                      padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                        context,
                        horizontal: 20,
                        vertical: 0,
                      ),
                      child: Text(
                        "Or sign up with",
                        style: TextStyle(
                          color: const Color.fromARGB(
                            255,
                            188,
                            118,
                            93,
                          ), // Darker coffee
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color.fromARGB(
                          255,
                          188,
                          118,
                          93,
                        ).withOpacity(0.3), // Darker coffee with opacity
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 30,
                    tablet: 40,
                    desktop: 50,
                  ),
                ),
                // Social signup buttons (placeholder)
                ResponsiveHelper.responsiveBuilder(
                  context: context,
                  mobile: Column(
                    children: [
                      _buildSocialButton(
                        context,
                        Icons.g_mobiledata,
                        Colors.red,
                        "Google",
                      ),
                    ],
                  ),
                  tablet: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          context,
                          Icons.g_mobiledata,
                          Colors.red,
                          "Google",
                        ),
                      ),
                    ],
                  ),
                  desktop: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: ResponsiveHelper.screenWidth(context) * 0.2,
                        child: _buildSocialButton(
                          context,
                          Icons.g_mobiledata,
                          Colors.red,
                          "Google",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    Color color,
    String text,
  ) {
    return Container(
      height: ResponsiveHelper.getResponsiveButtonHeight(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveCardRadius(context),
        ),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveMargin(
              context,
              mobile: 10,
              tablet: 15,
              desktop: 20,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
