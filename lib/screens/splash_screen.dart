import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../utils/routes.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start animations
    _animationController.forward();
    
    // Simulate app initialization
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToNextScreen() {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isAuthenticated) {
      NavigationHelper.navigateToHome(context);
    } else {
      NavigationHelper.navigateToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Animation
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Colors.white,
                      ),
                    ).animate(controller: _animationController)
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1500.ms),
                    
                    const SizedBox(height: 32),
                    
                    // App Name
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideY(begin: 0.3, end: 0, duration: 800.ms, delay: 200.ms),
                    
                    const SizedBox(height: 8),
                    
                    // Tagline
                    Text(
                      'Delicious Food, Delivered Fast',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate(controller: _animationController)
                      .fadeIn(duration: 800.ms, delay: 400.ms)
                      .slideY(begin: 0.3, end: 0, duration: 800.ms, delay: 400.ms),
                  ],
                ),
              ),
              
              // Loading Animation or Get Started Button
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading) ...[
                      // Loading Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ).animate(controller: _animationController)
                            .scale(
                              duration: 600.ms,
                              delay: Duration(milliseconds: 800 + (index * 100)),
                              curve: Curves.easeInOut,
                            ).then()
                            .scale(
                              duration: 600.ms,
                              curve: Curves.easeInOut,
                            );
                        }),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Preparing your experience...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 1000.ms),
                    ] else ...[
                      // Get Started Button
                      CustomButton(
                        text: 'Get Started',
                        onPressed: _navigateToNextScreen,
                        isLoading: false,
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .scale(duration: 600.ms, delay: 200.ms, curve: Curves.elasticOut),
                      
                      const SizedBox(height: 16),
                      
                      // Skip for now text
                      TextButton(
                        onPressed: () {
                          // Show a snackbar or handle skip logic
                          SnackbarHelper.showTopToast(
                            context,
                            'Welcome to ${AppConstants.appName}!',
                          );
                        },
                        child: Text(
                          'Skip for now',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 400.ms),
                    ],
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

// Modern Loading Animation Widget
class ModernLoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;

  const ModernLoadingAnimation({
    super.key,
    this.size = 40.0,
    this.color,
  });

  @override
  State<ModernLoadingAnimation> createState() => _ModernLoadingAnimationState();
}

class _ModernLoadingAnimationState extends State<ModernLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    
    return SizedBox(
      width: widget.size * 3,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDot(_animation1, color),
          _buildDot(_animation2, color),
          _buildDot(_animation3, color),
        ],
      ),
    );
  }

  Widget _buildDot(Animation<double> animation, Color color) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
