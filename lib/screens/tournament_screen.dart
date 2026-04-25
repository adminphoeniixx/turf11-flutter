import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/team_controller.dart';
import '../controllers/tournament_controller.dart';
import '../data/models/team_model.dart';
import '../data/models/tournament_model.dart';
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
  late final TournamentController _tournamentController;

  @override
  void initState() {
    super.initState();
    _teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());
    _tournamentController = Get.isRegistered<TournamentController>()
        ? Get.find<TournamentController>()
        : Get.put(TournamentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_teamController.teams.isEmpty && !_teamController.isLoading.value) {
        _teamController.loadTeams();
      }
      if (_tournamentController.tournaments.isEmpty &&
          !_tournamentController.isLoading.value) {
        _tournamentController.loadTournaments();
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
              BackRow(label: 'Tournaments', onBack: () => Navigator.pop(context)),
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
              child: Obx(() {
                final tournaments = _tournamentController.tournaments;
                return RefreshIndicator(
                  onRefresh: () => _tournamentController.loadTournaments(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    children: [
                      if (_tournamentController.isLoading.value &&
                          tournaments.isEmpty)
                        ...List.generate(
                          2,
                          (_) => const _TournamentCardShimmer(),
                        )
                      else if (_tournamentController
                              .errorMessage.value.isNotEmpty &&
                          tournaments.isEmpty)
                        SmallCard(
                          child: Text(
                            _tournamentController.errorMessage.value,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.red,
                            ),
                          ),
                        )
                      else if (tournaments.isEmpty)
                        SmallCard(
                          child: Text(
                            'No tournaments are available right now.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      else
                        ...tournaments.map(
                          (tournament) => _TournamentCard(
                            tournament: tournament,
                            onRegister: () => _showRegisterSheet(
                              context,
                              tournamentId: tournament.id,
                              tournamentName: tournament.name,
                            ),
                          ),
                        ),
                      if (tournaments.isNotEmpty &&
                          _tournamentController.hasMoreTournaments)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Obx(
                            () => AppButton(
                              label: _tournamentController.isLoadMoreLoading.value
                                  ? 'Loading...'
                                  : 'Load More',
                              isOutline: true,
                              onTap: _tournamentController.isLoadMoreLoading.value
                                  ? null
                                  : () => _tournamentController.loadTournaments(
                                        loadMore: true,
                                      ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
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
                          isLoading:
                              _teamController.registeringTournamentTeamId.value ==
                                  team.id,
                          onTap: () async {
                            final result = await _teamController
                                .registerTeamForTournament(
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
        });
  }
}

class _TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final VoidCallback onRegister;

  const _TournamentCard({
    required this.tournament,
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
                colors: _gradientColors(tournament.sport),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                        tournament.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tournament.dateLabel} | ${tournament.sport}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tournament.locationLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 10.5,
                          color: Colors.white.withOpacity(0.72),
                        ),
                      ),
                      const SizedBox(height: 6),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _stat(
                        '${tournament.registeredTeams}/${tournament.maxTeams}',
                        'Teams',
                      ),
                    ),
                    Expanded(child: _stat(tournament.topPrizeLabel, 'Prize')),
                    Expanded(child: _stat(tournament.entryFeeLabel, 'Entry')),
                  ],
                ),
                const SizedBox(height: 12),
                AppProgress(tournament.registrationProgress),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: tournament.isFull ? 'Tournament Full' : 'Register Team',
                        trailingIcon:
                            tournament.isFull ? null : Icons.arrow_forward,
                        color: tournament.isFull ? AppColors.muted2 : null,
                        onTap: tournament.isFull
                            ? null
                            : onRegister,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Teams',
                        isOutline: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TournamentTeamsScreen(
                              tournamentId: tournament.id,
                              tournamentName: tournament.name,
                            ),
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

  List<Color> _gradientColors(String sport) {
    final normalized = sport.trim().toLowerCase();
    if (normalized == 'football') {
      return const [AppColors.dark, AppColors.green2];
    }
    return const [Color(0xFF2C3E20), Color(0xFF3D6B35)];
  }

  BadgeType _badgeType(String status) {
    if (tournament.isFull) {
      return BadgeType.red;
    }
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

class TournamentTeamsScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const TournamentTeamsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<TournamentTeamsScreen> createState() => _TournamentTeamsScreenState();
}

class _TournamentTeamsScreenState extends State<TournamentTeamsScreen> {
  late final TournamentController _tournamentController;
  late final TeamController _teamController;

  @override
  void initState() {
    super.initState();
    _tournamentController = Get.isRegistered<TournamentController>()
        ? Get.find<TournamentController>()
        : Get.put(TournamentController());
    _teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_teamController.teams.isEmpty && !_teamController.isLoading.value) {
        _teamController.loadTeams();
      }
      _tournamentController.loadTournamentTeams(widget.tournamentId);
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
            BackRow(label: 'Teams', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Obx(() {
                final myTeams = _teamController.teams;
                final teams = _sortedTeams(
                  _tournamentController.registeredTeams,
                  myTeams,
                );
                final summary =
                    _tournamentController.selectedTournamentSummary.value;

                if (_tournamentController.isTeamsLoading.value && teams.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () => _tournamentController.loadTournamentTeams(
                    widget.tournamentId,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                    children: [
                      _TournamentTeamsHero(
                        title: summary?.name ?? widget.tournamentName,
                        registeredTeams: summary?.registeredTeams ?? teams.length,
                        maxTeams: summary?.maxTeams ?? 0,
                      ),
                      const SizedBox(height: 8),
                      if (_tournamentController.teamsErrorMessage.value.isNotEmpty &&
                          teams.isEmpty)
                        SmallCard(
                          child: Text(
                            _tournamentController.teamsErrorMessage.value,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.red,
                            ),
                          ),
                        )
                      else if (teams.isEmpty)
                        SmallCard(
                          child: Text(
                            'No registered teams found for this tournament.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      else
                        ...teams.map(
                          (team) => _RegisteredTeamCard(
                            team: team,
                            isMyTeam: _isMyTeam(team, myTeams),
                            onViewPlayers: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TournamentTeamPlayersScreen(
                                  tournamentId: widget.tournamentId,
                                  teamId: team.id,
                                  teamName: team.teamName,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<TournamentRegisteredTeamModel> _sortedTeams(
    List<TournamentRegisteredTeamModel> teams,
    List<TeamModel> myTeams,
  ) {
    final sorted = List<TournamentRegisteredTeamModel>.from(teams);
    sorted.sort((a, b) {
      final aMine = _isMyTeam(a, myTeams);
      final bMine = _isMyTeam(b, myTeams);
      if (aMine == bMine) {
        return a.teamName.toLowerCase().compareTo(b.teamName.toLowerCase());
      }
      return aMine ? -1 : 1;
    });
    return sorted;
  }

  bool _isMyTeam(
    TournamentRegisteredTeamModel team,
    List<TeamModel> myTeams,
  ) {
    final tournamentName = team.teamName.trim().toLowerCase();
    return myTeams.any((myTeam) => myTeam.name.trim().toLowerCase() == tournamentName);
  }
}

class _TournamentTeamsHero extends StatelessWidget {
  final String title;
  final int registeredTeams;
  final int maxTeams;

  const _TournamentTeamsHero({
    required this.title,
    required this.registeredTeams,
    required this.maxTeams,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.dark, AppColors.green2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registered teams for this tournament',
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              color: Colors.white.withOpacity(0.76),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TournamentTeamsHeroStat(
                  value: '$registeredTeams',
                  label: 'Registered',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TournamentTeamsHeroStat(
                  value: maxTeams > 0 ? '$maxTeams' : '-',
                  label: 'Max Teams',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TournamentTeamsHeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _TournamentTeamsHeroStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10.5,
              color: Colors.white.withOpacity(0.74),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisteredTeamCard extends StatelessWidget {
  final TournamentRegisteredTeamModel team;
  final bool isMyTeam;
  final VoidCallback? onViewPlayers;

  const _RegisteredTeamCard({
    required this.team,
    this.isMyTeam = false,
    this.onViewPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return SmallCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMyTeam) ...[
            const AppBadge('Your Team', type: BadgeType.green),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isMyTeam ? AppColors.dark : AppColors.greenLt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  LucideIcons.shield,
                  color: isMyTeam ? Colors.white : AppColors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Captain: ${team.captainName}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                team.statusLabel,
                type: _statusBadgeType(team.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TeamInfoPill(
                icon: LucideIcons.users,
                label: '${team.playersCount} players',
              ),
              _TeamInfoPill(
                icon: LucideIcons.wallet,
                label: '${team.paymentLabel} | ${team.entryFeePaidLabel}',
              ),
              _TeamInfoPill(
                icon: LucideIcons.clock3,
                label: team.registeredAt,
              ),
              if (team.captainPhone.trim().isNotEmpty)
                _TeamInfoPill(
                  icon: LucideIcons.phone,
                  label: team.captainPhone,
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'View Players',
            isOutline: true,
            onTap: onViewPlayers,
          ),
        ],
      ),
    );
  }

  BadgeType _statusBadgeType(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'confirmed') {
      return BadgeType.green;
    }
    if (normalized == 'registered') {
      return BadgeType.amber;
    }
    return BadgeType.dark;
  }
}

class TournamentTeamPlayersScreen extends StatefulWidget {
  final int tournamentId;
  final int teamId;
  final String teamName;

  const TournamentTeamPlayersScreen({
    super.key,
    required this.tournamentId,
    required this.teamId,
    required this.teamName,
  });

  @override
  State<TournamentTeamPlayersScreen> createState() =>
      _TournamentTeamPlayersScreenState();
}

class _TournamentTeamPlayersScreenState
    extends State<TournamentTeamPlayersScreen> {
  late final TournamentController _tournamentController;

  @override
  void initState() {
    super.initState();
    _tournamentController = Get.isRegistered<TournamentController>()
        ? Get.find<TournamentController>()
        : Get.put(TournamentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tournamentController.loadTournamentTeamPlayers(
        widget.tournamentId,
        widget.teamId,
      );
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
            BackRow(label: 'Players', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Obx(() {
                final players = _tournamentController.tournamentTeamPlayers;
                final team = _tournamentController.selectedTournamentTeamSummary.value;

                if (_tournamentController.isPlayersLoading.value &&
                    players.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () => _tournamentController.loadTournamentTeamPlayers(
                    widget.tournamentId,
                    widget.teamId,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                    children: [
                      _TournamentPlayersHero(
                        teamName: team?.teamName ?? widget.teamName,
                        captainName: team?.captainName ?? '-',
                        status: team?.status ?? 'registered',
                        paymentStatus: team?.paymentStatus ?? 'pending',
                        count: players.length,
                      ),
                      const SizedBox(height: 8),
                      if (_tournamentController.playersErrorMessage.value.isNotEmpty &&
                          players.isEmpty)
                        SmallCard(
                          child: Text(
                            _tournamentController.playersErrorMessage.value,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.red,
                            ),
                          ),
                        )
                      else if (players.isEmpty)
                        SmallCard(
                          child: Text(
                            'No players found for this team.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      else
                        ...players.map((player) => _TournamentPlayerCard(player: player)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentPlayersHero extends StatelessWidget {
  final String teamName;
  final String captainName;
  final String status;
  final String paymentStatus;
  final int count;

  const _TournamentPlayersHero({
    required this.teamName,
    required this.captainName,
    required this.status,
    required this.paymentStatus,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E20), AppColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teamName,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Captain: $captainName',
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              color: Colors.white.withOpacity(0.76),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(_labelize(status), type: BadgeType.amber),
              AppBadge(_labelize(paymentStatus), type: BadgeType.dark),
              AppBadge('$count Players', type: BadgeType.green),
            ],
          ),
        ],
      ),
    );
  }

  String _labelize(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '-';
    }
    return normalized
        .split('_')
        .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class _TournamentPlayerCard extends StatelessWidget {
  final TournamentTeamPlayerModel player;

  const _TournamentPlayerCard({
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return SmallCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                initials: player.initials,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (player.city.trim().isNotEmpty) player.city,
                        if (player.phone.trim().isNotEmpty) player.phone,
                      ].join(' | '),
                      style: GoogleFonts.dmSans(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (player.isCaptain) const AppBadge('Captain'),
            ],
          ),
          if (player.email.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              player.email,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.muted,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TeamInfoPill(
                icon: LucideIcons.calendarDays,
                label: '${player.stats.totalBookings} bookings',
              ),
              _TeamInfoPill(
                icon: LucideIcons.activity,
                label: '${player.stats.matchesPlayed} matches',
              ),
              if (player.sports.isNotEmpty)
                _TeamInfoPill(
                  icon: LucideIcons.trophy,
                  label: player.sports.join(', '),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TeamInfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.green),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentCardShimmer extends StatelessWidget {
  const _TournamentCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: 180,
                  height: 18,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(height: 8),
                ShimmerBox(
                  width: 140,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(height: 6),
                ShimmerBox(
                  width: 220,
                  height: 10,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 54,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 54,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 54,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ShimmerBox(
                  width: double.infinity,
                  height: 5,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
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
                  '${team.playerCount} players | ${_capitalize(team.sport)}',
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
