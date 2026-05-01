import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

const double kAppButtonHeight = 44;
const double kAppCompactButtonHeight = 34;
const double kAppButtonHorizontalPadding = 14;
const double kAppButtonVerticalPadding = 7;
const double kAppButtonFontSize = 11;
const double kAppButtonIconSize = 14;
const double kAppButtonTrailingSize = 24;
const double kScreenHorizontalPadding = 20;
const double kScreenTopSpacing = 8;
const double kScreenTitleGap = 4;
const double kScreenSectionSpacing = 12;
const double kScreenBlockSpacing = 16;
const double kScreenBottomSpacing = 30;
const double kScreenListBottomPadding = 90;

class AppLogo extends StatelessWidget {
  final double width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width = 180,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_icon.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

// ─── PRIMARY BUTTON ───────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool isOutline;
  final IconData? trailingIcon;
  final bool compact;
  final bool large;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.isOutline = false,
    this.trailingIcon,
    this.compact = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.dark;
    final buttonHeight = large || compact ? null : kAppButtonHeight;
    final minimumHeight = large || compact ? 0.0 : kAppButtonHeight;
    final verticalPadding = large ? 16.0 : kAppButtonVerticalPadding;
    final fontSize = large ? 14.0 : kAppButtonFontSize;
    final trailingSize = large ? 38.0 : kAppButtonTrailingSize;
    final iconSize = large ? 18.0 : kAppButtonIconSize;
    final buttonPadding = large || compact
        ? EdgeInsets.symmetric(vertical: verticalPadding)
        : const EdgeInsets.symmetric(horizontal: kAppButtonHorizontalPadding);
    final tapTargetSize =
        compact ? MaterialTapTargetSize.shrinkWrap : null;
    if (isOutline) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bg, width: 1.5),
            shape: const StadiumBorder(),
            minimumSize: Size(0, minimumHeight),
            padding: buttonPadding,
            alignment: Alignment.center,
            tapTargetSize: tapTargetSize,
          ),
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: large ? 13 : fontSize,
                  fontWeight: FontWeight.w600,
                  color: bg)),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          minimumSize: Size(0, minimumHeight),
          padding: buttonPadding,
          alignment: Alignment.center,
          tapTargetSize: tapTargetSize,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: trailingIcon != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (trailingIcon != null)
              SizedBox(width: trailingSize),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            if (trailingIcon != null)
              Container(
                width: trailingSize,
                height: trailingSize,
                decoration: const BoxDecoration(
                    color: AppColors.green, shape: BoxShape.circle),
                child: Icon(
                  trailingIcon,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── BACK ROW ─────────────────────────────────────────────────────────────────
class BackRow extends StatelessWidget {
  final String label;
  final VoidCallback? onBack;
  final bool showBackArrow;
  const BackRow({
    super.key,
    required this.label,
    this.onBack,
    this.showBackArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          if (showBackArrow) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.09),
                        blurRadius: 16,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 16,
                  color: AppColors.dark,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

// ─── SECTION LABEL ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kScreenBlockSpacing, bottom: 8),
      child: Text(text.toUpperCase(),
          style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.9)),
    );
  }
}

// ─── BADGE ────────────────────────────────────────────────────────────────────
enum BadgeType { green, dark, amber, red }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  const AppBadge(this.label, {super.key, this.type = BadgeType.green});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (type) {
      case BadgeType.green:
        bg = AppColors.greenLt;
        fg = AppColors.green;
        break;
      case BadgeType.dark:
        bg = AppColors.dark;
        fg = Colors.white;
        break;
      case BadgeType.amber:
        bg = AppColors.amberLt;
        fg = AppColors.amber;
        break;
      case BadgeType.red:
        bg = AppColors.redLt;
        fg = AppColors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ─── CHIP ROW ─────────────────────────────────────────────────────────────────
class ChipRow extends StatefulWidget {
  final List<String> options;
  final int initial;
  final ValueChanged<int>? onChanged;
  final bool equalWidth;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double height;
  const ChipRow(
    this.options, {
    super.key,
    this.initial = 0,
    this.onChanged,
    this.equalWidth = false,
    this.spacing = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize = 12,
    this.height = kAppButtonHeight,
  });

  @override
  State<ChipRow> createState() => _ChipRowState();
}

class _ChipRowState extends State<ChipRow> {
  late int _sel;

