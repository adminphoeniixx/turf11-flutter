import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/shared_widgets.dart' as custom;

import 'turf_list_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final _screens = const [
    _HomeContent(),
    TurfListScreen(),
    TournamentScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _screens[_navIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ─── HOME CONTENT ─────────────────────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin,
                                size: 11, color: AppColors.green),
                            const SizedBox(width: 4),
                            Text('Gurugram, HR',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.green)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Hey, Rahul 👋',
                            style: GoogleFonts.dmSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                      child: Stack(
                        children: [
                          const AppAvatar(
                              initials: 'RK',
                              size: 44,
                              bg: AppColors.green,
                              fg: Colors.white),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.bg, width: 2),
                              ),
                              child: const Center(
                                child: Text('₹',
                                    style: TextStyle(
                                        fontSize: 7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                custom.SearchBar(
                  hint: 'Search turfs, players, matches...',
                  readOnly: true,
                  onTap: () {},
                ),
                // Wallet mini
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.wallet,
                              size: 18,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Turf11 Wallet',
                                style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w600)),
                            Text('₹240.00',
                                style: GoogleFonts.dmSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.plus,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text('Add Money',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CreateMatchScreen()),
                        ),
                        child: _QuickAction(
                          icon: LucideIcons.plusCircle,
                          title: 'Create Match',
                          sub: 'Build team fast',
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const JoinMatchScreen()),
                        ),
                        child: _QuickAction(
                          icon: LucideIcons.users,
                          title: 'Join Match',
                          sub: 'Find nearby games',
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Nearby turfs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nearby Turfs',
                        style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const TurfListScreen()),
                      ),
                      child: Text('See all →',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.green,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Turf card
                _TurfCard(
                  name: 'DLF Arena Cricket',
                  location: '1.2 km · Sector 29, Gurugram',
                  price: '₹800/hr',
                  rating: '4.2 (128)',
                  badgeText: '● Open Now',
                  badgeColor: Colors.white.withOpacity(0.9),
                  badgeTextColor: AppColors.green,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TurfListScreen()),
                  ),
                ),
                // Active matches
                Text('Active Matches Nearby',
                    style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                const SizedBox(height: 10),
                SmallCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cricket 8v8 — DLF Arena',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark)),
                              const SizedBox(height: 2),
                              Text('Today 7 PM · 4 slots left',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 10, color: AppColors.muted)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const JoinMatchScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text('Join',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ...['RS', 'AK', 'MV', 'SK']
                              .map((s) => Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: PlayerDot(initials: s, filled: true),
                                  )),
                          ...List.generate(
                              4,
                              (_) => const Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: PlayerDot(),
                                  )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const AppProgress(0.5),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Tournaments
                Text('Tournaments',
                    style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                const SizedBox(height: 10),
                SmallCard(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const TournamentScreen()),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.greenLt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(LucideIcons.trophy,
                              color: AppColors.green, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gurugram T10 Cup',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark)),
                              const SizedBox(height: 2),
                              Text('Apr 12 · Cricket · 16 teams · ₹500',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 10, color: AppColors.muted)),
                              const SizedBox(height: 5),
                              const AppBadge('Registration Open',
                                  type: BadgeType.amber),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final Color color;

  const _QuickAction(
      {required this.icon,
      required this.title,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon,
                color: Colors.white.withOpacity(0.9), size: 22),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(sub,
              style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }
}

class _TurfCard extends StatelessWidget {
  final String name, location, price, rating;
  final String? badgeText;
  final Color? badgeColor, badgeTextColor;
  final VoidCallback? onTap;

  const _TurfCard({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
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
              child: TurfFieldBanner(
                  badgeText: badgeText,
                  badgeColor: badgeColor,
                  badgeTextColor: badgeTextColor),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark)),
                      Text(price,
                          style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 10, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(location,
                          style: GoogleFonts.dmSans(
                              fontSize: 10, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('★★★★☆ $rating',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppColors.green)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('Book Now',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
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
}
