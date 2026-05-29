import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/reveal.dart';
import 'phone_entry_screen.dart';

// ─────────────────────────────────────────────────────────
// SAVORA — Signup Screen  (complete rewrite)
// Design principles:
//  • Warm dark editorial aesthetic: deep clay/ember palette
//  • Playfair Display wordmark, DM Sans body
//  • Minimal language switcher: 2-letter code + underline indicator
//  • Plate art hero with rotating rings and emoji cycling
//  • All entrance animations staggered through AnimationController
// ─────────────────────────────────────────────────────────

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _plate;   // continuous spin for rings
  late final AnimationController _float;   // decor float loop
  late final AnimationController _emoji;   // emoji crossfade

  int _emojiIdx = 0;
  double _emojiOpacity = 1.0;
  double _emojiScale = 1.0;

  static const List<String> _emojis = ['🍲', '🥘', '🍕', '🥗', '🍜', '🍰', '🫕'];

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _plate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _emoji = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _entrance.forward();
    });

    // cycle emoji every 4 s
    _scheduleCycle();
  }

  void _scheduleCycle() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _cycleEmoji();
    });
  }

  Future<void> _cycleEmoji() async {
    setState(() {
      _emojiOpacity = 0.0;
      _emojiScale = 0.7;
    });
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    setState(() {
      _emojiIdx = (_emojiIdx + 1) % _emojis.length;
      _emojiOpacity = 1.0;
      _emojiScale = 1.0;
    });
    _scheduleCycle();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _plate.dispose();
    _float.dispose();
    _emoji.dispose();
    super.dispose();
  }

  void _goToPhone() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(fadeScaleRoute(const PhoneEntryScreen()));
  }

  // Entrance curve helper — maps a [start,end] window of [0..1] to [0..1]
  double _t(double start, double end) {
    final val = _entrance.value.clamp(start, end);
    return ((val - start) / (end - start)).clamp(0.0, 1.0);
  }

  // Smooth ease-out curve
  static double _ease(double t) {
    return 1.0 - math.pow(1.0 - t, 3).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isRtl = l.locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.clay,
        body: AnimatedBuilder(
          animation: Listenable.merge([_entrance, _plate, _float]),
          builder: (context, _) {
            return Stack(
              children: [
                // ── Background ──
                const _SavoraBackground(),

                // ── Floating food decor ──
                _FloatingDecor(floatAnim: _float),

                // ── Main content ──
                SafeArea(
                  child: Directionality(
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          // ── Language switcher ──
                          _buildLangSwitcher(l, _t(0.0, 0.35)),

                          const Spacer(flex: 3),

                          // ── Plate art hero ──
                          _buildPlateHero(_t(0.05, 0.50)),

                          const SizedBox(height: 26),

                          // ── Wordmark ──
                          _buildWordmark(_t(0.15, 0.55)),

                          const SizedBox(height: 8),

                          // ── Tagline ──
                          _buildTagline(l, _t(0.22, 0.62)),

                          const SizedBox(height: 20),

                          // ── Category chips ──
                          _buildChips(l, _t(0.30, 0.68)),

                          const Spacer(flex: 4),

                          // ── Primary CTA ──
                          _buildPrimaryButton(l, _t(0.44, 0.80)),

                          const SizedBox(height: 16),

                          // ── Or divider ──
                          _buildOrDivider(l, _t(0.52, 0.86)),

                          const SizedBox(height: 16),

                          // ── Social row ──
                          _buildSocialRow(l, _t(0.58, 0.92)),

                          const SizedBox(height: 18),

                          // ── Terms ──
                          _buildTerms(l, _t(0.70, 1.00)),

                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Language Switcher ──────────────────────────────────
  Widget _buildLangSwitcher(AppLocalizations l, double t) {
    const langs = [
      ('en', 'EN'),
      ('ar', 'AR'),
      ('es', 'ES'),
    ];
    final current = l.locale.languageCode;
    final opacity = _ease(t);
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: langs.map((entry) {
            final code = entry.$1;
            final label = entry.$2;
            final active = code == current;
            return GestureDetector(
              onTap: active
                  ? null
                  : () => localeProvider.setLocale(Locale(code)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: active ? 1.0 : 0.38,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.06,
                          color: active
                              ? AppColors.saffron
                              : AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: active ? 16 : 0,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: AppColors.saffron,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Plate Hero ─────────────────────────────────────────
  Widget _buildPlateHero(double t) {
    final scale = 0.7 + _ease(t) * 0.3;
    final opacity = _ease(t);
    final spin1 = _plate.value * 2 * math.pi;
    final spin2 = -_plate.value * 2 * math.pi * 1.4;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.rotate(
                angle: spin1,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.saffron.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Inner ring
              Transform.rotate(
                angle: spin2,
                child: Container(
                  width: 152,
                  height: 152,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.saffron.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Plate disc
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.25, -0.35),
                    radius: 1.2,
                    colors: [
                      Color(0xFF3D2010),
                      Color(0xFF1E0D06),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.saffron.withOpacity(0.20),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ember.withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _emojiOpacity,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: _emojiScale,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.elasticOut,
                      child: Text(
                        _emojis[_emojiIdx],
                        style: const TextStyle(fontSize: 52),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Wordmark ───────────────────────────────────────────
  Widget _buildWordmark(double t) {
    final dy = (1 - _ease(t)) * 16;
    final opacity = _ease(t);
    return Transform.translate(
      offset: Offset(0, dy),
      child: Opacity(
        opacity: opacity,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'S', style: AppTheme.wordmark(44)),
              TextSpan(
                text: 'a',
                style: AppTheme.wordmark(44).copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.saffron,
                ),
              ),
              TextSpan(text: 'v', style: AppTheme.wordmark(44)),
              TextSpan(
                text: 'o',
                style: AppTheme.wordmark(44).copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.saffron,
                ),
              ),
              TextSpan(text: 'r', style: AppTheme.wordmark(44)),
              TextSpan(
                text: 'a',
                style: AppTheme.wordmark(44).copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.saffron,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tagline ────────────────────────────────────────────
  Widget _buildTagline(AppLocalizations l, double t) {
    final dy = (1 - _ease(t)) * 14;
    return Transform.translate(
      offset: Offset(0, dy),
      child: Opacity(
        opacity: _ease(t),
        child: RichText(
          textAlign: TextAlign.center,
          text: _parseTagline(l.t('tagline')),
        ),
      ),
    );
  }

  // Parse tagline: wrap **text** in saffron bold
  TextSpan _parseTagline(String raw) {
    const base = TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 14,
      fontWeight: FontWeight.w300,
      color: Color(0x8CFBF6EF),
      height: 1.65,
      letterSpacing: 0.03,
    );
    const highlight = TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xCCFBF6EF),
      height: 1.65,
    );
    final parts = raw.split('**');
    return TextSpan(
      style: base,
      children: parts.asMap().entries.map((e) {
        return TextSpan(
          text: e.value,
          style: e.key.isOdd ? highlight : base,
        );
      }).toList(),
    );
  }

  // ── Chips ──────────────────────────────────────────────
  Widget _buildChips(AppLocalizations l, double t) {
    final dy = (1 - _ease(t)) * 12;
    return Transform.translate(
      offset: Offset(0, dy),
      child: Opacity(
        opacity: _ease(t),
        child: _CategoryChips(locale: l.locale.languageCode),
      ),
    );
  }

  // ── Primary Button ─────────────────────────────────────
  Widget _buildPrimaryButton(AppLocalizations l, double t) {
    final dy = (1 - _ease(t)) * 14;
    return Transform.translate(
      offset: Offset(0, dy),
      child: Opacity(
        opacity: _ease(t),
        child: _SavoraButton(
          label: l.t('continueWithPhone'),
          icon: '🍽',
          onPressed: _goToPhone,
          isPrimary: true,
        ),
      ),
    );
  }

  // ── Or Divider ─────────────────────────────────────────
  Widget _buildOrDivider(AppLocalizations l, double t) {
    return Opacity(
      opacity: _ease(t),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.t('or'),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                letterSpacing: 0.08,
                color: Color(0x4DFBF6EF),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
        ],
      ),
    );
  }

  // ── Social Row ─────────────────────────────────────────
  Widget _buildSocialRow(AppLocalizations l, double t) {
    final dy = (1 - _ease(t)) * 12;
    return Transform.translate(
      offset: Offset(0, dy),
      child: Opacity(
        opacity: _ease(t),
        child: Row(
          children: [
            Expanded(
              child: _SavoraSocialButton(
                label: l.t('continueWithGoogle'),
                icon: const _GoogleGlyph(),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SavoraSocialButton(
                label: l.t('continueWithApple'),
                icon: const Icon(Icons.apple, color: Color(0xCCFBF6EF), size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Terms ──────────────────────────────────────────────
  Widget _buildTerms(AppLocalizations l, double t) {
    const muted = TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 11.5,
      fontWeight: FontWeight.w300,
      color: Color(0x4DFBF6EF),
      height: 1.55,
      letterSpacing: 0.01,
    );
    const link = TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 11.5,
      fontWeight: FontWeight.w400,
      color: AppColors.saffron,
      height: 1.55,
    );
    return Opacity(
      opacity: _ease(t),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: muted,
          children: [
            TextSpan(text: l.t('termsPrefix')),
            TextSpan(text: l.t('terms'), style: link),
            TextSpan(text: l.t('and')),
            TextSpan(text: l.t('privacyPolicy'), style: link),
            TextSpan(text: l.t('termsSuffix')),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// BACKGROUND
// ════════════════════════════════════════════════════════
class _SavoraBackground extends StatelessWidget {
  const _SavoraBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.6, -1.0),
              end: Alignment(0.6, 1.0),
              colors: [
                Color(0xFF1A0C06),
                Color(0xFF2C1810),
                Color(0xFF3D1E0E),
                Color(0xFF1E0D06),
                Color(0xFF120906),
              ],
              stops: [0.0, 0.28, 0.55, 0.78, 1.0],
            ),
          ),
        ),
        // Top-left warm orb
        Positioned(
          top: -80,
          left: -90,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.saffron.withOpacity(0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-right ember orb
        Positioned(
          bottom: -60,
          right: -70,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.ember.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// FLOATING FOOD DECOR
// ════════════════════════════════════════════════════════
class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor({required this.floatAnim});

  final AnimationController floatAnim;

  static const List<_FoodSpec> _specs = [
    _FoodSpec('🍕', x: -0.84, y: -0.80, size: 30, opacity: 0.13, freqX: 1.0, freqY: 0.9, ampX: 5, ampY: 8, phase: 0.0),
    _FoodSpec('🥗', x: 0.86, y: -0.70, size: 28, opacity: 0.11, freqX: 1.2, freqY: 1.1, ampX: 6, ampY: 7, phase: 1.2),
    _FoodSpec('🍜', x: -0.90, y: -0.02, size: 26, opacity: 0.10, freqX: 0.9, freqY: 1.0, ampX: 4, ampY: 9, phase: 2.4),
    _FoodSpec('🫕', x: 0.90, y: 0.12, size: 28, opacity: 0.12, freqX: 1.3, freqY: 1.2, ampX: 5, ampY: 8, phase: 3.6),
    _FoodSpec('🥘', x: -0.80, y: 0.78, size: 30, opacity: 0.11, freqX: 1.1, freqY: 0.8, ampX: 6, ampY: 7, phase: 4.8),
    _FoodSpec('🍣', x: 0.84, y: 0.84, size: 26, opacity: 0.10, freqX: 1.0, freqY: 1.3, ampX: 4, ampY: 8, phase: 6.0),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (context, _) {
        return IgnorePointer(
          child: Stack(
            children: _specs.map((s) {
              final t = floatAnim.value * 2 * math.pi;
              final dx = math.sin(t * s.freqX + s.phase) * s.ampX;
              final dy = math.cos(t * s.freqY + s.phase) * s.ampY;
              return Align(
                alignment: Alignment(s.x, s.y),
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: Opacity(
                    opacity: s.opacity,
                    child: Text(s.emoji, style: TextStyle(fontSize: s.size)),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FoodSpec {
  const _FoodSpec(this.emoji, {
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.freqX,
    required this.freqY,
    required this.ampX,
    required this.ampY,
    required this.phase,
  });
  final String emoji;
  final double x, y, size, opacity, freqX, freqY, ampX, ampY, phase;
}

// ════════════════════════════════════════════════════════
// CATEGORY CHIPS
// ════════════════════════════════════════════════════════
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.locale});
  final String locale;

  List<(String, String)> get _items {
    return switch (locale) {
      'ar' => const [('🍕', 'إيطالي'), ('🥘', 'مصري'), ('🍜', 'آسيوي'), ('🥗', 'صحي'), ('🍰', 'حلويات')],
      'es' => const [('🍕', 'Italiano'), ('🥘', 'Egipcio'), ('🍜', 'Asiático'), ('🥗', 'Saludable'), ('🍰', 'Postres')],
      _   => const [('🍕', 'Italian'), ('🥘', 'Egyptian'), ('🍜', 'Asian'), ('🥗', 'Healthy'), ('🍰', 'Desserts')],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      alignment: WrapAlignment.center,
      children: _items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.saffron.withOpacity(0.20),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.$1, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                item.$2,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xA6FBF6EF),
                  letterSpacing: 0.02,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════
// PRIMARY BUTTON
// ════════════════════════════════════════════════════════
class _SavoraButton extends StatefulWidget {
  const _SavoraButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
  });
  final String label;
  final String icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  State<_SavoraButton> createState() => _SavoraButtonState();
}

class _SavoraButtonState extends State<_SavoraButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onPressed();
      },
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) => Transform.scale(
          scale: _press.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.saffron,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.saffron.withOpacity(0.28),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shine overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.14),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C1810),
                      letterSpacing: 0.01,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// SOCIAL BUTTON
// ════════════════════════════════════════════════════════
class _SavoraSocialButton extends StatefulWidget {
  const _SavoraSocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  State<_SavoraSocialButton> createState() => _SavoraSocialButtonState();
}

class _SavoraSocialButtonState extends State<_SavoraSocialButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onPressed();
      },
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) => Transform.scale(
          scale: _press.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xBFFBF6EF),
                  letterSpacing: 0.01,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// GOOGLE GLYPH
// ════════════════════════════════════════════════════════
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(17, 17),
      painter: _GoogleGlyphPainter(),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Simplified Google 'G' shape via four arcs
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), -math.pi / 6, -2 * math.pi / 3, true, paint);

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), -math.pi / 6, math.pi / 3, true, paint);

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), math.pi / 6, math.pi / 2, true, paint);

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), 2 * math.pi / 3, math.pi / 2, true, paint);

    // Center punch-out
    paint.color = const Color(0xFF2C1810);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.35, paint);

    // Bar for the G's horizontal stroke (white)
    paint.color = Colors.white.withOpacity(0.85);
    canvas.drawRect(Rect.fromLTWH(w * 0.5, h * 0.42, w * 0.46, h * 0.16), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// ════════════════════════════════════════════════════════
// APP THEME — add wordmark() to your app_theme.dart
// ════════════════════════════════════════════════════════
// static TextStyle wordmark(double size) => TextStyle(
//   fontFamily: 'Playfair Display',
//   fontSize: size,
//   fontWeight: FontWeight.w700,
//   color: AppColors.cream,
//   letterSpacing: -0.02,
//   height: 1.0,
// );

// ════════════════════════════════════════════════════════
// LOCALIZATION — add to your AppLocalizations strings:
// ════════════════════════════════════════════════════════
// EN:
//   tagline: "Fresh, homemade meals from **local chefs** in your city."
//
// AR:
//   tagline: "وجبات منزلية طازجة من **طهاة محليين** في مدينتك."
//
// ES:
//   tagline: "Comidas caseras frescas de **cocineros locales** en tu ciudad."
//
// NOTE: ** delimiters are parsed by _parseTagline() to apply highlight style.

// ════════════════════════════════════════════════════════
// pubspec.yaml — add these fonts:
// ════════════════════════════════════════════════════════
// fonts:
//   - family: Playfair Display
//     fonts:
//       - asset: assets/fonts/PlayfairDisplay-Regular.ttf
//       - asset: assets/fonts/PlayfairDisplay-Italic.ttf
//         style: italic
//       - asset: assets/fonts/PlayfairDisplay-Bold.ttf
//         weight: 700
//       - asset: assets/fonts/PlayfairDisplay-BoldItalic.ttf
//         weight: 700
//         style: italic
//
//   - family: DM Sans
//     fonts:
//       - asset: assets/fonts/DMSans-Light.ttf
//         weight: 300
//       - asset: assets/fonts/DMSans-Regular.ttf
//       - asset: assets/fonts/DMSans-Medium.ttf
//         weight: 500