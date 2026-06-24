import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import 'build_your_own_screen.dart';
import 'personalized_feast_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class GroupMealPlannerScreen extends StatefulWidget {
  const GroupMealPlannerScreen({super.key});

  @override
  State<GroupMealPlannerScreen> createState() => _GroupMealPlannerScreenState();
}

class _GroupMealPlannerScreenState extends State<GroupMealPlannerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;

  int _people = 4;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  final List<_Pref> _prefs = [
    _Pref('Vegetarian', Icons.eco_rounded),
    _Pref('Spicy', Icons.local_fire_department_rounded),
    _Pref('Kid-Friendly', Icons.child_care_rounded),
    _Pref('No Eggs', Icons.egg_alt_rounded),
    _Pref('Gluten-free', Icons.grain_rounded),
    _Pref('Pescatarian', Icons.set_meal_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  double _t(double start, double end) {
    final v = _entrance.value.clamp(start, end);
    return ((v - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _ease(double t) => 1.0 - math.pow(1.0 - t, 3.5).toDouble();

  Widget _reveal(double start, double end, Widget child, {double dy = 20}) {
    final t = _ease(_t(start, end));
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  void _changePeople(int delta) {
    HapticFeedback.selectionClick();
    setState(() => _people = (_people + delta).clamp(1, 50));
  }

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                bottom: false,
                child: AnimatedBuilder(
                  animation: _entrance,
                  builder: (context, _) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _reveal(0.0, 0.22, _buildTopBar()),
                            const SizedBox(height: 18),
                            _reveal(0.05, 0.32, _buildHeroImage()),
                            const SizedBox(height: 18),
                            _reveal(0.10, 0.38, _buildTitle()),
                            const SizedBox(height: 24),
                            _reveal(0.16, 0.44, _buildPeopleStepper()),
                            const SizedBox(height: 24),
                            _reveal(0.22, 0.50, _buildSectionLabel('Guest Preferences')),
                            const SizedBox(height: 12),
                            _reveal(0.26, 0.58, _buildPreferencesGrid()),
                            const SizedBox(height: 22),
                            _reveal(0.34, 0.66, _buildBuildYourOwnCard()),
                            const SizedBox(height: 16),
                            _reveal(0.42, 0.78, _buildAiCard()),
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
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.5, -1.0),
          end: const Alignment(0.5, 1.2),
          colors: [_bgColor, _bgColor2],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Icon(Icons.arrow_back_rounded, size: 24, color: _textColor),
        ),
        const SizedBox(width: 14),
        Text(
          'Group Meal Planner',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Icon(Icons.info_outline_rounded, size: 22, color: _subTextColor),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Image.asset(
          'assets/images/group_feast.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5A2B), Color(0xFF4A2F1A)],
              ),
            ),
            child: const Center(child: Text('🥘', style: TextStyle(fontSize: 56))),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Plan a Group Feast',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Coordinate flavors and portions effortlessly for your next gathering.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            height: 1.4,
            color: _subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleStepper() {
    return Column(
      children: [
        Text(
          'NUMBER OF PEOPLE',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: _subTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stepperButton(Icons.remove_rounded, filled: false, onTap: () => _changePeople(-1)),
            Container(
              width: 80,
              alignment: Alignment.center,
              child: Text(
                '$_people',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                ),
              ),
            ),
            _stepperButton(Icons.add_rounded, filled: true, onTap: () => _changePeople(1)),
          ],
        ),
      ],
    );
  }

  Widget _stepperButton(IconData icon, {required bool filled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
              : null,
          color: filled ? null : _fieldBgColor,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: 24, color: filled ? const Color(0xFF2C1810) : _textColor),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: _textColor,
      ),
    );
  }

  Widget _buildPreferencesGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_prefs.length, (i) {
        final p = _prefs[i];
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 40 - 12) / 2,
          child: _buildPrefChip(p),
        );
      }),
    );
  }

  Widget _buildPrefChip(_Pref p) {
    final selected = p.selected;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => p.selected = !p.selected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? _kAccent.withValues(alpha: _isDarkMode ? 0.18 : 0.10)
              : _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kAccent.withValues(alpha: 0.6) : _fieldBorderColor,
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? null
              : [
                  BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
                ],
        ),
        child: Row(
          children: [
            Icon(
              p.icon,
              size: 20,
              color: selected ? _kAccentDark : _subTextColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                p.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _textColor : _subTextColor,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, size: 16, color: _kAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildYourOwnCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune_rounded, size: 22, color: _kAccentDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build Your Own',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Handpick every dish from our curated collections.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        height: 1.3,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _outlinedButton('Start Building', onTap: () {
  HapticFeedback.mediumImpact();
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => BuildYourOwnScreen(guests: _people),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    ),
  );
}),
        ],
      ),
    );
  }

  Widget _buildAiCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _kAccent.withValues(alpha: _isDarkMode ? 0.20 : 0.12),
                _kAccent.withValues(alpha: _isDarkMode ? 0.08 : 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _kAccent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        size: 22, color: Color(0xFF2C1810)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Recommends',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instant menu balancing based on your group\'s profile.',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            height: 1.3,
                            color: _subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _filledButton('Get Recommendations', onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => PersonalizedFeastScreen(guests: _people),
              transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        }),
            ],
          ),
        ),
        Positioned(
          top: -10,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _kAccent.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'POPULAR',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF2C1810),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _outlinedButton(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _fieldBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kAccentDark,
          ),
        ),
      ),
    );
  }

  Widget _filledButton(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.8, -1.0),
            end: Alignment(0.8, 1.0),
            colors: [_kAccentLight, _kAccent, _kAccentDark],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withValues(alpha: 0.3),
              blurRadius: 14,
              spreadRadius: -4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF2C1810)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C1810),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pref {
  _Pref(this.label, this.icon);
  final String label;
  final IconData icon;
  bool selected = false;
}
