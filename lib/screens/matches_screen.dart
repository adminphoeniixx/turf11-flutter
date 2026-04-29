import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/match_controller.dart';
import '../controllers/team_controller.dart';
import '../controllers/turf_controller.dart';
import '../data/models/match_model.dart';
import '../data/models/team_model.dart';
import '../data/models/turf_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class JoinMatchScreen extends StatefulWidget {
  final int initialTabIndex;

  const JoinMatchScreen({super.key, this.initialTabIndex = 0});

  @override
  State<JoinMatchScreen> createState() => _JoinMatchScreenState();
}

class _JoinMatchScreenState extends State<JoinMatchScreen> {
  late final MatchController controller;
  final joinCodeController = TextEditingController();
  final matchRadiusController = TextEditingController();
  late int selectedTab;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    selectedTab = widget.initialTabIndex;
    matchRadiusController.text =
        controller.nearbyMatchesRadiusKm.value.toString();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.refreshAll());
  }

  @override
  void dispose() {
    joinCodeController.dispose();
    matchRadiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = selectedTab == 0 ? 'Join a Match' : 'My Matches';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackRow(label: 'Create Match', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Obx(() {
                      final subtitle = selectedTab == 0
                          ? controller.isUsingFallbackLocation.value
                              ? 'Showing nearby matches within ${controller.nearbyMatchesRadiusKm.value} km using fallback coordinates because device location is unavailable.'
                              : 'Live matches from the API within ${controller.nearbyMatchesRadiusKm.value} km near your current location.'
                          : 'All matches you have created or joined.';
                      return Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    ChipRow(
                      const ['Nearby', 'My Matches'],
                      initial: selectedTab,
                      onChanged: (index) => setState(() => selectedTab = index),
                    ),
                    const SizedBox(height: 10),
                    if (selectedTab == 0) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _openMatchRadiusFilter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.slidersHorizontal,
                                  size: 14,
                                  color: AppColors.dark,
                                ),
                                const SizedBox(width: 5),
                                Obx(() {
                                  return Text(
                                    '${controller.nearbyMatchesRadiusKm.value} km',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Obx(() {
                        final isLoading = selectedTab == 0
                            ? controller.isNearbyLoading.value
                            : controller.isMyMatchesLoading.value;
                        final matches = selectedTab == 0
                            ? controller.nearbyMatches
                            : controller.myMatches;

                        if (isLoading && matches.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (matches.isEmpty) {
                          return _EmptyState(
                            title: selectedTab == 0
                                ? 'No nearby matches yet'
                                : 'No matches found',
                            subtitle: selectedTab == 0
                                ? 'Create one first or refresh again shortly.'
                                : 'Once you create or join a match, it will appear here.',
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.green,
                          onRefresh: controller.refreshAll,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final match = matches[index];
                              final isJoined = controller.isMatchJoined(
                                match.id,
                                fallback: selectedTab == 1,
                              );
                              return _MatchCard(
                                match: match,
                                actionLabel: selectedTab == 0
                                    ? (isJoined ? 'View Details' : 'Join Match')
                                    : 'View Details',
                                secondaryActionLabel:
                                    selectedTab == 0 && !isJoined
                                        ? 'Join Code'
                                        : null,
                                onTap: () => _openDetail(
                                      context,
                                      match.id,
                                      isJoined: isJoined,
                                    ),
                                onAction: () async {
                                  if (selectedTab == 0 && !isJoined) {
                                    final success =
                                        await controller.joinMatch(match.id);
                                    if (!success) {
                                      return;
                                    }
                                  }
                                  if (!context.mounted) {
                                    return;
                                  }
                                  _openDetail(
                                    context,
                                    match.id,
                                    isJoined: controller.isMatchJoined(
                                      match.id,
                                      fallback: isJoined,
                                    ),
                                  );
                                },
                                onSecondaryAction:
                                    selectedTab == 0 && !isJoined
                                        ? () => _openJoinCodeDialog(match)
                                        : null,
                              );
                            },
                          ),
                        );
                      }),
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

  void _openDetail(
    BuildContext context,
    int matchId, {
    required bool isJoined,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchDetailScreen(
          matchId: matchId,
          initiallyJoined: isJoined,
        ),
      ),
    );
  }

  Future<void> _joinByCode() async {
    final code = joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid invite code.');
      return;
    }
    final success = await controller.joinMatchWithCode(code);
    if (success) {
      joinCodeController.clear();
    }
  }

  Future<void> _openJoinCodeDialog(MatchModel match) async {
    joinCodeController.clear();
    final shouldJoin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Join With Code',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Invite code enter karke is match ko join karo.',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: joinCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'e.g. MT-AB3X5',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );

    if (shouldJoin != true) {
      joinCodeController.clear();
      return;
    }

    await _joinByCode();
  }

  Future<void> _openMatchRadiusFilter() async {
    matchRadiusController.text =
        controller.nearbyMatchesRadiusKm.value.toString();
    final pickedRadius = await _showRadiusPickerSheet(
      title: 'Match Radius',
      subtitle: 'Nearby match search ke liye radius set karo.',
      controller: matchRadiusController,
      initialRadius: controller.nearbyMatchesRadiusKm.value,
    );

    if (pickedRadius == null) {
      return;
    }

    await controller.loadNearbyMatches(radius: pickedRadius);
  }
}

class CreateMatchScreen extends StatefulWidget {
  final TurfModel? initialTurf;

  const CreateMatchScreen({
    super.key,
    this.initialTurf,
  });

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  late final MatchController controller;
  late final TeamController teamController;
  late final TurfController turfController;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final minPlayersController = TextEditingController(text: '2');
  final maxPlayersController = TextEditingController(text: '10');
  final descriptionController = TextEditingController();

  int sportIndex = 0;
  int formatIndex = 0;
  int skillIndex = 0;
  int feeModeIndex = 0;
  int? selectedTeamId;
  int? selectedTurfId;
  DateTime? selectedDate;
  final Set<int> selectedSlotIds = <int>{};

  static const sports = ['cricket', 'football', 'badminton'];
  static const formats = ['5v5', '8v8', '11v11'];
  static const levels = ['all', 'beginner', 'intermediate', 'advanced'];
  static const feeModes = ['split', 'host_pays'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());
    turfController = Get.isRegistered<TurfController>()
        ? Get.find<TurfController>()
        : Get.put(TurfController());
    final initialTurf = widget.initialTurf;
    if (initialTurf != null) {
      selectedTurfId = initialTurf.id;
      final turfSport = initialTurf.sportType.trim().toLowerCase();
      final initialSportIndex = sports.indexOf(turfSport);
      if (initialSportIndex >= 0) {
        sportIndex = initialSportIndex;
      }
    }
    selectedDate = DateTime.now();
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (teamController.teams.isEmpty && !teamController.isLoading.value) {
        await teamController.loadTeams();
      }
      if (turfController.turfs.isEmpty && !turfController.isLoading.value) {
        await turfController.loadNearbyTurfs();
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    minPlayersController.dispose();
    maxPlayersController.dispose();
    descriptionController.dispose();
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
            BackRow(label: 'Join Match', onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create a Match',
                          style: GoogleFonts.dmSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark)),
                      const SizedBox(height: 4),
                      Text(
                          'This form posts directly to the live create-match API.',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppColors.muted)),
                      const SizedBox(height: 20),
                      const SectionLabel('Sport'),
                      ChipRow(
                        const ['Cricket', 'Football', 'Badminton'],
                        initial: sportIndex,
                        onChanged: (value) => setState(() {
                          sportIndex = value;
                          selectedSlotIds.clear();
                          turfController.slots.clear();
                          final teams = _selectableTeams;
                          if (!teams.any((team) => team.id == selectedTeamId)) {
                            selectedTeamId = null;
                          }
                          final turfs = _selectableTurfs;
                          if (!turfs.any((turf) => turf.id == selectedTurfId)) {
                            selectedTurfId = null;
                          }
                        }),
                      ),
                      const SectionLabel('Match Title'),
                      _TextField(
                        controller: titleController,
                        hint: 'Friday Night Cricket',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Title is required'
                                : null,
                      ),
                      const SectionLabel('Turf'),
                      Obx(() {
                        final turfs = _selectableTurfs;
                        final isLoading = turfController.isLoading.value;
                        final hasItems = turfs.isNotEmpty;
                        final selectedName = _selectedTurfName(turfs);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: !hasItems || isLoading
                                  ? null
                                  : () => _openTurfPicker(turfs),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: hasItems
                                      ? AppColors.white
                                      : AppColors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedName ?? 'Select',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: selectedName == null
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                          color: selectedName == null
                                              ? AppColors.muted2
                                              : AppColors.dark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      LucideIcons.chevronDown,
                                      size: 18,
                                      color: AppColors.muted2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLoading &&
                                selectedTurfId == null &&
                                hasItems) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Please select a turf',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                            if (isLoading) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Loading nearby turfs...',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ] else if (!hasItems) ...[
                              const SizedBox(height: 8),
                              Text(
                                turfController.errorMessage.value.isNotEmpty
                                    ? turfController.errorMessage.value
                                    : 'No turf available right now.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.red,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              Text(
                                _selectedTurfSummary(turfs),
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                      const SectionLabel('Invite Team'),
                      Obx(() {
                        final teams = _selectableTeams;
                        final isLoading = teamController.isLoading.value;
                        final selectedName = _selectedTeamName(teams);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: isLoading || teams.isEmpty
                                  ? null
                                  : () => _openTeamPicker(teams),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: teams.isNotEmpty
                                      ? AppColors.white
                                      : AppColors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedName ?? 'Skip for now',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: selectedName == null
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                          color: selectedName == null
                                              ? AppColors.muted2
                                              : AppColors.dark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      LucideIcons.chevronDown,
                                      size: 18,
                                      color: AppColors.muted2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedTeamSummary(teams),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: teams.isEmpty && !isLoading
                                    ? AppColors.red
                                    : AppColors.muted,
                              ),
                            ),
                          ],
                        );
                      }),
                      Text(
                        'Date',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final date = DateTime.now().add(Duration(days: index));
                            final isSelected = _isSameDate(date, selectedDate);
                            return GestureDetector(
                              onTap: () => _selectDate(date),
                              child: Container(
                                width: 66,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.dark
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.dark
                                        : AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('E')
                                          .format(date)
                                          .toUpperCase(),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white70
                                            : AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd').format(date),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.dark,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      DateFormat('MMM').format(date),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white70
                                            : AppColors.muted2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Time Slots',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap one or more available slots to create the match.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        final slots = turfController.slots;
                        final isLoading = turfController.isSlotsLoading.value;
                        final error = turfController.slotsErrorMessage.value;

                        if (isLoading) {
                          return const _CreateMatchSlotsLoadingState();
                        }

                        if (error.isNotEmpty && slots.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              error,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.red,
                              ),
                            ),
                          );
                        }

                        if (selectedTurfId == null) {
                          return Text(
                            'Select a turf to see slots.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          );
                        }

                        if (slots.isEmpty) {
                          return Text(
                            'No slots available for this date.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: slots.map((slot) {
                                final isSelected =
                                    selectedSlotIds.contains(slot.id);
                                return GestureDetector(
                                  onTap: !slot.isAvailable
                                      ? null
                                      : () => setState(() {
                                          if (isSelected) {
                                            selectedSlotIds.remove(slot.id);
                                          } else {
                                            selectedSlotIds.add(slot.id);
                                          }
                                        }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !slot.isAvailable
                                          ? AppColors.bg
                                          : isSelected
                                              ? AppColors.dark
                                              : AppColors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.dark
                                            : AppColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot.label,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: !slot.isAvailable
                                                ? AppColors.muted2
                                                : isSelected
                                                    ? Colors.white
                                                    : AppColors.dark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          !slot.isAvailable
                                              ? 'Unavailable'
                                              : slot.price > 0
                                                  ? 'Rs ${_formatAmount(slot.price)}'
                                                  : 'Available',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 10,
                                            color: !slot.isAvailable
                                                ? AppColors.muted2
                                                : isSelected
                                                    ? Colors.white70
                                                    : AppColors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedSlotsSummary(slots),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        );
                      }),
                      const SectionLabel('Format'),
                      ChipRow(
                        const ['5v5', '8v8', '11v11'],
                        initial: formatIndex,
                        onChanged: (value) => setState(() => formatIndex = value),
                      ),
                      const SectionLabel('Skill Level'),
                      ChipRow(
                        const ['All', 'Beginner', 'Intermediate', 'Advanced'],
                        initial: skillIndex,
                        onChanged: (value) => setState(() => skillIndex = value),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel('Min Players'),
                                _TextField(
                                  controller: minPlayersController,
                                  hint: '6',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: _validatePositiveNumber,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel('Max Players'),
                                _TextField(
                                  controller: maxPlayersController,
                                  hint: '10',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: _validatePositiveNumber,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SectionLabel('Fee Mode'),
                      ChipRow(
                        const ['Split', 'Host Pays'],
                        initial: feeModeIndex,
                        onChanged: (value) => setState(() => feeModeIndex = value),
                      ),
                      const SectionLabel('Description'),
                      _TextField(
                        controller: descriptionController,
                        hint: 'Casual match, all levels welcome',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 18),
                      SmallCard(
                        child: Text(
                          'Create match now uses selected turf, date, slots, min players, max players, fee mode, and can also invite one team right after match creation.',
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.muted,
                              height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => AppButton(
                          label: controller.isCreateLoading.value
                              ? 'Creating...'
                              : 'Confirm Match',
                          trailingIcon: controller.isCreateLoading.value
                              ? null
                              : Icons.arrow_forward,
                          onTap:
                              controller.isCreateLoading.value ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(DateTime picked) async {
    setState(() {
      selectedDate = picked;
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      selectedSlotIds.clear();
    });
    await _loadSlotsIfPossible();
  }

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (dateController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a date.');
      return;
    }
    if (selectedTurfId == null) {
      Get.snackbar('Error', 'Please select a turf.');
      return;
    }
    if (selectedSlotIds.isEmpty) {
      Get.snackbar('Error', 'Please select at least one slot.');
      return;
    }
    final minPlayers = int.tryParse(minPlayersController.text.trim());
    final maxPlayers = int.tryParse(maxPlayersController.text.trim());
    if (minPlayers == null || maxPlayers == null || minPlayers > maxPlayers) {
      Get.snackbar('Error', 'Min players cannot be greater than max players.');
      return;
    }

    final payload = {
      'title': titleController.text.trim(),
      'sport': sports[sportIndex],
      'format': formats[formatIndex],
      'turf_id': selectedTurfId,
      'slot_ids': selectedSlotIds.toList()..sort(),
      'min_players': minPlayers,
      'max_players': maxPlayers,
      'fee_mode': feeModes[feeModeIndex],
      'skill_level': levels[skillIndex],
      'description': descriptionController.text.trim(),
    };

    final match = await controller.createMatch(
      payload,
      invitedTeamId: selectedTeamId,
    );
    if (match == null || !mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MatchDetailScreen(
          matchId: match.id,
          initiallyJoined: true,
        ),
      ),
    );
  }

  String? _validatePositiveNumber(String? value) {
    final number = int.tryParse(value ?? '');
    if (number == null || number <= 0) {
      return 'Enter valid count';
    }
    if (number < 2) {
      return 'Minimum 2 players required';
    }
    return null;
  }

  Future<void> _loadSlotsIfPossible() async {
    final turfId = selectedTurfId;
    final date = dateController.text.trim();
    if (turfId == null || date.isEmpty) {
      return;
    }
    await turfController.loadAvailableSlots(
      turfId: turfId,
      date: date,
    );
  }

  bool _isSameDate(DateTime a, DateTime? b) {
    if (b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatAmount(num value) {
    final amount = value.toDouble();
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  List<TurfModel> get _selectableTurfs {
    final activeSport = sports[sportIndex];
    final mergedTurfs = <TurfModel>[
      if (widget.initialTurf != null) widget.initialTurf!,
      ...turfController.turfs.where(
        (turf) => turf.id != widget.initialTurf?.id,
      ),
    ];
    final matchingTurfs = mergedTurfs
        .where((turf) => turf.sportType.toLowerCase() == activeSport)
        .toList();
    if (matchingTurfs.isNotEmpty) {
      return matchingTurfs;
    }
    return mergedTurfs;
  }

  List<TeamModel> get _selectableTeams {
    final activeSport = sports[sportIndex];
    final matchingTeams = teamController.teams
        .where((team) => team.sport.toLowerCase() == activeSport)
        .toList();
    if (matchingTeams.isNotEmpty) {
      return matchingTeams;
    }
    return teamController.teams.toList();
  }

  String? _selectedTeamName(List<TeamModel> teams) {
    for (final team in teams) {
      if (team.id == selectedTeamId) {
        return team.name;
      }
    }
    return null;
  }

  String? _selectedTurfName(List<TurfModel> turfs) {
    for (final turf in turfs) {
      if (turf.id == selectedTurfId) {
        return turf.name;
      }
    }
    return null;
  }

  String _selectedSlotsSummary(List<TurfSlotModel> slots) {
    if (selectedTurfId == null) {
      return 'Choose a turf to load slots.';
    }
    if (dateController.text.trim().isEmpty) {
      return 'Choose a date to load available slots.';
    }
    if (slots.isEmpty) {
      return 'No slots loaded yet.';
    }
    final selected = slots.where((slot) => selectedSlotIds.contains(slot.id)).toList();
    if (selected.isEmpty) {
      return '${slots.length} slots available.';
    }
    final total = selected.fold<num>(0, (sum, slot) => sum + slot.price);
    return '${selected.length} selected | Total Rs ${total.toStringAsFixed(total == total.roundToDouble() ? 0 : 2)}';
  }

  String _selectedTurfSummary(List<TurfModel> turfs) {
    TurfModel? selectedTurf;
    for (final turf in turfs) {
      if (turf.id == selectedTurfId) {
        selectedTurf = turf;
        break;
      }
    }
    if (selectedTurf == null) {
      return 'Select a turf for this match.';
    }

    final parts = <String>[
      if (selectedTurf.city.trim().isNotEmpty) selectedTurf.city,
      if (selectedTurf.address.trim().isNotEmpty) selectedTurf.address,
    ];
    if (parts.isEmpty) {
      return 'Turf selected';
    }
    return parts.join(' | ');
  }

  String _selectedTeamSummary(List<TeamModel> teams) {
    if (teamController.isLoading.value) {
      return 'Loading your teams...';
    }
    if (teams.isEmpty) {
      return 'No teams available to invite yet. You can still create the match without inviting a team.';
    }

    TeamModel? selectedTeam;
    for (final team in teams) {
      if (team.id == selectedTeamId) {
        selectedTeam = team;
        break;
      }
    }
    if (selectedTeam == null) {
      return 'Optional: pick one team to send an invite right after match creation.';
    }

    final parts = <String>[
      if (selectedTeam.sport.trim().isNotEmpty) _capitalize(selectedTeam.sport),
      if (selectedTeam.city.trim().isNotEmpty) selectedTeam.city,
      '${selectedTeam.playerCount} players',
    ];
    return parts.join(' | ');
  }

  Future<void> _openTurfPicker(List<TurfModel> turfs) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Turf',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a turf for this match.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: turfs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final turf = turfs[index];
                        final isSelected = turf.id == selectedTurfId;
                        final locationParts = <String>[
                          if (turf.city.trim().isNotEmpty) turf.city,
                          if (turf.address.trim().isNotEmpty) turf.address,
                        ];

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).pop(turf.id),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.green.withOpacity(0.08)
                                  : AppColors.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        turf.name,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      if (locationParts.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          locationParts.join(' | '),
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            color: AppColors.muted,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppColors.green
                                      : AppColors.muted2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      selectedTurfId = picked;
      selectedSlotIds.clear();
    });
    await _loadSlotsIfPossible();
  }

  Future<void> _openTeamPicker(List<TeamModel> teams) async {
    final picked = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Invite Team',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select one team to invite after the match is created.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Skip invitation',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    subtitle: Text(
                      'Create the match without sending a team invite.',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    trailing: Icon(
                      selectedTeamId == null
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selectedTeamId == null
                          ? AppColors.green
                          : AppColors.muted2,
                    ),
                    onTap: () => Navigator.of(context).pop(-1),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: teams.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final isSelected = team.id == selectedTeamId;

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).pop(team.id),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.green.withOpacity(0.08)
                                  : AppColors.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        team.name,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        [
                                          _capitalize(team.sport),
                                          team.city,
                                          '${team.playerCount} players',
                                        ].where((part) => part.trim().isNotEmpty).join(' | '),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppColors.green
                                      : AppColors.muted2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      selectedTeamId = picked <= 0 ? null : picked;
    });
  }
}

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  final bool initiallyJoined;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    this.initiallyJoined = false,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late final MatchController controller;
  final nearbyPlayersRadiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    nearbyPlayersRadiusController.text =
        controller.nearbyPlayersRadiusKm.value.toString();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.loadMatchDetail(widget.matchId));
  }

  @override
  void dispose() {
    nearbyPlayersRadiusController.dispose();
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
            BackRow(label: 'Matches', onBack: () => Navigator.pop(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Obx(() {
                  final match = controller.selectedMatch.value;
                  if (controller.isDetailLoading.value && match == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (match == null) {
                    return const _EmptyState(
                      title: 'Match details unavailable',
                      subtitle:
                          'The detail API did not return a usable match payload.',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.green,
                    onRefresh: () => controller.loadMatchDetail(widget.matchId),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
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
                              AppBadge(match.status.toUpperCase(),
                                  type: match.isFull
                                      ? BadgeType.red
                                      : BadgeType.amber),
                              const SizedBox(height: 14),
                              Text(match.title,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              const SizedBox(height: 8),
                              Text(_scheduleText(match),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.78),
                                      height: 1.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Match Overview',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.dark)),
                              const SizedBox(height: 12),
                              InfoRow(
                                  label: 'Sport',
                                  value: _capitalize(match.sport)),
                              InfoRow(label: 'Format', value: match.format),
                              InfoRow(label: 'Turf', value: match.turfName),
                              InfoRow(label: 'City', value: match.city),
                              if (match.venueAddress.trim().isNotEmpty)
                                InfoRow(
                                  label: 'Venue',
                                  value: match.venueAddress,
                                ),
                              if (match.creatorName.trim().isNotEmpty)
                                InfoRow(
                                  label: 'Creator',
                                  value: match.creatorName,
                                ),
                              InfoRow(
                                  label: 'Skill level',
                                  value: _capitalize(match.skillLevel)),
                              if (match.minPlayers > 0)
                                InfoRow(
                                  label: 'Min players',
                                  value: '${match.minPlayers}',
                                ),
                              InfoRow(
                                  label: 'Fee per player',
                                  value: 'Rs ${match.feePerPlayer}'),
                              if (match.estimatedFee > 0)
                                InfoRow(
                                  label: 'Estimated fee',
                                  value: 'Rs ${match.estimatedFee}',
                                ),
                              if (match.slotTotalCost > 0)
                                InfoRow(
                                  label: 'Slot cost',
                                  value: 'Rs ${match.slotTotalCost}',
                                ),
                              InfoRow(
                                label: 'Fee mode',
                                value: _capitalize(match.feeMode.replaceAll('_', ' ')),
                              ),
                              if (match.inviteCode.trim().isNotEmpty)
                                InfoRow(
                                  label: 'Invite code',
                                  value: match.inviteCode,
                                ),
                              InfoRow(
                                  label: 'Slots left',
                                  value:
                                      '${match.slotsLeft}/${match.maxPlayers}'),
                              const SizedBox(height: 8),
                              AppProgress(match.fillProgress),
                              if (match.description.trim().isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(match.description,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                        height: 1.6)),
                              ],
                            ],
                          ),
                        ),
                        if (match.isCreator) ...[
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Creator Actions',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.dark)),
                                const SizedBox(height: 8),
                                Text(
                                  'Share match invitations, invite nearby players, or finalize the match once teams are locked.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AppButton(
                                  label: controller.isInviteLinkLoading.value
                                      ? 'Preparing Link...'
                                      : 'Share Invite Link',
                                  isOutline: true,
                                  onTap: controller.isInviteLinkLoading.value
                                      ? null
                                      : () => _shareInviteLink(match.id),
                                ),
                                const SizedBox(height: 10),
                                AppButton(
                                  label: controller.isInvitePlayersLoading.value
                                      ? 'Loading Players...'
                                      : 'Invite Nearby Players',
                                  isOutline: true,
                                  onTap: controller.isInvitePlayersLoading.value
                                      ? null
                                      : () => _openInvitePlayersSheet(match.id),
                                ),
                                const SizedBox(height: 10),
                                AppButton(
                                  label: controller.isFinalizeLoading.value
                                      ? 'Finalizing...'
                                      : match.canFinalize
                                          ? 'Finalize Match'
                                          : 'Finalize Unavailable',
                                  color: AppColors.dark,
                                  onTap: controller.isFinalizeLoading.value ||
                                          !match.canFinalize
                                      ? null
                                      : () => _finalizeMatch(match.id),
                                ),
                                if (!match.canFinalize) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Finalize will unlock once match rules are satisfied.',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        if (match.players.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Players',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.dark)),
                                const SizedBox(height: 12),
                                ...match.players.map(
                                  (player) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        _PlayerBubble(
                                          filled: true,
                                          label: player.initials,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                player.name,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.dark,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                [
                                                  if (player.status.trim().isNotEmpty)
                                                    _capitalize(player.status),
                                                  if (player.paymentStatus
                                                      .trim()
                                                      .isNotEmpty)
                                                    _capitalize(
                                                      player.paymentStatus,
                                                    ),
                                                  if (player.feePaid > 0)
                                                    'Paid Rs ${player.feePaid}',
                                                ].join(' | '),
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 10.5,
                                                  color: AppColors.muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (player.isCreator)
                                          const AppBadge('Creator')
                                        else if (match.isCreator)
                                          TextButton(
                                            onPressed: () => controller
                                                .removePlayerFromMatch(
                                              matchId: match.id,
                                              playerId: player.id,
                                            ),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Obx(() {
                          final isJoined =
                              match.hasJoined ||
                              controller.isMatchJoined(
                                widget.matchId,
                                fallback: widget.initiallyJoined,
                              );
                          return AppButton(
                            label: controller.isJoinLoading.value
                                ? 'Updating...'
                                : isJoined
                                    ? 'Leave Match'
                                    : 'Join Match',
                            color: isJoined ? AppColors.red : AppColors.dark,
                            trailingIcon: controller.isJoinLoading.value
                                ? null
                                : Icons.arrow_forward,
                            onTap: controller.isJoinLoading.value
                                ? null
                                : () async {
                                    final success = isJoined
                                        ? await controller.leaveMatch(match.id)
                                        : await controller.joinMatch(match.id);
                                    if (success) {
                                      await controller.loadMyMatches();
                                    }
                                  },
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _scheduleText(MatchModel match) {
    final date = _formatMatchDate(match.date);
    final start = match.timeStart.isEmpty ? '--:--' : match.timeStart;
    final end = match.timeEnd.isEmpty ? '--:--' : match.timeEnd;
    return '$date  $start - $end  ${match.city}';
  }

  String _formatMatchDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'Date TBD';
    }

    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      return normalized;
    }

    return DateFormat('dd MMM yyyy').format(parsed);
  }

  Future<void> _shareInviteLink(int matchId) async {
    final invite = await controller.loadMatchInviteLink(matchId);
    if (invite == null) {
      Get.snackbar('Error', 'Invite link could not be loaded.');
      return;
    }

    final message = [
      if (invite.shareMessage.trim().isNotEmpty) invite.shareMessage.trim(),
      if (invite.shareMessage.trim().isEmpty && invite.code.trim().isNotEmpty)
        'Join this match with code: ${invite.code.trim()}',
      if (invite.inviteLink.trim().isNotEmpty) invite.inviteLink.trim(),
    ].join('\n\n');

    await SharePlus.instance.share(
      ShareParams(
        text: message.isNotEmpty ? message : invite.inviteLink,
        subject: 'Join this Turf11 match',
      ),
    );
  }

  Future<void> _openInvitePlayersSheet(int matchId) async {
    await controller.loadNearbyPlayers();
    if (!mounted) {
      return;
    }

    final selectedIds = <int>{};

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Obx(() {
                    final players = controller.nearbyPlayers;
                    final isLoading = controller.isNearbyPlayersLoading.value;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Invite Nearby Players',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select players and send them an in-app invite for this match.',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            nearbyPlayersRadiusController.text = controller
                                .nearbyPlayersRadiusKm.value
                                .toString();
                            final pickedRadius = await _showRadiusPickerSheet(
                              title: 'Nearby Players Radius',
                              subtitle:
                                  'Invite nearby players ke liye radius set karo.',
                              controller: nearbyPlayersRadiusController,
                              initialRadius:
                                  controller.nearbyPlayersRadiusKm.value,
                            );
                            if (pickedRadius == null) {
                              return;
                            }
                            await controller.loadNearbyPlayers(
                              radius: pickedRadius,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.mapPin,
                                  size: 14,
                                  color: AppColors.dark,
                                ),
                                const SizedBox(width: 8),
                                Obx(() {
                                  return Text(
                                    'Radius ${controller.nearbyPlayersRadiusKm.value} km',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 320,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : players.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No nearby players found right now.',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: players.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final player = players[index];
                                        final isSelected =
                                            selectedIds.contains(player.id);

                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          onTap: player.id <= 0
                                              ? null
                                              : () => setSheetState(() {
                                                    if (isSelected) {
                                                      selectedIds.remove(
                                                        player.id,
                                                      );
                                                    } else {
                                                      selectedIds.add(player.id);
                                                    }
                                                  }),
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.green
                                                      .withOpacity(0.08)
                                                  : AppColors.bg,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.green
                                                    : AppColors.border,
                                                width: isSelected ? 1.5 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                _PlayerBubble(
                                                  filled: true,
                                                  label: player.initials,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        player.name,
                                                        style:
                                                            GoogleFonts.dmSans(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              AppColors.dark,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        [
                                                          if (player.city
                                                              .trim()
                                                              .isNotEmpty)
                                                            player.city.trim(),
                                                          if (player.sport
                                                              .trim()
                                                              .isNotEmpty)
                                                            _capitalize(
                                                              player.sport,
                                                            ),
                                                          if (player.phone
                                                              .trim()
                                                              .isNotEmpty)
                                                            player.phone.trim(),
                                                        ].join(' | '),
                                                        style:
                                                            GoogleFonts.dmSans(
                                                          fontSize: 11,
                                                          color:
                                                              AppColors.muted,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  isSelected
                                                      ? Icons.check_circle
                                                      : Icons
                                                          .radio_button_unchecked,
                                                  color: isSelected
                                                      ? AppColors.green
                                                      : AppColors.muted2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => AppButton(
                            label: controller.isInvitePlayersLoading.value
                                ? 'Sending Invites...'
                                : 'Invite Selected',
                            onTap: controller.isInvitePlayersLoading.value
                                ? null
                                : () async {
                                    if (selectedIds.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Please select at least one player.',
                                      );
                                      return;
                                    }
                                    final success =
                                        await controller.invitePlayersToMatch(
                                      matchId: matchId,
                                      playerIds: selectedIds.toList(),
                                    );
                                    if (success && sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                    }
                                  },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _finalizeMatch(int matchId) async {
    final shouldFinalize = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalize Match'),
          content: const Text(
            'This will lock the match state for players. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Finalize'),
            ),
          ],
        );
      },
    );

    if (shouldFinalize != true) {
      return;
    }

    await controller.finalizeMatch(matchId);
  }
}

Future<int?> _showRadiusPickerSheet({
  required String title,
  required String subtitle,
  required TextEditingController controller,
  required int initialRadius,
}) async {
  return showModalBottomSheet<int>(
    context: Get.context!,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final quickOptions = <int>[5, 10, 20, 30, 50];
      return StatefulBuilder(
        builder: (context, setModalState) {
          final selectedRadius =
              int.tryParse(controller.text.trim()) ?? initialRadius;
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20 + MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickOptions.map((option) {
                        final isSelected = selectedRadius == option;
                        return InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () {
                            controller.text = option.toString();
                            setModalState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.green.withOpacity(0.08)
                                  : AppColors.bg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              '$option km',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.dark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Enter radius in km',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Apply Radius',
                      onTap: () {
                        final value = int.tryParse(controller.text.trim());
                        if (value == null || value <= 0) {
                          Get.snackbar(
                            'Error',
                            'Please enter a valid radius in km.',
                          );
                          return;
                        }
                        Navigator.of(sheetContext).pop(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final String actionLabel;
  final String? secondaryActionLabel;
  final VoidCallback onTap;
  final VoidCallback onAction;
  final VoidCallback? onSecondaryAction;

  const _MatchCard({
    required this.match,
    required this.actionLabel,
    this.secondaryActionLabel,
    required this.onTap,
    required this.onAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subText(),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: _actionColor(),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(
                      actionLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_displayPlayerLabels.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._displayPlayerLabels.map(
                    (label) => _PlayerBubble(
                      filled: true,
                      label: label,
                    ),
                  ),
                  if (_remainingPlayersCount > 0)
                    _PlayerBubble(
                      filled: false,
                      label: '+$_remainingPlayersCount',
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: match.fillProgress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.green,
                  ),
                ),
              ),
            ),
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onSecondaryAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      secondaryActionLabel!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<MatchPlayerModel> get _visiblePlayers {
    return match.activePlayers.take(5).toList();
  }

  List<String> get _displayPlayerLabels {
    return _visiblePlayers.map((player) => player.initials).toList();
  }

  int get _remainingPlayersCount {
    final totalPlayers = match.activePlayers.length;
    final remaining = totalPlayers - _displayPlayerLabels.length;
    return remaining < 0 ? 0 : remaining;
  }

  String _subText() {
    final dateLabel = _relativeDate(match.date);
    final timeLabel = _timeLabel();
    final slotsLabel = match.isFull ? 'Full' : '${match.slotsLeft} slots left';
    final parts = <String>[
      if (dateLabel.isNotEmpty) dateLabel,
      if (timeLabel.isNotEmpty) timeLabel,
      if (match.turfName.trim().isNotEmpty && match.turfName.trim() != '-')
        match.turfName.trim(),
      if (match.city.trim().isNotEmpty) match.city.trim(),
      slotsLabel,
      if (match.inviteCode.trim().isNotEmpty) match.inviteCode.trim(),
    ];
    if (parts.isEmpty) {
      return slotsLabel;
    }
    return parts.join(' | ');
  }

  String _timeLabel() {
    final rawStart = match.timeStart.trim();
    if (rawStart.isEmpty) {
      return '';
    }
    if (rawStart.contains('-') || rawStart.contains('–')) {
      return rawStart;
    }
    if (match.timeEnd.trim().isNotEmpty) {
      return '${_displayTime(rawStart)}-${_displayTime(match.timeEnd)}';
    }
    return _displayTime(rawStart);
  }

  Color _actionColor() {
    return AppColors.green;
  }

  String _relativeDate(String raw) {
    final parsed = _parseDate(raw.trim());
    if (parsed == null) {
      return raw.trim();
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) {
      return 'Today';
    }
    if (diff == 1) {
      return 'Tomorrow';
    }
    return DateFormat('dd MMM').format(parsed);
  }

  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) {
      return null;
    }
    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      return direct;
    }
    for (final pattern in const ['MMM d, yyyy', 'MMM dd, yyyy', 'dd MMM yyyy']) {
      try {
        return DateFormat(pattern).parseStrict(raw);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  String _displayTime(String raw) {
    final normalized = raw.trim();
    for (final pattern in const ['HH:mm:ss', 'HH:mm', 'H:mm']) {
      try {
        final parsed = DateFormat(pattern).parseStrict(normalized);
        return DateFormat('h a').format(parsed);
      } catch (_) {
        continue;
      }
    }
    return normalized;
  }
}

class _PlayerBubble extends StatelessWidget {
  final bool filled;
  final String label;

  const _PlayerBubble({
    required this.filled,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: filled ? AppColors.greenLt : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? AppColors.green : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
            color: filled ? AppColors.green : AppColors.muted2,
          ),
        ),
      ),
    );
  }
}

class _CreateMatchSlotsLoadingState extends StatelessWidget {
  const _CreateMatchSlotsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        6,
        (_) => const ShimmerBox(
          width: 110,
          height: 54,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _TextField({
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;

  const _ReadOnlyField({
    required this.controller,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: const Icon(LucideIcons.chevronRight,
            size: 16, color: AppColors.muted2),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.greenLt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(LucideIcons.calendarDays,
                  color: AppColors.green, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.muted, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

String _capitalize(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return '';
  }
  return normalized[0].toUpperCase() + normalized.substring(1);
}
