import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/team_controller.dart';
import '../data/models/team_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class TeamsScreen extends StatefulWidget {
  final bool showBackButton;

  const TeamsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late final TeamController _teamController;
  final TextEditingController _joinCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _teamController.loadTeams();
    });
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
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
            if (widget.showBackButton)
              BackRow(label: 'Teams', onBack: () => Navigator.pop(context)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _teamController.loadTeams,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 16),
                      _joinCard(),
                      const SizedBox(height: 6),
                      Obx(() {
                        final teams = _teamController.teams;
                        if (_teamController.isLoading.value && teams.isEmpty) {
                          return const _TeamListLoading();
                        }

                        if (_teamController.errorMessage.value.isNotEmpty &&
                            teams.isEmpty) {
                          return SmallCard(
                            child: Text(
                              _teamController.errorMessage.value,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.red,
                              ),
                            ),
                          );
                        }

                        if (teams.isEmpty) {
                          return const _EmptyTeamsState();
                        }

                        return Column(
                          children: teams
                              .map(
                                (team) => _TeamSummaryCard(
                                  team: team,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TeamDetailScreen(team: team),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        onPressed: () => _showTeamFormSheet(context),
        icon: const Icon(LucideIcons.plus, size: 18),
        label: Text(
          'Create Team',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Obx(() {
      final totalTeams = _teamController.teams.length;
      final totalPlayers = _teamController.teams.fold<int>(
        0,
        (total, team) => total + team.playerCount,
      );

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1C14), Color(0xFF3D6B35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teams',
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your squad, invite players, and register faster for tournaments.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.72),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _heroStat('$totalTeams', 'Active teams')),
                const SizedBox(width: 10),
                Expanded(child: _heroStat('$totalPlayers', 'Total players')),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _heroStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _joinCard() {
    return SmallCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join with Team Code',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Paste the invite code shared by your captain to join instantly.',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _joinCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'e.g. TW-AB3X',
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => AppButton(
              label: _teamController.isSaving.value ? 'Joining...' : 'Join Team',
              onTap: _teamController.isSaving.value
                  ? null
                  : () async {
                      final code = _joinCodeController.text.trim().toUpperCase();
                      if (code.isEmpty) {
                        Get.snackbar('Error', 'Please enter a valid invite code.');
                        return;
                      }
                      final result = await _teamController.joinTeamByCode(code);
                      if (result.success) {
                        _joinCodeController.clear();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTeamFormSheet(
    BuildContext context, {
    TeamModel? team,
  }) async {
    final nameController = TextEditingController(text: team?.name ?? '');
    final cityController = TextEditingController(text: team?.city ?? '');
    String selectedSport = team?.sport.toLowerCase() == 'football'
        ? 'football'
        : 'cricket';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team == null ? 'Create Team' : 'Edit Team',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sport',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['cricket', 'football'].map((sport) {
                        final isSelected = selectedSport == sport;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedSport = sport),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppColors.dark : AppColors.bg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.dark
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              _capitalize(sport),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.dark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => AppButton(
                        label: _teamController.isSaving.value
                            ? 'Saving...'
                            : team == null
                                ? 'Create Team'
                                : 'Save Changes',
                        onTap: _teamController.isSaving.value
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final city = cityController.text.trim();
                                if (name.isEmpty || city.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please fill team name and city.',
                                  );
                                  return;
                                }

                                final result = team == null
                                    ? await _teamController.createTeam(
                                        name: name,
                                        sport: selectedSport,
                                        city: city,
                                      )
                                    : await _teamController.updateTeam(
                                        teamId: team.id,
                                        name: name,
                                        sport: selectedSport,
                                        city: city,
                                      );

                                if (result.success && mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _capitalize(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }
    final normalized = value.trim().toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

class TeamDetailScreen extends StatefulWidget {
  final TeamModel team;

  const TeamDetailScreen({
    super.key,
    required this.team,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late final TeamController _teamController;

  @override
  void initState() {
    super.initState();
    _teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());
    _teamController.selectedTeam.value = widget.team;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _teamController.loadTeamDetail(widget.team.id);
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
                final team = _teamController.selectedTeam.value ?? widget.team;
                if (_teamController.isDetailLoading.value &&
                    _teamController.selectedTeam.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailHero(team: team),
                      const SizedBox(height: 12),
                      _actionPanel(context, team),
                      const SizedBox(height: 6),
                      if (_teamController.detailErrorMessage.value.isNotEmpty)
                        SmallCard(
                          child: Text(
                            _teamController.detailErrorMessage.value,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      SmallCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Players',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (team.members.isEmpty)
                              Text(
                                'Players will appear here once the team detail API returns them.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              )
                            else
                              ...team.members.map(
                                (member) => _MemberTile(
                                  member: member,
                                  showRemove: team.canManage && !member.isCaptain,
                                  onRemove: () => _removeMember(team, member),
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
          ],
        ),
      ),
    );
  }

  Widget _actionPanel(BuildContext context, TeamModel team) {
    return SmallCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Copy Code',
                  isOutline: true,
                  onTap: () {
                    if (team.code.isEmpty) {
                      Get.snackbar('Info', 'No team code available yet.');
                      return;
                    }
                    _copyText(team.code, 'Team code copied.');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: _teamController.isInviteLoading.value
                      ? 'Loading...'
                      : 'Invite',
                  onTap: !team.canManage || _teamController.isInviteLoading.value
                      ? null
                      : () => _showInviteSheet(context, team),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (team.canManage) ...[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit Team',
                    isOutline: true,
                    onTap: () => _showEditSheet(context, team),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Delete Team',
                    color: AppColors.red,
                    onTap: () => _confirmDelete(team),
                  ),
                ),
              ],
            ),
          ] else
            AppButton(
              label: 'Leave Team',
              color: AppColors.red,
              onTap: () => _confirmLeave(team),
            ),
        ],
      ),
    );
  }

  Future<void> _showInviteSheet(BuildContext context, TeamModel team) async {
    final invite = await _teamController.loadInviteLink(team.id);
    if (!mounted || invite == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final inviteMessage = _inviteMessage(team, invite);
        final hasWhatsapp = invite.whatsappUrl.trim().isNotEmpty;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite Players',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 12),
                _InviteRow(label: 'Code', value: invite.code),
                _InviteRow(label: 'Invite Link', value: invite.inviteLink),
                if (invite.whatsappUrl.isNotEmpty)
                  _InviteRow(label: 'WhatsApp URL', value: invite.whatsappUrl),
                if (inviteMessage.isNotEmpty)
                  _InviteRow(label: 'Share Message', value: inviteMessage),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'WhatsApp',
                        onTap: hasWhatsapp
                            ? () => _openWhatsappInvite(invite, inviteMessage)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'More Apps',
                        isOutline: true,
                        onTap: () => _shareInvite(team, invite),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Copy Message',
                        isOutline: true,
                        onTap: () => _copyText(
                          inviteMessage.isNotEmpty
                              ? inviteMessage
                              : invite.inviteLink.isNotEmpty
                                  ? invite.inviteLink
                                  : invite.code,
                          'Invite message copied.',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Copy Link',
                        isOutline: true,
                        onTap: () => _copyText(
                          invite.inviteLink.isNotEmpty
                              ? invite.inviteLink
                              : invite.code,
                          'Invite link copied.',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditSheet(BuildContext context, TeamModel team) async {
    final nameController = TextEditingController(text: team.name);
    final cityController = TextEditingController(text: team.city);
    String selectedSport = team.sport.toLowerCase() == 'football'
        ? 'football'
        : 'cricket';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Team',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Team Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: ['cricket', 'football'].map((sport) {
                        final isSelected = selectedSport == sport;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedSport = sport),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppColors.dark : AppColors.bg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.dark
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              _capitalize(sport),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.dark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => AppButton(
                        label: _teamController.isSaving.value
                            ? 'Saving...'
                            : 'Save Changes',
                        onTap: _teamController.isSaving.value
                            ? null
                            : () async {
                                final result = await _teamController.updateTeam(
                                  teamId: team.id,
                                  name: nameController.text.trim(),
                                  sport: selectedSport,
                                  city: cityController.text.trim(),
                                );
                                if (result.success && mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
    if (mounted) {
      _teamController.loadTeamDetail(team.id);
    }
  }

  Future<void> _removeMember(TeamModel team, TeamMemberModel member) async {
    final shouldRemove = await _confirmAction(
      title: 'Remove Player',
      message: 'Remove ${member.name} from ${team.name}?',
    );
    if (shouldRemove != true) {
      return;
    }
    await _teamController.removeMember(teamId: team.id, memberId: member.id);
  }

  Future<void> _confirmDelete(TeamModel team) async {
    final shouldDelete = await _confirmAction(
      title: 'Delete Team',
      message: 'This will permanently delete ${team.name}.',
    );
    if (shouldDelete != true) {
      return;
    }
    final result = await _teamController.deleteTeam(team.id);
    if (result.success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmLeave(TeamModel team) async {
    final shouldLeave = await _confirmAction(
      title: 'Leave Team',
      message: 'You will exit ${team.name} and need an invite to rejoin.',
    );
    if (shouldLeave != true) {
      return;
    }
    final result = await _teamController.leaveTeam(team.id);
    if (result.success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool?> _confirmAction({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyText(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    Get.snackbar('Copied', message);
  }

  String _inviteMessage(TeamModel team, TeamInviteModel invite) {
    if (invite.shareMessage.trim().isNotEmpty) {
      return invite.shareMessage.trim();
    }
    final code = invite.code.isNotEmpty ? invite.code : team.code;
    final link = invite.inviteLink.trim();
    final buffer = StringBuffer('Join my team "${team.name}" on Turf11!');
    if (code.isNotEmpty) {
      buffer.write('\n\nUse code: $code');
    }
    if (link.isNotEmpty) {
      buffer.write('\nOr tap: $link');
    }
    return buffer.toString();
  }

  Future<void> _shareInvite(TeamModel team, TeamInviteModel invite) async {
    final message = _inviteMessage(team, invite);
    await SharePlus.instance.share(
      ShareParams(
        text: message.isNotEmpty ? message : invite.inviteLink,
        subject: 'Join ${team.name} on Turf11',
      ),
    );
  }

  Future<void> _openWhatsappInvite(
    TeamInviteModel invite,
    String inviteMessage,
  ) async {
    final whatsappUrl = invite.whatsappUrl.trim();
    final fallbackUrl = inviteMessage.isNotEmpty
        ? 'https://wa.me/?text=${Uri.encodeComponent(inviteMessage)}'
        : '';

    final target = whatsappUrl.isNotEmpty ? whatsappUrl : fallbackUrl;
    if (target.isEmpty) {
      Get.snackbar('Error', 'No WhatsApp invite is available yet.');
      return;
    }

    final uri = Uri.tryParse(target);
    if (uri == null) {
      Get.snackbar('Error', 'WhatsApp invite link is invalid.');
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      Get.snackbar('Error', 'Unable to open WhatsApp right now.');
    }
  }
}

class _TeamSummaryCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onTap;

  const _TeamSummaryCard({
    required this.team,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SmallCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.greenLt,
                    borderRadius: BorderRadius.circular(16),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_capitalize(team.sport)} | ${team.city}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppBadge(
                  team.isCaptain ? 'Captain' : 'Player',
                  type: team.isCaptain ? BadgeType.green : BadgeType.dark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniPill(
                  icon: LucideIcons.users,
                  label: '${team.playerCount} players',
                ),
                if (team.code.isNotEmpty)
                  _MiniPill(
                    icon: LucideIcons.badgePercent,
                    label: team.code,
                  ),
                if (team.captainName.isNotEmpty)
                  _MiniPill(
                    icon: LucideIcons.crown,
                    label: team.captainName,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  final TeamModel team;

  const _DetailHero({
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D6B35), Color(0xFF6F8D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_capitalize(team.sport)} | ${team.city}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.78),
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                team.code.isEmpty ? 'No Code' : team.code,
                type: BadgeType.amber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '${team.playerCount}',
                  label: 'Players',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  value: team.captainName.isEmpty ? '-' : team.captainName,
                  label: 'Captain',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final TeamMemberModel member;
  final bool showRemove;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.member,
    required this.showRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AppAvatar(
            initials: member.initials,
            size: 42,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (member.displayRole.isNotEmpty) member.displayRole,
                    if (member.city.isNotEmpty) member.city,
                    if (member.phone.isNotEmpty) member.phone,
                  ].join(' | '),
                  style: GoogleFonts.dmSans(
                    fontSize: 10.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (member.isCaptain)
            const AppBadge('Captain')
          else if (showRemove)
            TextButton(
              onPressed: onRemove,
              child: Text(
                'Remove',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InviteRow extends StatelessWidget {
  final String label;
  final String value;

  const _InviteRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(20),
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

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10.5,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTeamsState extends StatelessWidget {
  const _EmptyTeamsState();

  @override
  Widget build(BuildContext context) {
    return SmallCard(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.greenLt,
              borderRadius: BorderRadius.circular(18),
            ),
            child:  const Icon(
              LucideIcons.shieldCheck,
              color: AppColors.green,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No teams yet',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your first team or join an invite with a team code.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamListLoading extends StatelessWidget {
  const _TeamListLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => const SmallCard(
          child: Column(
            children: [
              ShimmerBox(
                width: double.infinity,
                height: 18,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              SizedBox(height: 10),
              ShimmerBox(
                width: double.infinity,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
        ),
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
