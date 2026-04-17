import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../data/models/profile_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'login_screen.dart';
import 'wallet_razorpay_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool showBackButton;

  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    if (profileController.profile.value == null &&
        !profileController.isLoading.value) {
      profileController.loadProfile();
    }

    return Scaffold(
        backgroundColor: AppColors.bg,
        body: Obx(() {
          final profile = profileController.profile.value;
          final isLoading =
              profileController.isLoading.value && profile == null;
          final errorMessage = profileController.errorMessage.value;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 20,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3E20), AppColors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    if (showBackButton) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            child: const Icon(
                              LucideIcons.arrowLeft,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    AppAvatar(
                      initials: profile?.initials ?? 'P',
                      size: 78,
                      bg: const Color(0x33FFFFFF),
                      fg: Colors.white,
                      borderColor: const Color(0x80FFFFFF),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile?.name ?? 'Player',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 11,
                          color: Color(0xBFFFFFFF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _locationAndSport(profile),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _heroBadge(profile == null
                            ? 'Verified'
                            : 'Member ${profile.memberSince}'),
                        _heroBadge(
                          profile == null
                              ? 'Cricket'
                              : _capitalize(profile.primarySport),
                        ),
                        _heroBadge(
                          profile == null
                              ? 'Points 0'
                              : 'Points ${profile.rewardPoints}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: profileController.loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    child: Column(
                      children: [
                        if (errorMessage.isNotEmpty && profile == null) ...[
                          AppCard(
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.alertCircle,
                                  color: AppColors.red,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              _stat(
                                '${profile?.totalBookings ?? 0}',
                                'Bookings',
                              ),
                              _stat(
                                'Rs ${_formatMoney(profile?.totalSpent ?? 0)}',
                                'Spent',
                              ),
                              _stat(
                                'Rs ${_formatMoney(profile?.walletBalance ?? 0)}',
                                'Wallet',
                              ),
                            ],
                          ),
                        ),
                        const SectionLabel('Account'),
                        AppCard(
                          child: Column(
                            children: [
                              _menuItem(
                                LucideIcons.shield,
                                'Verification',
                                trailing: const AppBadge('Verified'),
                                onTap: () {},
                              ),
                              const AppDivider(),
                              _menuItem(
                                LucideIcons.wallet,
                                'Wallet & Payments',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const WalletRazorpayScreen(),
                                  ),
                                ),
                              ),
                              const AppDivider(),
                              _menuItem(
                                LucideIcons.phone,
                                profile?.phone.isNotEmpty == true
                                    ? profile!.phone
                                    : 'Phone not added',
                              ),
                              const AppDivider(),
                              _menuItem(
                                LucideIcons.mail,
                                profile?.email.isNotEmpty == true
                                    ? profile!.email
                                    : 'Email not added',
                              ),
                              const AppDivider(),
                              _menuItem(
                                LucideIcons.mapPin,
                                profile?.locationLabel.isNotEmpty == true
                                    ? profile!.locationLabel
                                    : 'Location not added',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          label: 'Edit Profile',
                          onTap: () => _showEditProfileSheet(
                            context,
                            profileController,
                            profile,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          label: 'Log Out',
                          color: AppColors.red,
                          isOutline: true,
                          onTap: () {
                            final controller =
                                Get.isRegistered<AuthController>()
                                    ? Get.find<AuthController>()
                                    : Get.put(AuthController());

                            Get.dialog(
                              Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Log Out',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Are you sure you want to logout from this account?',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: AppColors.muted,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Obx(
                                        () => Row(
                                          children: [
                                            Expanded(
                                              child: AppButton(
                                                label: 'Cancel',
                                                isOutline: true,
                                                onTap:
                                                    controller.isLoading.value
                                                        ? null
                                                        : () => Get.back(),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: AppButton(
                                                label:
                                                    controller.isLoading.value
                                                        ? 'Logging out...'
                                                        : 'Logout',
                                                color: AppColors.red,
                                                onTap: controller
                                                        .isLoading.value
                                                    ? null
                                                    : () async {
                                                        final success =
                                                            await controller
                                                                .logout();
                                                        if (!success) {
                                                          return;
                                                        }
                                                        if (Get.isDialogOpen ??
                                                            false) {
                                                          Get.back();
                                                        }
                                                        Get.offAll(
                                                          () => LoginScreen(),
                                                        );
                                                      },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        }));
  }

  String _locationAndSport(PlayerProfile? profile) {
    final location = profile?.locationLabel ?? '';
    final sport =
        profile == null ? 'Cricket' : _capitalize(profile.primarySport);

    if (location.isEmpty) {
      return sport;
    }
    return '$location | $sport';
  }

  Widget _heroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label,
      {Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark,
                ),
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight,
                size: 14, color: AppColors.muted2),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '';
    }
    return normalized[0].toUpperCase() + normalized.substring(1).toLowerCase();
  }

  String _formatMoney(num value) {
    final isWhole = value == value.roundToDouble();
    return value.toStringAsFixed(isWhole ? 0 : 2);
  }

  void _showEditProfileSheet(
    BuildContext context,
    ProfileController profileController,
    PlayerProfile? profile,
  ) {
    final nameController = TextEditingController(text: profile?.name ?? '');
    final emailController = TextEditingController(text: profile?.email ?? '');
    final cityController = TextEditingController(text: profile?.city ?? '');
    final availableSports = ['cricket', 'football', 'badminton', 'basketball'];
    final selectedSports = <String>{
      ...?profile?.sports.map((sport) => sport.toLowerCase()),
    };

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _editLabel('Full Name'),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _editLabel('Email'),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _editLabel('City'),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your city',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _editLabel('Sports'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSports.map((sport) {
                        final isSelected = selectedSports.contains(sport);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedSports.remove(sport);
                              } else {
                                selectedSports.add(sport);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.dark
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.dark
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _capitalize(sport),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.muted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => AppButton(
                        label: profileController.isUpdating.value
                            ? 'Saving...'
                            : 'Save Changes',
                        trailingIcon: profileController.isUpdating.value
                            ? null
                            : Icons.arrow_forward,
                        onTap: profileController.isUpdating.value
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final email = emailController.text.trim();
                                final city = cityController.text.trim();

                                if (name.isEmpty || city.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Name and city are required.',
                                  );
                                  return;
                                }

                                if (selectedSports.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Select at least one sport.',
                                  );
                                  return;
                                }

                                final success =
                                    await profileController.updateProfile(
                                  name: name,
                                  email: email,
                                  city: city,
                                  sports: selectedSports.toList(),
                                );

                                if (success && (Get.isBottomSheetOpen ?? false)) {
                                  Get.back();
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _editLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}
