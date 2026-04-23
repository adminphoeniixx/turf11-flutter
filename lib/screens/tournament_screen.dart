import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/team_controller.dart';
import '../data/models/team_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'teams_screen.dart';

class TournamentScreen extends StatefulWidget {
  final bool showBackButton;

  const TournamentScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  late final TeamController _teamController;

  @override
  void initState() {
    super.initState();
    _teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_teamController.teams.isEmpty && !_teamController.isLoading.value) {
        _teamController.loadTeams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBackButton)
              BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tournaments',
                    style: GoogleFonts.dmSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    'Compete. Win. Repeat.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: ChipRow(['Open', 'My Team', 'Completed']),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                child: ListView(
                  children: [
                    _TournamentCard(
                      tournamentId: 1,
                      title: 'Gurugram T10 Cup',
                      dates: 'Apr 12-20 | Cricket',
                      teams: 16,
                      prize: 'Rs 5K',
                      entry: 'Rs 500',
                      status: 'Registration Open',
                      gradientColors: const [
                        Color(0xFF2C3E20),
                        Color(0xFF3D6B35),
                      ],
                      onRegister: () => _showRegisterSheet(
                        context,
                        tournamentId: 1,
                        tournamentName: 'Gurugram T10 Cup',
                      ),
                    ),
                    _TournamentCard(
                      tournamentId: 2,
                      title: 'Sector Flash T20',
                      dates: 'Apr 26 | Cricket | 1 Day',
                      teams: 8,
                      prize: 'Rs 3K',
                      entry: 'Rs 300',
                      status: 'Coming Soon',
                      gradientColors: const [
                        Color(0xFF1A3A5C),
                        Color(0xFF2563EB),
                      ],
                      onRegister: () => _showRegisterSheet(
                        context,
                        tournamentId: 2,
                        tournamentName: 'Sector Flash T20',
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

  Future<void> _showRegisterSheet(
    BuildContext context, {
    required int tournamentId,
    required String tournamentName,
  }) async {
    if (_teamController.teams.isEmpty && !_teamController.isLoading.value) {
      await _teamController.loadTeams();
    }

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Obx(() {
              final teams = _teamController.teams;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register for $tournamentName',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_teamController.isLoading.value && teams.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (teams.isEmpty) ...[
                      Text(
                        'Create a team first, then register it here.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        label: 'Open Teams',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TeamsScreen(showBackButton: true),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      ...teams.map(
                        (team) => _TournamentTeamTile(
                          team: team,
                          isLoading: _teamController.isSaving.value,
                          onTap: () async {
                            final result =
                                await _teamController.registerTeamForTournament(
                              tournamentId: tournamentId,
                              playerTeamId: team.id,
                            );
                            if (result.success && mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final int tournamentId;
  final String title;
  final String dates;
  final String status;
  final int teams;
  final String prize;
  final String entry;
  final List<Color> gradientColors;
  final VoidCallback onRegister;

  const _TournamentCard({
    required this.tournamentId,
    required this.title,
    required this.dates,
    required this.status,
    required this.teams,
    required this.prize,
    required this.entry,
    required this.gradientColors,
    required this.onRegister,
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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
                  child: const Icon(
                    LucideIcons.trophy,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dates,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppBadge(status, type: BadgeType.amber),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                        onTap: onRegister,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'My Teams',
                        isOutline: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TeamsScreen(showBackButton: true),
                          ),
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
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
    );
  }
}

class _TournamentTeamTile extends StatelessWidget {
  final TeamModel team;
  final bool isLoading;
  final VoidCallback onTap;

  const _TournamentTeamTile({
    required this.team,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmallCard(
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
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${team.memberCount} players | ${_capitalize(team.sport)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 10.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: AppButton(
              label: isLoading ? 'Please wait' : 'Select',
              onTap: isLoading ? null : onTap,
            ),
          ),
        ],
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.trim().isEmpty) {
    return '-';
  }
  final normalized = value.trim().toLowerCase();
  return normalized[0].toUpperCase() + normalized.substring(1);
}
