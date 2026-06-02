import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import 'registration_choice_screen.dart';

// ─── Accent palette ──────────────────────────────────────────────────────────
const _kAccent      = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark  = Color(0xFFD4952E);

// ─── Main screen ─────────────────────────────────────────────────────────────

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _entrance;
  late final AnimationController _float;

  // ── Merged listenable drives both animations in one AnimatedBuilder ─────────
  late final Listenable _allAnimations;

  // ── Text field ─────────────────────────────────────────────────────────────
  final _nameCtrl  = TextEditingController();
  final _nameFocus = FocusNode();

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // FIX 3: merge both controllers so AnimatedBuilder rebuilds on either tick.
    _allAnimations = Listenable.merge([_entrance, _float]);

    _nameCtrl.addListener(() => setState(() {}));
    _nameFocus.addListener(() => setState(() {}));

    themeModeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() =>
      setState(() => _isDarkMode = themeModeNotifier.value == ThemeMode.dark);

  @override
  void dispose() {
    themeModeNotifier.removeListener(_onThemeChanged);
    _entrance.dispose();
    _float.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  bool get _valid => _nameCtrl.text.trim().length >= 2;

  void _continue() {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) =>
            RegistrationChoiceScreen(name: _nameCtrl.text.trim()),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOutExpo),
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // Entrance animation progress for a window [start, end].
  double _t(double start, double end) {
    final v = _entrance.value.clamp(start, end);
    return ((v - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _ease(double t) =>
      1.0 - math.pow(1.0 - t, 3.5).toDouble();

  Widget _reveal(
      double start,
      double end,
      Widget child, {
        double dy = 20,
      }) {
    final t = _ease(_t(start, end));
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * dy),
        child: child,
      ),
    );
  }

  // ── Theme colours ──────────────────────────────────────────────────────────
  Color get _bgColor    => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2   => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor  => _isDarkMode ? AppColors.cream    : const Color(0xFF161618);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor  => _isDarkMode ? AppColors.glass    : Colors.white;
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass  : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.06);

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = l.locale;
    final isRtl  = locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        // FIX: resizeToAvoidBottomInset keeps layout stable when keyboard opens.
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ── Background (driven by _float only, no need for full rebuild) ──
            _BackgroundLayer(
              floatCtrl: _float,
              bgColor: _bgColor,
              bgColor2: _bgColor2,
            ),

            SafeArea(
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: AnimatedBuilder(
                  // FIX 3: listen to both controllers.
                  animation: _allAnimations,
                  builder: (context, _) {
                    return Column(
                      children: [
                        // ── Scrollable body ──────────────────────────────────
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                _reveal(0.0, 0.22, _buildTopBar()),
                                const SizedBox(height: 48),
                                // FIX 2: hero uses _float inside the same
                                // AnimatedBuilder (merged listenable above).
                                _reveal(0.08, 0.40, _buildHero()),
                                const SizedBox(height: 28),
                                _reveal(0.16, 0.50, _buildTitle(l)),
                                const SizedBox(height: 10),
                                _reveal(0.22, 0.56, _buildSubtitle(l)),
                                const SizedBox(height: 36),
                                _reveal(0.32, 0.70, _buildNameField(l)),
                                // FIX 1: SizedBox instead of Spacer —
                                // Spacer is illegal inside a scroll view.
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),

                        // ── Sticky CTA pinned above keyboard ─────────────────
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            28, 8, 28,
                            MediaQuery.of(context).viewPadding.bottom + 24,
                          ),
                          child: _reveal(0.50, 0.90, _buildContinueButton(l)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
                color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(Icons.arrow_back_rounded, size: 20, color: _textColor),
      ),
    );
  }

  Widget _buildHero() {
    // FIX 2: _float is now part of _allAnimations, so this value is
    // live — the bob actually animates after entrance completes.
    final bob = math.sin(_float.value * 2 * math.pi) * 6.0;
    return Center(
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Container(
          width: 88, height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                colors: [_kAccentLight, _kAccentDark]),
            boxShadow: [
              BoxShadow(
                  color: _kAccent.withValues(alpha: 0.35),
                  blurRadius: 22, spreadRadius: -4,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: const Text('👤', style: TextStyle(fontSize: 40)),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l) {
    return Text(
      l.t('nameEntryTitle'),
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 28, fontWeight: FontWeight.w700,
        color: _textColor, height: 1.15,
      ),
    );
  }

  Widget _buildSubtitle(AppLocalizations l) {
    return Text(
      l.t('nameEntrySubtitle'),
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14, height: 1.4,
        color: _subTextColor,
      ),
    );
  }

  Widget _buildNameField(AppLocalizations l) {
    final focused = _nameFocus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _fieldBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused
              ? _kAccent.withValues(alpha: 0.55)
              : _fieldBorderColor,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [
          BoxShadow(
              color: _kAccent.withValues(alpha: 0.16),
              blurRadius: 14, spreadRadius: 1),
        ]
            : null,
      ),
      child: TextField(
        controller:   _nameCtrl,
        focusNode:    _nameFocus,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        textInputAction:    TextInputAction.done,
        onSubmitted: (_) { if (_valid) _continue(); },
        cursorColor: _kAccent,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 17, fontWeight: FontWeight.w600,
          color: _textColor,
        ),
        decoration: InputDecoration(
          hintText: l.t('nameEntryHint'),
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 17,
            color: _subTextColor.withValues(alpha: 0.5),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.person_outline_rounded,
              size: 22,
              color: focused
                  ? _kAccent
                  : _subTextColor.withValues(alpha: 0.5),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border:           InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        ),
      ),
    );
  }

  Widget _buildContinueButton(AppLocalizations l) {
    return GestureDetector(
      onTap: _valid ? _continue : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: _valid
              ? const LinearGradient(
            begin: Alignment(-0.8, -1.0),
            end:   Alignment(0.8,  1.0),
            colors: [_kAccentLight, _kAccent, _kAccentDark],
          )
              : null,
          color:          _valid ? null : _fieldBgColor,
          borderRadius:   BorderRadius.circular(14),
          border: Border.all(
            color: _valid ? Colors.transparent : _fieldBorderColor,
            width: 0.5,
          ),
          boxShadow: _valid
              ? [
            BoxShadow(
                color:       _kAccent.withValues(alpha: 0.3),
                blurRadius:  16, spreadRadius: -4,
                offset:      const Offset(0, 5)),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l.t('continue'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15, fontWeight: FontWeight.w700,
                color: _valid
                    ? const Color(0xFF2C1810)
                    : _subTextColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size:  18,
              color: _valid ? const Color(0xFF2C1810) : _subTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Background layer (separate StatefulWidget to isolate float redraws) ──────

class _BackgroundLayer extends StatelessWidget {
  final AnimationController floatCtrl;
  final Color bgColor;
  final Color bgColor2;

  const _BackgroundLayer({
    required this.floatCtrl,
    required this.bgColor,
    required this.bgColor2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.5, -1.0),
              end:   const Alignment(0.5,  1.2),
              colors: [bgColor, bgColor2],
            ),
          ),
        ),

        // Top-right orb
        Positioned(
          top: -80, right: -50,
          child: AnimatedBuilder(
            animation: floatCtrl,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, floatCtrl.value * 30),
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _kAccent.withValues(alpha: 0.08),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
        ),

        // Bottom-left orb
        Positioned(
          bottom: -70, left: -60,
          child: AnimatedBuilder(
            animation: floatCtrl,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, -floatCtrl.value * 30),
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _kAccent.withValues(alpha: 0.04),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}