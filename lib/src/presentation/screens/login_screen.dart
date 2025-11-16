import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:restaurant_store_flutter/src/core/constants/app_constants.dart';
import 'package:restaurant_store_flutter/src/core/routing/app_router.dart';
import 'package:restaurant_store_flutter/src/core/utils/snackbar_helper.dart';
import 'package:restaurant_store_flutter/src/features/auth/providers/auth_provider.dart';
import 'package:restaurant_store_flutter/src/presentation/widgets/custom_button.dart';
import 'package:restaurant_store_flutter/src/presentation/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      SnackbarHelper.showTopToast(
        context,
        AppConstants.loginSuccess,
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
              const SizedBox(height: 40),
              
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ).animate(controller: _animationController)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.3, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Sign in to continue to your account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ).animate(controller: _animationController)
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .slideX(begin: -0.3, end: 0),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
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
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 20),
                    
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
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          _showForgotPasswordDialog();
                        },
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 400.ms),
                    
                    const SizedBox(height: 30),
                    
                    // Login Button
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      width: double.infinity,
                      height: 50,
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 600.ms, delay: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      NavigationHelper.navigateToRegister(context);
                    },
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate(controller: _animationController)
                .fadeIn(duration: 600.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address and we\'ll send you a link to reset your password.'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarHelper.showTopToast(
                context,
                'Password reset email sent!',
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
