import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/match_controller.dart';
import '../data/models/match_model.dart';
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
            BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
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
                              return _MatchCard(
                                match: match,
                                actionLabel: selectedTab == 0
                                    ? 'Join Match'
                                    : 'View Details',
                                onTap: () => _openDetail(
                                      context,
                                      match.id,
                                      isJoined: selectedTab == 1,
                                    ),
                                onAction: () async {
                                  if (selectedTab == 0) {
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
                                    isJoined: true,
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

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final cityController = TextEditingController(text: 'Gurugram');
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final maxPlayersController = TextEditingController(text: '10');
  final feeController = TextEditingController(text: '200');
  final descriptionController = TextEditingController();

  int sportIndex = 0;
  int formatIndex = 0;
  int skillIndex = 0;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  static const sports = ['cricket', 'football', 'badminton'];
  static const formats = ['5v5', '8v8', '11v11'];
  static const levels = ['all', 'beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
  }

  @override
  void dispose() {
    titleController.dispose();
    cityController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    maxPlayersController.dispose();
    feeController.dispose();
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
            BackRow(label: 'Home', onBack: () => Navigator.pop(context)),
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
                        onChanged: (value) => sportIndex = value,
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
                      const SectionLabel('City'),
                      _TextField(
                        controller: cityController,
                        hint: 'Gurugram',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'City is required'
                                : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel('Date'),
                                _ReadOnlyField(
                                  controller: dateController,
                                  hint: '2026-04-20',
                                  onTap: _pickDate,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel('Start Time'),
                                _ReadOnlyField(
                                  controller: startTimeController,
                                  hint: '18:00',
                                  onTap: () => _pickTime(isStart: true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('End Time'),
                      _ReadOnlyField(
                        controller: endTimeController,
                        hint: '20:00',
                        onTap: () => _pickTime(isStart: false),
                      ),
                      const SectionLabel('Format'),
                      ChipRow(
                        const ['5v5', '8v8', '11v11'],
                        initial: formatIndex,
                        onChanged: (value) => formatIndex = value,
                      ),
                      const SectionLabel('Skill Level'),
                      ChipRow(
                        const ['All', 'Beginner', 'Intermediate', 'Advanced'],
                        initial: skillIndex,
                        onChanged: (value) => skillIndex = value,
                      ),
                      Row(
                        children: [
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel('Fee / Player'),
                                _TextField(
                                  controller: feeController,
                                  hint: '200',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: _validateNonNegativeNumber,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          'Nearby list now uses device GPS when permission is available. If location is denied or unavailable, the app falls back to default coordinates.',
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
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTime ?? const TimeOfDay(hour: 18, minute: 0))
          : (endTime ?? const TimeOfDay(hour: 20, minute: 0)),
    );

    if (picked == null) {
      return;
    }

    final date = DateTime(2026, 1, 1, picked.hour, picked.minute);
    final value = DateFormat('HH:mm').format(date);

    setState(() {
      if (isStart) {
        startTime = picked;
        startTimeController.text = value;
      } else {
        endTime = picked;
        endTimeController.text = value;
      }
    });
  }

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (dateController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty) {
      Get.snackbar('Error', 'Date, start time and end time are required.');
      return;
    }

    final payload = {
      'title': titleController.text.trim(),
      'sport': sports[sportIndex],
      'format': formats[formatIndex],
      'city': cityController.text.trim(),
      'date': dateController.text.trim(),
      'time_start': startTimeController.text.trim(),
      'time_end': endTimeController.text.trim(),
      'max_players': int.parse(maxPlayersController.text.trim()),
      'fee_per_player': int.parse(feeController.text.trim()),
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

  String? _validateNonNegativeNumber(String? value) {
    final number = int.tryParse(value ?? '');
    if (number == null || number < 0) {
      return 'Enter valid fee';
    }
    return null;
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
  late bool isJoined;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    isJoined = controller.isMatchJoined(
      widget.matchId,
      fallback: widget.initiallyJoined,
    );
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
                        Obx(
                          () => AppButton(
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
                                      final nextJoinedState = !isJoined;
                                      controller.setMatchJoinedState(
                                        match.id,
                                        nextJoinedState,
                                      );
                                      setState(() {
                                        isJoined = nextJoinedState;
                                      });
                                      await controller.loadMyMatches();
                                    }
                                  },
                          ),
                        ),
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
      child: AppCard(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(match.title,
                          style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 10, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                                '${match.city}  ${match.date}  ${match.timeStart}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 10, color: AppColors.muted)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppBadge(
                    match.isFull ? 'Full' : '${match.slotsLeft} slots left',
                    type: match.isFull ? BadgeType.red : BadgeType.green),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                AppBadge(_capitalize(match.sport), type: BadgeType.amber),
                const SizedBox(width: 6),
                AppBadge(match.format, type: BadgeType.dark),
                const SizedBox(width: 6),
                AppBadge(_capitalize(match.skillLevel), type: BadgeType.green),
              ],
            ),
            const SizedBox(height: 12),
            AppProgress(match.fillProgress),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Rs ${match.feePerPlayer} ',
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
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(actionLabel,
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
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
