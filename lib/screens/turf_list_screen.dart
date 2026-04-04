import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/shared_widgets.dart' as custom;

// ─── TURF LIST SCREEN ─────────────────────────────────────────────────────────
class TurfListScreen extends StatefulWidget {
  const TurfListScreen({super.key});

  @override
  State<TurfListScreen> createState() => _TurfListScreenState();
}

class _TurfListScreenState extends State<TurfListScreen> {
  int _sportIndex = 0;

  static const _turfs = [
    (
      name: 'DLF Arena Cricket Box',
      location: 'Sector 29 · 1.2 km',
      price: '₹800/hr',
      rating: '4.2 (128)',
      badge: '● Open Now',
      badgeColor: Colors.white,
      available: true,
    ),
    (
      name: 'Sector 56 Cricket Box',
      location: 'Sector 56 · 2.4 km',
      price: '₹600/hr',
      rating: '4.7 (89)',
      badge: '⚡ Peak Hours',
      badgeColor: Color(0xFFFEF3CD),
      available: true,
    ),
    (
      name: 'CyberHub Cricket Arena',
      location: 'CyberHub · 3.1 km',
      price: '₹900/hr',
      rating: '4.5 (203)',
      badge: '✕ Full Today',
      badgeColor: Color(0xFFFDECEA),
      available: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isInNav = ModalRoute.of(context)?.settings.name == null;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isInNav)
              BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nearby Turfs',
                                style: GoogleFonts.dmSans(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark)),
                            Text('Gurugram · 12 found',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            border:
                                Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.slidersHorizontal,
                                  size: 14, color: AppColors.dark),
                              const SizedBox(width: 5),
                              Text('Filter',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const custom.SearchBar(hint: 'Search turf name, area...'),
                    ChipRow(const ['All', 'Cricket', 'Football', 'Badminton'],
                        initial: _sportIndex,
                        onChanged: (i) => setState(() => _sportIndex = i)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _turfs.length,
                        itemBuilder: (context, i) {
                          final t = _turfs[i];
                          return _TurfListCard(
                            name: t.name,
                            location: t.location,
                            price: t.price,
                            rating: t.rating,
                            badge: t.badge,
                            badgeBg: t.badgeColor,
                            available: t.available,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const BookingScreen()),
                            ),
                          );
                        },
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

class _TurfListCard extends StatelessWidget {
  final String name, location, price, rating, badge;
  final Color badgeBg;
  final bool available;
  final VoidCallback? onTap;

