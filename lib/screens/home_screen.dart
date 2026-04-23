import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/profile_controller.dart';
import '../controllers/match_controller.dart';
import '../controllers/tournament_controller.dart';
import '../controllers/turf_controller.dart';
import '../controllers/wallet_controller.dart';
import '../data/models/profile_model.dart';
import '../data/models/tournament_model.dart';
import '../data/models/turf_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/shared_widgets.dart';
import 'booking_screen.dart';
import 'matches_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'teams_screen.dart';
import 'tournament_screen.dart';
import 'turf_list_screen.dart';
import 'wallet_razorpay_screen.dart';

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
      body: IndexedStack(
        index: _navIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  String _homeLocation(PlayerProfile? profile) {
    final location = profile?.locationLabel ?? '';
    if (location.isNotEmpty) {
      return location;
    }
    return 'Your City';
  }

  String _capitalize(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _formatHomeMatchDate(String value) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return value.trim().isEmpty ? 'Date TBD' : value;
    }
    return 'Today';
  }

  String _playerInitialsForIndex(int index) {
    const initials = ['RS', 'AK', 'MV', 'SK', 'PJ', 'RT', 'NK', 'AD'];
    return initials[index % initials.length];
  }

  @override
  Widget build(BuildContext context) {
    final walletController = Get.put(WalletController());
    final matchController = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    final turfController = Get.isRegistered<TurfController>()
        ? Get.find<TurfController>()
        : Get.put(TurfController());
    final tournamentController = Get.isRegistered<TournamentController>()
        ? Get.find<TournamentController>()
        : Get.put(TournamentController());
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    if (walletController.wallet.value == null &&
        !walletController.isLoading.value) {
      walletController.loadWallet();
    }
    if (profileController.profile.value == null &&
        !profileController.isLoading.value) {
      profileController.loadProfile();
    }
    if (turfController.turfs.isEmpty && !turfController.isLoading.value) {
      turfController.loadNearbyTurfs();
    }
    if (matchController.nearbyMatches.isEmpty &&
        !matchController.isNearbyLoading.value) {
      matchController.loadNearbyMatches();
    }
    if (tournamentController.tournaments.isEmpty &&
        !tournamentController.isLoading.value) {
      tournamentController.loadTournaments();
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                Obx(() {
                  final profile = profileController.profile.value;
                  final initials = profile?.initials ?? 'P';
                  final location = _homeLocation(profile);
                  final greetingName = profile?.name.trim().isNotEmpty == true
                      ? profile!.name.trim()
                      : 'Player';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.mapPin,
                                size: 11,
                                color: AppColors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hey, $greetingName',
                            style: GoogleFonts.dmSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const ProfileScreen(showBackButton: true),
                          ),
                        ),
                        child: Stack(
                          children: [
                            AppAvatar(
                              initials: initials,
                              size: 44,
                              bg: AppColors.green,
                              fg: Colors.white,
                            ),
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
                                    color: AppColors.bg,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    initials.substring(0, 1),
                                    style: const TextStyle(
                                      fontSize: 7,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                // custom.SearchBar(
                //   hint: 'Search turfs, players, matches...',
                //   readOnly: true,
                //   onTap: () {},
                // ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const WalletRazorpayScreen()),
                  ),
                  child: Obx(() {
                    final wallet = walletController.wallet.value;
                    final balanceText = wallet == null
                        ? '...'
                        : 'Rs ${wallet.walletBalance.toStringAsFixed(2)}';

                    return Container(
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
                                size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Turf11 Wallet',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                balanceText,
                                style: GoogleFonts.dmSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
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
                                Text(
                                  'Add Money',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CreateMatchScreen()),
                        ),
                        child: const _QuickAction(
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
                        child: const _QuickAction(
                          icon: LucideIcons.users,
                          title: 'Join Match',
                          sub: 'Find nearby games',
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TeamsScreen(showBackButton: true),
                    ),
                  ),
                  child: SmallCard(
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.greenLt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            LucideIcons.shield,
                            color: AppColors.green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Teams',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Create squads, invite players, and use them in tournaments.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Open',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nearby Turfs',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const TurfListScreen(showBackButton: true),
                        ),
                      ),
                      child: Text(
                        'See all ->',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final turfs = turfController.turfs;
                  if (turfController.isLoading.value && turfs.isEmpty) {
                    return const _HomeTurfShimmerCard();
                  }

                  if (turfs.isEmpty) {
                    return SmallCard(
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            color: AppColors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              turfController.errorMessage.value.isNotEmpty
                                  ? turfController.errorMessage.value
                                  : 'Nearby turf data is not available right now.',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final turf = turfs.first;
                  return _TurfCard(
                    turf: turf,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          turfId: turf.id,
                          turfName: turf.name,
                          sportType: turf.sportType,
                          pricePerHour: turf.pricePerHour.toInt(),
                        ),
                      ),
                    ),
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Matches Nearby',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const JoinMatchScreen(),
                        ),
                      ),
                      child: Text(
                        'See all ->',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final matches = matchController.nearbyMatches;
                  if (matchController.isNearbyLoading.value && matches.isEmpty) {
                    return const _HomeMatchShimmerCard();
                  }

                  if (matches.isEmpty) {
                    return SmallCard(
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.users,
                            color: AppColors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Nearby match data is not available right now.',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final match = matches.first;
                  final slotsLeft = match.slotsLeft;
                  final progress = match.fillProgress;
                  final isJoined = matchController.isMatchJoined(match.id);
                  final visibleSlots = match.maxPlayers.clamp(0, 8);
                  final filledSlots = match.joinedPlayers.clamp(0, visibleSlots);

                  return SmallCard(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_capitalize(match.sport)} ${match.format} | ${match.city}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatHomeMatchDate(match.date)} ${match.timeStart} · $slotsLeft slots left',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10.5,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MatchDetailScreen(
                                    matchId: match.id,
                                    initiallyJoined: isJoined,
                                  ),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  isJoined ? 'View' : 'Join',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: List.generate(visibleSlots, (index) {
                            final filled = index < filledSlots;
                            return Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: PlayerDot(
                                initials: filled
                                    ? _playerInitialsForIndex(index)
                                    : null,
                                filled: filled,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: SizedBox(
                            width: 360,
                            child: AppProgress(progress),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tournaments',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const TournamentScreen(showBackButton: true),
                        ),
                      ),
                      child: Text(
                        'See all ->',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final tournaments = tournamentController.tournaments;
                  if (tournamentController.isLoading.value &&
                      tournaments.isEmpty) {
                    return const _HomeTournamentShimmerCard();
                  }

                  if (tournaments.isEmpty) {
                    return SmallCard(
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.trophy,
                            color: AppColors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tournamentController.errorMessage.value.isNotEmpty
                                  ? tournamentController.errorMessage.value
                                  : 'Tournament data is not available right now.',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final tournament = tournaments.first;
                  return _HomeTournamentCard(tournament: tournament);
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTournamentCard extends StatelessWidget {
  final TournamentModel tournament;

  const _HomeTournamentCard({
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    return SmallCard(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TournamentScreen(showBackButton: true),
          ),
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
              child: const Icon(
                LucideIcons.trophy,
                color: AppColors.green,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tournament.startDate} | ${tournament.sport} | ${tournament.maxTeams} teams | ${tournament.entryFeeLabel}',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  AppBadge(
                    tournament.statusLabel,
                    type: _badgeType(tournament.status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BadgeType _badgeType(String status) {
    switch (status.trim().toLowerCase()) {
      case 'registration_open':
        return BadgeType.amber;
      case 'completed':
        return BadgeType.dark;
      case 'ongoing':
        return BadgeType.green;
      default:
        return BadgeType.green;
    }
  }
}

class _HomeTournamentShimmerCard extends StatelessWidget {
  const _HomeTournamentShimmerCard();

  @override
  Widget build(BuildContext context) {
    return SmallCard(
      child: Row(
        children: const [
          ShimmerBox(
            width: 46,
            height: 46,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: 170,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(height: 6),
                ShimmerBox(
                  width: 220,
                  height: 10,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(height: 8),
                ShimmerBox(
                  width: 110,
                  height: 22,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ],
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

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
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
            child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.dmSans(
                fontSize: 10, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _TurfCard extends StatelessWidget {
  final TurfModel turf;
  final VoidCallback? onTap;

  const _TurfCard({
    required this.turf,
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: TurfFieldBanner(
                badgeText: turf.formatLabel,
                badgeColor: Colors.white.withOpacity(0.9),
                badgeTextColor: AppColors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          turf.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        turf.priceLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: turf.hasPrice ? 16 : 12,
                          fontWeight: FontWeight.w800,
                          color:
                              turf.hasPrice ? AppColors.green : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 10, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _locationText(turf),
                          style: GoogleFonts.dmSans(
                              fontSize: 10, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${turf.ratingLabel} ${turf.reviewLabel}',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.green),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Book Now',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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

  String _locationText(TurfModel turf) {
    final distance = turf.distanceKm != null && turf.distanceKm! > 0
        ? '${turf.distanceKm!.toStringAsFixed(1)} km | '
        : '';
    final address = turf.address.trim().isNotEmpty ? turf.address : turf.location;
    return '$distance$address';
  }
}

class _HomeTurfShimmerCard extends StatelessWidget {
  const _HomeTurfShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: const ShimmerBox(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 18,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    SizedBox(width: 12),
                    ShimmerBox(
                      width: 78,
                      height: 18,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ShimmerBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(
                      width: 110,
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    ShimmerBox(
                      width: 92,
                      height: 32,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
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
}

class _HomeMatchShimmerCard extends StatelessWidget {
  const _HomeMatchShimmerCard();

  @override
  Widget build(BuildContext context) {
    return SmallCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: 180,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    SizedBox(height: 8),
                    ShimmerBox(
                      width: 160,
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              ShimmerBox(
                width: 68,
                height: 30,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
              SizedBox(width: 5),
              ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
              SizedBox(width: 5),
              ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
              SizedBox(width: 5),
              ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
              SizedBox(width: 5),
              ShimmerBox(width: 30, height: 30, shape: BoxShape.circle),
            ],
          ),
          SizedBox(height: 10),
          ShimmerBox(
            width: double.infinity,
            height: 5,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ],
      ),
    );
  }
}
