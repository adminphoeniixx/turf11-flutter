import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';

// ─── LOGIN SCREEN ─────────────────────────────────────────────────────────────
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field banner
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: const TurfFieldBanner(),
              ),
              const SizedBox(height: 28),
              Text('Welcome back.',
                  style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text('Sign in with your mobile number',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 24),
              // Mobile input
              _MobileField(),
              const SizedBox(height: 4),
              AppButton(
                label: 'Send OTP',
                trailingIcon: Icons.arrow_forward,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OtpScreen()),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'New here? ',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.muted),
                      ),
                      TextSpan(
                        text: 'Create Account →',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
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

class _MobileField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              border:
                  Border(right: BorderSide(color: AppColors.border, width: 1.5)),
            ),
            child: Text('🇮🇳 +91',
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark2)),
          ),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                hintText: '9876543210',
                border: InputBorder.none,
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                hintStyle: GoogleFonts.dmSans(
                    fontSize: 14, color: AppColors.muted2),
              ),
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OTP SCREEN ───────────────────────────────────────────────────────────────
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _seconds = 120;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    while (_seconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _seconds--);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _timerStr {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Back', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.greenLt,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.phone_android,
                          color: AppColors.green, size: 28),
                    ),
                    const SizedBox(height: 18),
                    Text('Verify Number',
                        style: GoogleFonts.dmSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Text('We sent a 6-digit OTP to',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text('+91 9876543210',
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    // OTP boxes
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (i) {
                          return Container(
                            width: 48,
                            height: 56,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(1),
                              ],
                              style: GoogleFonts.dmSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.border, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.border, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.green, width: 2),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (v) {
                                if (v.isNotEmpty && i < 5) {
                                  _focusNodes[i + 1].requestFocus();
                                } else if (v.isEmpty && i > 0) {
                                  _focusNodes[i - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    AppButton(
                      label: 'Verify & Login',
                      trailingIcon: Icons.arrow_forward,
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (r) => false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: "Didn't receive it? ",
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppColors.muted),
                        ),
                        TextSpan(
                          text: 'Resend OTP',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.green,
                              fontWeight: FontWeight.w600),
                        ),
                      ])),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'Expires in ',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.muted2),
                        ),
                        TextSpan(
                          text: _timerStr,
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark),
                        ),
                      ])),
                    ),
                    const SizedBox(height: 24),
                    SmallCard(
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline,
                              size: 16, color: AppColors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'OTP sent via SMS. Valid for 2 minutes. Turf11 will never ask for your OTP.',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: AppColors.dark, height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── REGISTER SCREEN ──────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _roleIndex = 0;
  final List<String> _sports = ['Cricket', 'Football', 'Badminton', 'Basketball'];
  final Set<int> _selectedSports = {0};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Login', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Account',
                        style: GoogleFonts.dmSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Text('Join 50,000+ players across India',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 20),
                    _label('I am a'),
                    ChipRow(['Player', 'Turf Owner'],
                        initial: _roleIndex,
                        onChanged: (i) => setState(() => _roleIndex = i)),
                    _field('Full Name', 'Rahul Kumar'),
                    _field('Email (optional)', 'rahul@example.com',
                        type: TextInputType.emailAddress),
                    _field('City', 'Gurugram'),
                    _label('Date of Birth'),
                    _dateField(context),
                    const SizedBox(height: 14),
                    _label('Preferred Sports'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_sports.length, (i) {
                        final on = _selectedSports.contains(i);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (on) {
                              _selectedSports.remove(i);
                            } else {
                              _selectedSports.add(i);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: on ? AppColors.dark : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: on ? AppColors.dark : AppColors.border,
                                  width: 1.5),
                            ),
                            child: Text(_sports[i],
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: on ? Colors.white : AppColors.muted)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Create Account',
                      trailingIcon: Icons.arrow_forward,
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (r) => false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'By signing up you agree to our ',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.muted),
                        ),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.green),
                        ),
                      ])),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text.toUpperCase(),
          style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.7)),
    );
  }

  Widget _field(String label, String hint,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          keyboardType: type,
          decoration: InputDecoration(hintText: hint),
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.dark),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _dateField(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () async {
        await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.green),
            ),
            child: child!,
          ),
        );
      },
      decoration: const InputDecoration(
        hintText: 'Select date',
        suffixIcon: Icon(Icons.calendar_today_outlined,
            size: 18, color: AppColors.muted2),
      ),
    );
  }
}
