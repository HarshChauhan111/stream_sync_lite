import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'login_page.dart';
import 'main_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    print('🎬 SplashPage initState');
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    print('✅ Animations started');

    // Check authentication status after animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      print('⏰ Checking authentication...');
      if (mounted) {
        try {
          context.read<AuthBloc>().add(AuthCheckRequested());
          print('✅ AuthCheckRequested event sent');
        } catch (e) {
          print('❌ Error sending AuthCheckRequested: $e');
        }
      } else {
        print('⚠️ Widget not mounted, skipping auth check');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔄 SplashPage AuthState changed: ${state.runtimeType}');
        
        if (state is AuthAuthenticated) {
          print('✅ User authenticated, navigating to MainNavigationPage');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          );
        } else if (state is AuthUnauthenticated) {
          print('⚠️ User not authenticated, navigating to LoginPage');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else if (state is AuthError) {
          print('❌ Auth error: ${state.message}');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else if (state is AuthLoading) {
          print('⏳ Auth loading...');
        } else {
          print('🤔 Unknown auth state: $state');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.stream,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Stream Sync Lite',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Stay Connected',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
