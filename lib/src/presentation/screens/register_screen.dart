import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/routing/app_router.dart';
import 'package:restaurant_store_flutter/src/core/utils/snackbar_helper.dart';
import 'package:restaurant_store_flutter/src/features/auth/providers/auth_provider.dart';
import 'package:restaurant_store_flutter/src/presentation/widgets/custom_button.dart';
import 'package:restaurant_store_flutter/src/presentation/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      SnackbarHelper.showTopToast(
        context,
        'Please agree to the terms and conditions',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      SnackbarHelper.showTopToast(
        context,
        AppConstants.registrationSuccess,
      );
      NavigationHelper.navigateToHome(context);
    } else {
      // Show error message
      SnackbarHelper.showTopToast(
        context,
        authProvider.errorMessage ?? AppConstants.generalError,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ).animate(controller: _animationController)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.3, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Join us and start ordering delicious food',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ).animate(controller: _animationController)
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .slideX(begin: -0.3, end: 0),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Fields Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hint: 'John',
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ).animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(begin: 0.3, end: 0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hint: 'Doe',
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ).animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 250.ms)
                            .slideY(begin: 0.3, end: 0),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'john.doe@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.emailRequired;
                        }
                        if (!context.read<AuthProvider>().isValidEmail(value)) {
                          return AppConstants.emailInvalid;
                        }
                        return null;
                      },
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Phone Field
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+1 (555) 123-4567',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.phoneRequired;
                        }
                        if (!context.read<AuthProvider>().isValidPhone(value)) {
                          return AppConstants.phoneInvalid;
                        }
                        return null;
                      },
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 350.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.passwordRequired;
                        }
                        if (value.length < 6) {
                          return AppConstants.passwordTooShort;
                        }
                        return null;
                      },
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
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
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 450.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Terms and Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 500.ms),
                    
                    const SizedBox(height: 30),
                    
                    // Register Button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                      width: double.infinity,
                      height: 50,
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 30),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 700.ms),
                    
                    const SizedBox(height: 20),
                    
                    // Social Registration Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Google',
                            isOutlined: true,
                            onPressed: () {
                              // TODO: Implement Google sign-up
                              _showNotImplementedDialog('Google Sign-Up');
                            },
                            icon: const Icon(Icons.g_mobiledata, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Facebook',
                            isOutlined: true,
                            onPressed: () {
                              // TODO: Implement Facebook sign-up
                              _showNotImplementedDialog('Facebook Sign-Up');
                            },
                            icon: const Icon(Icons.facebook, size: 20),
                          ),
                        ),
                      ],
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 800.ms),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      NavigationHelper.navigateToLogin(context);
                    },
                    child: Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate(controller: _animationController)
                .fadeIn(duration: 600.ms, delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotImplementedDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
