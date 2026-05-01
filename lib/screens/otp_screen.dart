import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final bool isLogin;
  final Map<String, dynamic>? registrationData;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.isLogin,
    this.registrationData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  int _seconds = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _seconds <= 0) {
        timer.cancel();
        return;
      }

      setState(() => _seconds--);
    });
  }

  String get _timerStr {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _handleOtpChanged(String value, int index) {
    if (value.length > 1) {
      _fillOtp(value);
      return;
    }

    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  KeyEventResult _handleOtpKey(KeyEvent event, int index) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace ||
        index == 0 ||
        _controllers[index].text.isNotEmpty) {
      return KeyEventResult.ignored;
    }

    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
    return KeyEventResult.handled;
  }

  void _fillOtp(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return;
    }

    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }

    final nextIndex = digits.length >= _focusNodes.length
        ? _focusNodes.length - 1
        : digits.length;
    _focusNodes[nextIndex].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'OTP Verification', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON
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

                    Text('+91 ${widget.phone}',
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),

                    // OTP BOXES
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: AutofillGroup(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            return Container(
                              width: 48,
                              height: 56,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Focus(
                                onKeyEvent: (_, event) =>
                                    _handleOtpKey(event, i),
                                child: TextField(
                                  controller: _controllers[i],
                                  focusNode: _focusNodes[i],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  textInputAction: i == 5
                                      ? TextInputAction.done
                                      : TextInputAction.next,
                                  autofillHints: i == 0
                                      ? const [AutofillHints.oneTimeCode]
                                      : null,
                                  enableSuggestions: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
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
                                    counterText: '',
                                  ),
                                  onChanged: (value) =>
                                      _handleOtpChanged(value, i),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    // VERIFY BUTTON
                    Obx(
                      () => AppButton(
                        label: controller.isLoading.value
                            ? (widget.isLogin
                                ? 'Verifying...'
                                : 'Creating account...')
                            : (widget.isLogin
                                ? 'Verify & Login'
                                : 'Verify & Register'),
                        large: true,
                        onTap: controller.isLoading.value
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                final otp = _controllers.map((e) => e.text).join();

                                if (otp.length != 6) {
                                  Get.snackbar("Error", "Enter valid OTP");
                                  return;
                                }

                                bool isSuccess = false;
                                if (widget.isLogin) {
                                  isSuccess =
                                      await controller.login(widget.phone, otp);
                                } else {
                                  final payload = <String, dynamic>{
                                    ...?widget.registrationData,
                                    "phone": widget.phone,
                                    "otp": otp,
                                    "device_name": "flutter",
                                  };
                                  isSuccess = await controller.register(payload);
                                }

                                if (!isSuccess) {
                                  return;
                                }

                                Get.offAll(() => const HomeScreen());
                              },
                      ),
                    ),

                    const SizedBox(height: 10),

                    Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: controller.isLoading.value ? 1 : 0,
                        child: Text(
                          'Verifying OTP, please wait.',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // RESEND OTP
                    Center(
                      child: Obx(
                        () => GestureDetector(
                          onTap: _seconds > 0 || controller.isLoading.value
                              ? null
                              : () async {
                                  final resent =
                                      await controller.resendOtp(
                                        widget.phone,
                                        widget.isLogin,
                                      );
                                  if (resent && mounted) {
                                    setState(() => _seconds = 120);
                                    _startTimer();
                                  }
                                },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Didn't receive it? ",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                                TextSpan(
                                  text: controller.isLoading.value
                                      ? 'Please wait'
                                      : (_seconds > 0
                                          ? 'Resend in $_timerStr'
                                          : 'Resend OTP'),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: _seconds > 0 || controller.isLoading.value
                                        ? AppColors.muted2
                                        : AppColors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // TIMER
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