  const _TurfListCard({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.badge,
    required this.badgeBg,
    required this.available,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 16,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Container(
                height: 100,
                color: const Color(0xFF2D5A1B),
                child: Stack(
                  children: [
                    Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(badge,
                              style: GoogleFonts.dmSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: available
                                      ? AppColors.green
                                      : AppColors.red)),
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark)),
                      Text(price,
                          style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(LucideIcons.mapPin,
                            size: 10, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(location,
                            style: GoogleFonts.dmSans(
                                fontSize: 10, color: AppColors.muted)),
                      ]),
                      Row(children: [
                        Text('★ $rating',
                            style: GoogleFonts.dmSans(
                                fontSize: 10, color: AppColors.green)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _pill('Map', AppColors.white, AppColors.dark),
                      const SizedBox(width: 6),
                      _pill(
                          available ? 'Book' : 'Notify Me',
                          available ? AppColors.dark : AppColors.white,
                          available ? Colors.white : AppColors.dark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: bg == AppColors.white
            ? Border.all(color: AppColors.border, width: 1.5)
            : null,
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ─── BOOKING SCREEN ───────────────────────────────────────────────────────────
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedDay = 16;
  int _selectedSlot = 4;
  int _selectedPeople = 7; // index for 16

  static const _slots = [
    '04:00–06:00',
    '06:00–08:00',
    '08:00–10:00',
    '10:00–12:00',
    '12:00–14:00',
    '16:00–18:00',
    '18:00–20:00',
    '20:00–22:00',
  ];
  static const _takenSlots = {2};
  static const _people = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(
                label: 'Book Your Slot', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.09),
                              blurRadius: 16,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(LucideIcons.chevronLeft,
                              size: 18, color: AppColors.dark),
                          Text('April 2025',
                              style: GoogleFonts.dmSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark)),
                          const Icon(LucideIcons.chevronRight,
                              size: 18, color: AppColors.dark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Day row
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7, mainAxisSpacing: 4),
                      itemCount: 7 + 28,
                      itemBuilder: (ctx, i) {
                        if (i < 7) {
                          const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                          return Center(
                              child: Text(days[i],
                                  style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.muted2)));
                        }
                        final day = i - 6;
                        final on = day == _selectedDay;
                        final today = day == 9;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = day),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: on ? AppColors.dark : Colors.transparent,
                              shape: BoxShape.circle,
                              border: today && !on
                                  ? Border.all(
                                      color: AppColors.green, width: 1.5)
                                  : null,
                            ),
                            child: Center(
                              child: Text('$day',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: on
                                          ? Colors.white
                                          : today
                                              ? AppColors.green
                                              : AppColors.muted)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text('Time Slot',
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_slots.length, (i) {
                        final taken = _takenSlots.contains(i);
                        final on = i == _selectedSlot && !taken;
                        return GestureDetector(
                          onTap: taken
                              ? null
                              : () => setState(() => _selectedSlot = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: taken
                                  ? AppColors.bg
                                  : on
                                      ? AppColors.dark
                                      : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: on ? AppColors.dark : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(_slots[i],
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: taken
                                        ? AppColors.muted2
                                        : on
                                            ? Colors.white
                                            : AppColors.muted)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text('No. of People',
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6),
                      itemCount: _people.length,
                      itemBuilder: (ctx, i) {
                        final on = i == _selectedPeople;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPeople = i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: on ? AppColors.dark : AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: on ? AppColors.dark : AppColors.border,
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                  '${_people[i].toString().padLeft(2, '0')}',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          on ? Colors.white : AppColors.dark)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    // Summary
                    SmallCard(
                      child: Column(
                        children: [
                          const InfoRow(
                              label: 'Turf', value: 'DLF Arena Cricket'),
                          const InfoRow(
                              label: 'Date & Time',
                              value: 'Apr 17, 16:00–18:00'),
                          const AppDivider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark)),
                              Text('₹1,600',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.green)),
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
                        MaterialPageRoute(
                            builder: (_) => const CreateMatchScreen()),
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

// ─── JOIN MATCH SCREEN ────────────────────────────────────────────────────────
class JoinMatchScreen extends StatelessWidget {
  const JoinMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Join a Match',
                        style: GoogleFonts.dmSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Text('Open matches near you',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _MatchCard(
                            title: 'Cricket 8v8 — DLF Arena',
                            location: 'Sector 29 · Today 7:00 PM',
                            format: '8v8',
                            slotsLeft: 4,
                            pricePerPlayer: 100,
                            filledInitials: const ['RK', 'AK', 'SR', 'MV'],
                            totalSlots: 8,
                            progress: 0.5,
                          ),
                          _MatchCard(
                            title: 'Cricket T10 — Sector 56',
                            location: 'Sector 56 · Tomorrow 6:00 PM',
                            format: '10v10',
                            slotsLeft: 2,
                            pricePerPlayer: 120,
                            filledInitials: const [
                              'MS',
                              'VK',
                              'RS',
                              'KD',
                              'AS',
                              'RJ',
                              'MK',
                              'PV'
                            ],
                            totalSlots: 10,
                            progress: 0.8,
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

class _MatchCard extends StatelessWidget {
  final String title, location, format;
  final int slotsLeft, pricePerPlayer, totalSlots;
  final List<String> filledInitials;
  final double progress;

  const _MatchCard({
    required this.title,
    required this.location,
    required this.format,
    required this.slotsLeft,
    required this.pricePerPlayer,
    required this.filledInitials,
    required this.totalSlots,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(LucideIcons.mapPin,
                          size: 10, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(location,
                          style: GoogleFonts.dmSans(
                              fontSize: 10, color: AppColors.muted)),
                    ]),
                  ],
                ),
              ),
              AppBadge('$slotsLeft slots left',
                  type: slotsLeft <= 2 ? BadgeType.amber : BadgeType.green),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            const AppBadge('Cricket', type: BadgeType.amber),
            const SizedBox(width: 6),
            AppBadge(format, type: BadgeType.dark),
          ]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              ...filledInitials
                  .map((s) => PlayerDot(initials: s, filled: true)),
              ...List.generate(
                  totalSlots - filledInitials.length, (_) => const PlayerDot()),
            ],
          ),
          const SizedBox(height: 8),
          AppProgress(progress),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '₹$pricePerPlayer ',
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green),
                  ),
                  TextSpan(
                    text: 'per player',
                    style: GoogleFonts.dmSans(
                        fontSize: 10, color: AppColors.muted),
                  ),
                ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(30)),
                child: Text('Join Match',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── CREATE MATCH SCREEN ──────────────────────────────────────────────────────
class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  int _sportIndex = 0;
  int _formatIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create a Match',
                        style: GoogleFonts.dmSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Text('Set it up · Share it · We fill the rest.',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 20),
                    const SectionLabel('Sport'),
                    ChipRow(['Cricket', 'Football', 'Badminton'],
                        initial: _sportIndex,
                        onChanged: (i) => setState(() => _sportIndex = i)),
                    const SectionLabel('Select Turf'),
                    TextField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'DLF Arena Cricket, Gurugram',
                        suffixIcon: Icon(LucideIcons.chevronRight,
                            size: 16, color: AppColors.muted2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel('Date'),
                              TextField(
                                readOnly: true,
                                decoration: const InputDecoration(
                                    hintText: '2025-04-17'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel('Time'),
                              TextField(
                                readOnly: true,
                                decoration:
                                    const InputDecoration(hintText: '7:00 PM'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const SectionLabel('Format'),
                    ChipRow(['6v6', '8v8', '11v11'],
                        initial: _formatIndex,
                        onChanged: (i) => setState(() => _formatIndex = i)),
                    const SizedBox(height: 4),
                    Text('Players — 5 of 16 joined',
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        ...['RK', 'AK', 'SR', 'MV', 'PV']
                            .map((s) => PlayerDot(initials: s, filled: true)),
                        ...List.generate(11, (_) => const PlayerDot()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const AppProgress(0.31),
                    const SizedBox(height: 16),
                    // Invite link card
                    SmallCard(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.greenLt,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.link2,
                                size: 16, color: AppColors.green),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invite Link Ready',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.green)),
                                Text('turf11.in/m/x4k9f2',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 10, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(
                                  color: AppColors.border, width: 1.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(children: [
                              const Icon(LucideIcons.copy,
                                  size: 12, color: AppColors.dark),
                              const SizedBox(width: 4),
                              Text('Copy',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    ToggleRow('Auto-fill nearby players',
                        subtitle: 'App suggests available players',
                        initial: true),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Confirm Match',
                      trailingIcon: Icons.arrow_forward,
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                        label: 'Send Invites', isOutline: true, onTap: () {}),
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

// ─── WALLET SCREEN ────────────────────────────────────────────────────────────
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedAmt = 1;
  static const _amounts = [100, 500, 1000, 2000, 5000];
  static const _bonuses = [5, 30, 80, 200, 600];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.dark, Color(0xFF2C3E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TURF11 WALLET',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          Text('₹240.00',
                              style: GoogleFonts.dmSans(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('Rahul Kumar · +91 9876543210',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.6))),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _tag('✓ UPI Linked'),
                              const SizedBox(width: 8),
                              _tag('✓ Card Saved'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Quick Recharge',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        ...List.generate(_amounts.length, (i) {
                          final on = i == _selectedAmt;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedAmt = i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: on ? AppColors.dark : AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color:
                                        on ? AppColors.dark : AppColors.border,
                                    width: 1.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('₹${_amounts[i]}',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: on
                                              ? Colors.white
                                              : AppColors.dark)),
                                  Text('+${_bonuses[i]} bonus',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: on
                                              ? Colors.white.withOpacity(0.6)
                                              : AppColors.green)),
                                ],
                              ),
                            ),
                          );
                        }),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Center(
                            child: Text('Custom',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const SectionLabel('Or Enter Custom Amount'),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: AppColors.border, width: 1.5)),
                            ),
                            child: Text('₹',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.dark2)),
                          ),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter amount',
                                border: InputBorder.none,
                                filled: false,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                hintStyle: GoogleFonts.dmSans(
                                    fontSize: 14, color: AppColors.muted2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SectionLabel('Pay Via'),
                    ChipRow(['UPI', 'Card', 'Net Banking']),
                    const SizedBox(height: 4),
                    AppButton(
                      label: 'Add ₹500 to Wallet',
                      color: AppColors.green,
                      trailingIcon: Icons.arrow_forward,
                      onTap: () {},
                    ),
                    const SectionLabel('Transaction History'),
                    SmallCard(
                      child: Column(
                        children: [
                          _txn(
                              LucideIcons.arrowDownLeft,
                              AppColors.greenLt,
                              AppColors.green,
                              'Recharged',
                              'Apr 2, 2:30 PM · UPI',
                              '+₹500',
                              true),
                          const AppDivider(),
                          _txn(
                              LucideIcons.activity,
                              AppColors.redLt,
                              AppColors.red,
                              'Cricket Match — DLF Arena',
                              'Apr 1, 7:00 PM',
                              '−₹100',
                              false),
                          const AppDivider(),
                          _txn(
                              LucideIcons.trophy,
                              AppColors.redLt,
                              AppColors.red,
                              'Tournament Entry — T10 Cup',
                              'Mar 29, 11:00 AM',
                              '−₹500',
                              false),
                          const AppDivider(),
                          _txn(
                              LucideIcons.refreshCcw,
                              AppColors.greenLt,
                              AppColors.green,
                              'Refund — Cancelled Match',
                              'Mar 28, 9:14 AM',
                              '+₹50',
                              true),
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

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: GoogleFonts.dmSans(
              fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _txn(IconData icon, Color iconBg, Color iconColor, String title,
      String sub, String amount, bool positive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark)),
                Text(sub,
                    style: GoogleFonts.dmSans(
                        fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          Text(amount,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: positive ? AppColors.green : AppColors.red)),
        ],
      ),
    );
  }
}

// ─── TOURNAMENT SCREEN ────────────────────────────────────────────────────────
class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tournaments',
                      style: GoogleFonts.dmSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark)),
                  Text('Compete. Win. Repeat.',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ChipRow(['Open', 'My Team', 'Completed']),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                child: ListView(
                  children: [
                    _TournamentCard(
                      title: 'Gurugram T10 Cup',
                      dates: 'Apr 12–20 · Cricket',
                      teams: 16,
                      prize: '₹5K',
                      entry: '₹500',
                      status: 'Registration Open',
                      gradientColors: const [
                        Color(0xFF2C3E20),
                        Color(0xFF3D6B35)
                      ],
                    ),
                    _TournamentCard(
                      title: 'Sector Flash T20',
                      dates: 'Apr 26 · Cricket · 1 Day',
                      teams: 8,
                      prize: '₹3K',
                      entry: '₹300',
                      status: 'Coming Soon',
                      gradientColors: const [
                        Color(0xFF1A3A5C),
                        Color(0xFF2563EB)
                      ],
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

class _TournamentCard extends StatelessWidget {
  final String title, dates, status;
  final int teams;
  final String prize, entry;
  final List<Color> gradientColors;

  const _TournamentCard({
    required this.title,
    required this.dates,
    required this.status,
    required this.teams,
    required this.prize,
    required this.entry,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 28,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.trophy,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(dates,
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7))),
                      const SizedBox(height: 6),
                      AppBadge(status, type: BadgeType.amber),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _stat('$teams', 'Teams')),
                    Expanded(child: _stat(prize, 'Prize')),
                    Expanded(child: _stat(entry, 'Entry')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Register Team',
                        trailingIcon: Icons.arrow_forward,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Schedule',
                        isOutline: true,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark)),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 9, color: AppColors.muted, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// ─── NOTIFICATIONS SCREEN ─────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications',
                      style: GoogleFonts.dmSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark)),
                  Text('Mark all read',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.green,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                children: [
                  _Notif(
                    icon: LucideIcons.checkCircle,
                    iconBg: AppColors.greenLt,
                    iconColor: AppColors.green,
                    title: 'Match Confirmed!',
                    body: 'Cricket 8v8 at DLF Arena confirmed for 7 PM.',
                    time: '10 min ago',
                    unread: true,
                  ),
                  _Notif(
                    icon: LucideIcons.wallet,
                    iconBg: const Color(0xFFFFFBEB),
                    iconColor: Color(0xFFB45309),
                    title: 'Payment Received',
                    body: 'Mohit Kumar paid ₹100 for tonight\'s match.',
                    time: '45 min ago',
                    unread: true,
                  ),
                  _Notif(
                    icon: LucideIcons.trophy,
                    iconBg: AppColors.greenLt,
                    iconColor: AppColors.green,
                    title: 'Tournament Registration Open',
                    body: 'Gurugram T10 Cup now accepting teams. ₹500 entry.',
                    time: 'Yesterday 3 PM',
                  ),
                  _Notif(
                    icon: LucideIcons.alertCircle,
                    iconBg: AppColors.redLt,
                    iconColor: AppColors.red,
                    title: 'Payment Reminder',
                    body: 'Arjun Nair hasn\'t paid ₹100. 6h remaining.',
                    time: 'Yesterday 8 PM',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, body, time;
  final bool unread;

  const _Notif({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unread)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 6, right: 5),
              decoration: const BoxDecoration(
                  color: AppColors.green, shape: BoxShape.circle),
            ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                const SizedBox(height: 3),
                Text(body,
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppColors.muted, height: 1.5)),
                const SizedBox(height: 4),
                Text(time,
                    style: GoogleFonts.dmSans(
                        fontSize: 10, color: AppColors.muted2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PROFILE SCREEN ───────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // Hero
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E20), AppColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const AppAvatar(
                  initials: 'RK',
                  size: 78,
                  bg: Color(0x33FFFFFF),
                  fg: Colors.white,
                  borderColor: Color(0x80FFFFFF),
                ),
                const SizedBox(height: 12),
                Text('Rahul Kumar',
                    style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.mapPin,
                        size: 11, color: Color(0xBFFFFFFF)),
                    const SizedBox(width: 4),
                    Text('Gurugram · Cricket',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.75))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _heroBadge('Verified'),
                    const SizedBox(width: 6),
                    _heroBadge('4.6 ★'),
                    const SizedBox(width: 6),
                    _heroBadge('Pro'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              child: Column(
                children: [
                  // Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        _stat('63', 'Matches'),
                        _stat('4.6', 'Rating'),
                        _stat('₹240', 'Wallet'),
                      ],
                    ),
                  ),
                  const SectionLabel('Account'),
                  AppCard(
                    child: Column(
                      children: [
                        _menuItem(LucideIcons.shield, 'Verification',
                            trailing: const AppBadge('Verified'), onTap: () {}),
                        const AppDivider(),
                        _menuItem(LucideIcons.wallet, 'Wallet & Payments',
                            onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const WalletScreen()),
                                )),
                        const AppDivider(),
                        _menuItem(LucideIcons.mapPin, 'Add My Turf',
                            onTap: () {}),
                        const AppDivider(),
                        _menuItem(LucideIcons.fileText, 'Terms & Privacy',
                            onTap: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppButton(
                    label: 'Sign Out',
                    color: AppColors.red,
                    isOutline: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
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
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark)),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 9, color: AppColors.muted, letterSpacing: 0.5)),
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
              child: Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark)),
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
}
