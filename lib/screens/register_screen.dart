import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final controller =
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController());

  // ✅ Controllers added
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final dobController = TextEditingController();
  final List<String> _sports = [
    'Cricket',
    'Football',
    'Badminton',
    'Basketball'
  ];
  final Set<int> _selectedSports = {0};
  DateTime? _selectedDob;

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    cityController.dispose();
    stateController.dispose();
    dobController.dispose();
    super.dispose();
  }

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

                    // ✅ Fields with controller
                    _field(
                      'Phone Number',
                      '9876543210',
                      phoneController,
                      type: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    _field('Full Name', 'Enter your full name', nameController),
                    _field('Email (optional)', 'Enter your email',
                        emailController,
                        type: TextInputType.emailAddress),
                    _field('City', 'Enter your city', cityController),
                    _field('State', 'Enter your state', stateController),

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
                                    color:
                                        on ? Colors.white : AppColors.muted)),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // ✅ API CALL BUTTON
                    Obx(
                      () => AppButton(
                        label: controller.isLoading.value
                            ? 'Sending OTP...'
                            : 'Send OTP & Continue',
                        trailingIcon: controller.isLoading.value
                            ? null
                            : Icons.arrow_forward,
                        onTap: controller.isLoading.value
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                final phone = phoneController.text.trim();
                                final name = nameController.text.trim();
                                final email = emailController.text.trim();
                                final city = cityController.text.trim();
                                final state = stateController.text.trim();

                                if (phone.length != 10) {
                                  Get.snackbar("Error", "Enter a valid phone number");
                                  return;
                                }

                                if (name.isEmpty || city.isEmpty || state.isEmpty) {
                                  Get.snackbar("Error", "Name, city and state are required");
                                  return;
                                }

                                if (_selectedSports.isEmpty) {
                                  Get.snackbar("Error", "Select at least one sport");
                                  return;
                                }

                                final sent = await controller.sendOtp(phone, false);
                                if (!sent) {
                                  return;
                                }

                                if (!context.mounted) {
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OtpScreen(
                                      phone: phone,
                                      isLogin: false,
                                      registrationData: {
                                        "name": name,
                                        if (email.isNotEmpty) "email": email,
                                        "city": city,
                                        "state": state,
                                        "sports": _selectedSports
                                            .map((i) => _sports[i].toLowerCase())
                                            .toList(),
                                      },
                                    ),
                                  ),
                                );
                              },
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

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller, // ✅ FIXED
          keyboardType: type,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint),
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.dark),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _dateField(BuildContext context) {
    return TextField(
      controller: dobController,
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDob ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDob = pickedDate;
            dobController.text = DateFormat('dd MMM yyyy').format(pickedDate);
          });
        }
      },
      decoration: const InputDecoration(
        hintText: 'Select date',
        suffixIcon: Icon(Icons.calendar_today_outlined,
            size: 18, color: AppColors.muted2),
      ),
    );
  }
}
