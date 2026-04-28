import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/match_controller.dart';
import '../controllers/turf_controller.dart';
import '../data/models/match_model.dart';
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
  late int selectedTab;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    selectedTab = widget.initialTabIndex;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.refreshAll());
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
                              ? 'Showing nearby matches using fallback coordinates because device location is unavailable.'
                              : 'Live matches from the API near your current location.'
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
}

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  late final MatchController controller;
  late final TurfController turfController;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final minPlayersController = TextEditingController(text: '6');
  final maxPlayersController = TextEditingController(text: '10');
  final descriptionController = TextEditingController();

  int sportIndex = 0;
  int formatIndex = 0;
  int skillIndex = 0;
  int feeModeIndex = 0;
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
    turfController = Get.isRegistered<TurfController>()
        ? Get.find<TurfController>()
        : Get.put(TurfController());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
                      const SectionLabel('Date'),
                      _ReadOnlyField(
                        controller: dateController,
                        hint: '2026-04-28',
                        onTap: _pickDate,
                      ),
                      const SectionLabel('Slots'),
                      Obx(() {
                        final slots = turfController.slots;
                        final isLoading = turfController.isSlotsLoading.value;
                        final error = turfController.slotsErrorMessage.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: isLoading ? null : _openSlotPicker,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedSlotsLabel(slots),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: selectedSlotIds.isEmpty
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                          color: selectedSlotIds.isEmpty
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
                            if (isLoading) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Loading available slots...',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ] else if (error.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                error,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.red,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              Text(
                                _selectedSlotsSummary(slots),
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
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
                          'Create match now uses selected turf, date, slots, min players, max players, and fee mode.',
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

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

    final match = await controller.createMatch(payload);
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

  List<TurfModel> get _selectableTurfs {
    final activeSport = sports[sportIndex];
    final matchingTurfs = turfController.turfs
        .where((turf) => turf.sportType.toLowerCase() == activeSport)
        .toList();
    if (matchingTurfs.isNotEmpty) {
      return matchingTurfs;
    }
    return turfController.turfs.toList();
  }

  String? _selectedTurfName(List<TurfModel> turfs) {
    for (final turf in turfs) {
      if (turf.id == selectedTurfId) {
        return turf.name;
      }
    }
    return null;
  }

  String _selectedSlotsLabel(List<TurfSlotModel> slots) {
    if (selectedTurfId == null) {
      return 'Select turf first';
    }
    if (dateController.text.trim().isEmpty) {
      return 'Select date first';
    }
    if (selectedSlotIds.isEmpty) {
      return slots.isEmpty ? 'Select slots' : 'Choose slots';
    }
    return '${selectedSlotIds.length} slot${selectedSlotIds.length == 1 ? '' : 's'} selected';
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

  Future<void> _openSlotPicker() async {
    if (selectedTurfId == null) {
      Get.snackbar('Error', 'Please select a turf first.');
      return;
    }
    if (dateController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please select a date first.');
      return;
    }

    if (turfController.slots.isEmpty && !turfController.isSlotsLoading.value) {
      await _loadSlotsIfPossible();
    }

    if (!mounted) {
      return;
    }

    final workingSelection = selectedSlotIds.toSet();

    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final slots = turfController.slots;

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
                        'Select Slots',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateController.text.trim(),
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: turfController.isSlotsLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : slots.isEmpty
                                ? Center(
                                    child: Text(
                                      'No slots available.',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: slots.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final slot = slots[index];
                                      final isSelected =
                                          workingSelection.contains(slot.id);

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: !slot.isAvailable
                                            ? null
                                            : () {
                                                setSheetState(() {
                                                  if (isSelected) {
                                                    workingSelection.remove(slot.id);
                                                  } else {
                                                    workingSelection.add(slot.id);
                                                  }
                                                });
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.green.withOpacity(0.08)
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
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      slot.label,
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors.dark,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Rs ${slot.price}',
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: 11,
                                                        color: AppColors.muted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                isSelected
                                                    ? Icons.check_circle
                                                    : Icons.radio_button_unchecked,
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
                      AppButton(
                        label: 'Apply Slots',
                        onTap: () => Navigator.of(context).pop(workingSelection),
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

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      selectedSlotIds
        ..clear()
        ..addAll(picked);
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

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.loadMatchDetail(widget.matchId));
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
                              InfoRow(label: 'City', value: match.city),
                              InfoRow(
                                  label: 'Skill level',
                                  value: _capitalize(match.skillLevel)),
                              InfoRow(
                                  label: 'Fee per player',
                                  value: 'Rs ${match.feePerPlayer}'),
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
                        Obx(() {
                          final isJoined = controller.isMatchJoined(
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
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final String actionLabel;
  final VoidCallback onTap;
  final VoidCallback onAction;

  const _MatchCard({
    required this.match,
    required this.actionLabel,
    required this.onTap,
    required this.onAction,
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                _visibleBubbleCount,
                (index) => _PlayerBubble(
                  filled: index < match.joinedPlayers,
                  label: index < match.joinedPlayers
                      ? _playerInitials(index)
                      : '+',
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }

  int get _visibleBubbleCount {
    if (match.maxPlayers <= 0) {
      return 8;
    }
    return match.maxPlayers > 8 ? 8 : match.maxPlayers;
  }

  String _subText() {
    final dateLabel = _relativeDate(match.date);
    final timeLabel = _timeLabel();
    final slotsLabel = match.isFull ? 'Full' : '${match.slotsLeft} slots left';
    final parts = <String>[
      dateLabel,
      timeLabel,
      if (match.city.trim().isNotEmpty) match.city.trim(),
      slotsLabel,
    ];
    if (parts.isEmpty) {
      return slotsLabel;
    }
    return parts.join(' · ');
  }

  String _timeLabel() {
    final rawStart = match.timeStart.trim();
    if (rawStart.isEmpty) {
      return '--:--';
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
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) {
      return raw.trim().isEmpty ? 'Today' : raw.trim();
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

  String _playerInitials(int index) {
    const pool = ['RS', 'AK', 'MV', 'SK', 'PJ', 'RT', 'NK', 'AD'];
    return pool[index % pool.length];
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
