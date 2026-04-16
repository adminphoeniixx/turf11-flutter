import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
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
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted || _isRouting) {
      return;
    }

    final hasToken = await StorageService.hasToken();
    if (!mounted || _isRouting) {
      return;
    }

    if (hasToken) {
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Turf',
                          style: GoogleFonts.dmSans(
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -3,
                          ),
                        ),
                        TextSpan(
                          text: '11',
                          style: GoogleFonts.dmSans(
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                            color: AppColors.green,
                            letterSpacing: -3,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Text('BOOK · PLAY · COMPETE',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.45),
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 48),
                    // Field illustration
                    Opacity(
                      opacity: 0.18,
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: CustomPaint(painter: _FieldPainter()),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Tagline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 20, height: 1,
                            color: Colors.white.withOpacity(0.2)),
                        const SizedBox(width: 8),
                        Text('Cricket & Beyond',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.35),
                                letterSpacing: 1.5)),
                        const SizedBox(width: 8),
                        Container(
                            width: 20, height: 1,
                            color: Colors.white.withOpacity(0.2)),
                      ],
                    ),
                    const SizedBox(height: 36),
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(true),
                        const SizedBox(width: 6),
                        _dot(false),
                        const SizedBox(width: 6),
                        _dot(false),
                      ],
                    ),
                    const Spacer(flex: 2),
                    // Get Started button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRouting ? null : _goLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(_isRouting ? 'Please wait...' : 'Get Started',
                            style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.green : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Outer rect
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
            const Radius.circular(6)),
        paint);
    // Center line
    canvas.drawLine(Offset(4, size.height / 2),
        Offset(size.width - 4, size.height / 2), paint);
    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 16, paint);
    // Goals
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(4, size.height / 2 - 16, 9, 32),
            const Radius.circular(2)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width - 13, size.height / 2 - 16, 9, 32),
            const Radius.circular(2)),
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
