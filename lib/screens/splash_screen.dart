import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/session_bootstrap_service.dart';
import '../core/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _bootstrapSession();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrapSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _isRouting) {
      return;
    }

    final hasToken = await StorageService.hasToken();
    if (!mounted || _isRouting) {
      return;
    }

    if (hasToken) {
      await SessionBootstrapService.bootstrapSession(forceRefresh: true);
      if (!mounted || _isRouting) {
        return;
      }
      _goHome();
      return;
    }

    _goLogin();
  }

  void _goLogin() {
    if (_isRouting || !mounted) {
      return;
    }
    _isRouting = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _goHome() {
    if (_isRouting || !mounted) {
      return;
    }
    _isRouting = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF071005),
                    AppColors.dark,
                    Color(0xFF081407),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const AppLogo(width: 240),
                  const SizedBox(height: 24),
                  Text(
                    'Book. Play. Compete.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Loading...',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
