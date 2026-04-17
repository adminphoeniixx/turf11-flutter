import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'matches_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedDay = 16;
  int _selectedSlot = 4;
  int _selectedPeople = 7;

  static const _slots = [
    '04:00-06:00',
    '06:00-08:00',
    '08:00-10:00',
    '10:00-12:00',
    '12:00-14:00',
    '16:00-18:00',
    '18:00-20:00',
    '20:00-22:00',
  ];

  static const _takenSlots = {2};
  static const _people = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20];

  @override
  Widget build(BuildContext context) {
    final selectedSlot = _slots[_selectedSlot];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Book Your Slot', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 16,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.dark),
                          Text(
                            'April 2026',
                            style: GoogleFonts.dmSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.dark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: 35,
                      itemBuilder: (context, index) {
                        if (index < 7) {
                          const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                          return Center(
                            child: Text(
                              days[index],
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted2,
                              ),
                            ),
                          );
                        }

                        final day = index - 6;
                        final isSelected = day == _selectedDay;
                        final isToday = day == 17;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = day),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.dark : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isToday && !isSelected
                                  ? Border.all(color: AppColors.green, width: 1.5)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? AppColors.green
                                          : AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Time Slot',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_slots.length, (index) {
                        final isTaken = _takenSlots.contains(index);
                        final isSelected = index == _selectedSlot && !isTaken;

                        return GestureDetector(
                          onTap: isTaken ? null : () => setState(() => _selectedSlot = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isTaken
                                  ? AppColors.bg
                                  : isSelected
                                      ? AppColors.dark
                                      : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? AppColors.dark : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _slots[index],
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isTaken
                                    ? AppColors.muted2
                                    : isSelected
                                        ? Colors.white
                                        : AppColors.muted,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No. of People',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: _people.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedPeople;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedPeople = index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.dark : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? AppColors.dark : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${_people[index].toString().padLeft(2, '0')}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.dark,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    SmallCard(
                      child: Column(
                        children: [
                          const InfoRow(label: 'Turf', value: 'DLF Arena Cricket'),
                          InfoRow(label: 'Date & Time', value: 'Apr $_selectedDay, $selectedSlot'),
                          InfoRow(label: 'Players', value: '${_people[_selectedPeople]} selected'),
                          const AppDivider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                              Text(
                                'Rs 1,600',
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      label: 'Confirm Booking',
                      trailingIcon: Icons.arrow_forward,
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Create Match for this Slot',
                      isOutline: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateMatchScreen()),
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