  @override
  void initState() {
    super.initState();
    _sel = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final chips = List.generate(widget.options.length, (i) {
      final on = i == _sel;
      final chip = GestureDetector(
        onTap: () {
          setState(() => _sel = i);
          widget.onChanged?.call(i);
        },
        child: Container(
          width: double.infinity,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: on ? AppColors.dark : AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: on ? AppColors.dark : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.options[i],
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w500,
                color: on ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        ),
      );

      if (!widget.equalWidth) {
        return chip;
      }

      return Expanded(child: chip);
    });

    if (widget.equalWidth) {
      return Row(
        children: List.generate(chips.length * 2 - 1, (index) {
          if (index.isOdd) {
            return SizedBox(width: widget.spacing);
          }
          return chips[index ~/ 2];
        }),
      );
    }

    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      children: chips,
    );
  }
}

// ─── TOGGLE ROW ───────────────────────────────────────────────────────────────
class ToggleRow extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool initial;
  const ToggleRow(this.title, {super.key, this.subtitle, this.initial = false});

  @override
  State<ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<ToggleRow> {
  late bool _on;

  @override
  void initState() {
    super.initState();
    _on = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark)),
              if (widget.subtitle != null)
                Text(widget.subtitle!,
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.muted)),
            ]),
          ),
          Switch(
            value: _on,
            onChanged: (v) => setState(() => _on = v),
            activeColor: AppColors.green,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// ─── CARD CONTAINER ───────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double radius;
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 16,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

// ─── SMALL CARD ───────────────────────────────────────────────────────────────
class SmallCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const SmallCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 1))
        ],
      ),
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: -1.0, end: 2.0),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeInOut,
        onEnd: () {},
        builder: (context, value, _) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(value - 1, 0),
                end: Alignment(value, 0),
                colors: const [
                  Color(0xFFE9EDF0),
                  Color(0xFFF7F8FA),
                  Color(0xFFE9EDF0),
                ],
                stops: const [0.15, 0.5, 0.85],
              ).createShader(bounds);
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDF0),
                shape: shape,
                borderRadius:
                    shape == BoxShape.circle
                        ? null
                        : (borderRadius ?? BorderRadius.circular(12)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── DIVIDER ──────────────────────────────────────────────────────────────────
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppColors.border, height: 24, thickness: 1);
  }
}

// ─── SEARCH BAR ───────────────────────────────────────────────────────────────
class SearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchBar({
    super.key,
    this.hint = 'Search...',
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 16,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.search, size: 16, color: AppColors.muted2),
            const SizedBox(width: 10),
            Expanded(
              child: readOnly
                  ? Text(hint,
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.muted2))
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dark),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AVATAR ───────────────────────────────────────────────────────────────────
class AppAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color bg;
  final Color fg;
  final Color? borderColor;
  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.bg = AppColors.greenLt,
    this.fg = AppColors.green,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
      ),
      child: Center(
        child: Text(initials,
            style: GoogleFonts.dmSans(
                fontSize: size * 0.32,
                fontWeight: FontWeight.w800,
                color: fg)),
      ),
    );
  }
}

// ─── PROGRESS BAR ─────────────────────────────────────────────────────────────
class AppProgress extends StatelessWidget {
  final double value; // 0.0 to 1.0
  const AppProgress(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
          color: AppColors.border, borderRadius: BorderRadius.circular(3)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
            decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(3))),
      ),
    );
  }
}

// ─── PLAYER DOT ───────────────────────────────────────────────────────────────
class PlayerDot extends StatelessWidget {
  final String? initials;
  final bool filled;
  const PlayerDot({super.key, this.initials, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: filled ? AppColors.greenLt : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? AppColors.green : AppColors.border,
          width: 1.5,
          style: filled ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Center(
        child: filled && initials != null
            ? Text(initials!,
                style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green))
            : const Icon(LucideIcons.plus, size: 12, color: AppColors.muted2),
      ),
    );
  }
}

// ─── INFO ROW ─────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted)),
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark)),
        ],
      ),
    );
  }
}

// ─── TURF FIELD SVG ───────────────────────────────────────────────────────────
class TurfFieldBanner extends StatelessWidget {
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double height;

  const TurfFieldBanner({
    super.key,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          children: [
            // Green field base
            Container(color: const Color(0xFF2D5A1B)),
            // Pitch strips
            Positioned.fill(
              child: Row(
                children: List.generate(
                  7,
                  (index) => Expanded(
                    child: ColoredBox(
                      color: const Color(0xFF336622).withOpacity(
                        index.isEven ? 0.4 : 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Crease
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.16,
                heightFactor: 1,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 42,
                    maxWidth: 58,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8A96E),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            // Overlay
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withOpacity(0.2)),
            ),
            // Centered logo
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 38,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: AppLogo(width: 124),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Book. Play. Compete.',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Badge
            if (badgeText != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(badgeText!,
                      style: GoogleFonts.dmSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color:
                              badgeTextColor ?? AppColors.green)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
