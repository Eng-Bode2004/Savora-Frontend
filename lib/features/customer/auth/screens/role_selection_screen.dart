import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/savora_api.dart';
import '../../../../state/providers/auth_provider.dart';
import '../../../../core/routing/routes.dart';
import 'login_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key, this.userId});

  final String? userId;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _shimmer;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;
  String? _roleError;

  // Roles fetched from API, keyed by English key (Customer, Chef, Delivery)
  List<Map<String, dynamic>> _fetchedRoles = [];

  // Fallback hardcoded specs (used if API fails).
  // Order must match the API's consistent return order:
  //   [0] Customer, [1] Delivery, [2] Chief (spelled "Chief" in API → "Chef" internally)
  static const List<_RoleSpec> _fallbackRoles = [
    _RoleSpec(
      id: null,
      roleKey: 'Customer',
      titleKey: 'roleCustomer',
      subtitleKey: 'roleCustomerSub',
      fallbackTitle: 'Customer',
      fallbackSubtitle: 'Browse restaurants and order delicious meals to your door',
      image: 'assets/images/Cutomer.png',
      icon: Icons.restaurant_rounded,
      tint: Color(0xFFE8A838),
    ),
    _RoleSpec(
      id: null,
      roleKey: 'Delivery',
      titleKey: 'roleDelivery',
      subtitleKey: 'roleDeliverySub',
      fallbackTitle: 'Delivery Partner',
      fallbackSubtitle: 'Pick up orders, deliver to customers, and earn on your schedule',
      image: 'assets/images/Delivery.png',
      icon: Icons.delivery_dining_rounded,
      tint: Color(0xFF5BA46A),
    ),
    _RoleSpec(
      id: null,
      roleKey: 'Chef',
      titleKey: 'roleChief',
      subtitleKey: 'roleChiefSub',
      fallbackTitle: 'Chef',
      fallbackSubtitle: 'Share your cooking, manage your menu, and grow your kitchen',
      image: 'assets/images/Chief.png',
      icon: Icons.soup_kitchen_rounded,
      tint: Color(0xFFE07A3D),
    ),
  ];

  List<_RoleSpec> get _roles {
    if (_fetchedRoles.isNotEmpty) {
      // Map by index — API always returns [Customer, Delivery, Chief] regardless of language
      return _fetchedRoles.asMap().entries.map((entry) {
        final r = entry.value;
        final fallback = entry.key < _fallbackRoles.length
            ? _fallbackRoles[entry.key]
            : _fallbackRoles.first;
        return _RoleSpec(
          id: r['id'] as String?,
          roleKey: fallback.roleKey,
          titleKey: fallback.titleKey,
          subtitleKey: fallback.subtitleKey,
          fallbackTitle: r['name'] as String? ?? fallback.fallbackTitle,
          fallbackSubtitle: fallback.fallbackSubtitle,
          image: r['imageUrl'] as String? ?? fallback.image,
          icon: fallback.icon,
          tint: fallback.tint,
        );
      }).toList();
    }
    return _fallbackRoles;
  }

  // Returns the translation, or the fallback if the key is missing / echoed back.
  String _loc(AppLocalizations l, String key, String fallback) {
    final v = l.t(key);
    if (v.isEmpty || v == key) return fallback;
    return v;
  }

  Future<void> _fetchRoles() async {
    try {
      final userId = widget.userId;
      final appLang = localeProvider.locale.languageCode;
      final langMap = {
        'en': 'english',
        'ar': 'arabic',
        'es': 'spanish',
        'fr': 'french',
        'zh': 'chinese',
      };
      final langFull = langMap[appLang] ?? 'english';

      // Sync the app's locale to the backend so the user's language is stored
      if (userId != null && userId.isNotEmpty) {
        try {
          await SavoraApi.changeUserLanguage(userId: userId, language: langFull);
        } catch (_) {}
      }

      // Fetch roles in the app's language
      final roles = await SavoraApi.getRolesByLanguage(langFull);
      if (mounted) {
        setState(() {
          _fetchedRoles = roles;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _roleError = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _assignRole(String roleId, _RoleSpec spec) async {
    final userId = widget.userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await SavoraApi.assignRole(userId: userId, roleId: roleId);

      if (spec.roleKey == 'Chef' && authState.name != null && authState.name!.trim().isNotEmpty) {
        final profileResult = await SavoraApi.createChiefProfile(authState.name!.trim());
        final profile = profileResult['profile'] as Map<String, dynamic>?;
        final profileId = profile?['_id'] as String?;
        if (profileId != null) {
          await SavoraApi.assignProfile(userId: userId, profileId: profileId);
          authState.setProfileId(profileId);
          if (profile != null) authState.setProfileData(profile);
        }
      } else if (spec.roleKey == 'Delivery' && authState.name != null && authState.name!.trim().isNotEmpty) {
        final profileResult = await SavoraApi.createDriverProfile(authState.name!.trim());
        final profile = profileResult['profile'] as Map<String, dynamic>?;
        final profileId = profile?['_id'] as String?;
        if (profileId != null) {
          await SavoraApi.assignProfile(userId: userId, profileId: profileId);
          authState.setProfileId(profileId);
          if (profile != null) authState.setProfileData(profile);
        }
      } else if (spec.roleKey == 'Customer') {
        try {
          final profileResult = await SavoraApi.createCustomerProfile({
            'auth_id': userId,
            'name': authState.name ?? '',
          });
          final profile = profileResult['response'] as Map<String, dynamic>?;
          final profileId = profile?['_id'] as String?;
          if (profileId != null) {
            await SavoraApi.assignProfile(userId: userId, profileId: profileId);
          }
        } catch (_) {
          // profile may already exist from backend auto-creation
        }
      }

      _showSuccessDialog(spec);
    } catch (e) {
      if (mounted) {
        setState(() {
          _roleError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    _fetchRoles();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _shimmer.dispose();
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

  // ── theme colors ──
  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF6B6258);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  void _toggleDarkMode() {
    HapticFeedback.lightImpact();
    setState(() {
      themeModeNotifier.value = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _selectRole(_RoleSpec spec) {
    HapticFeedback.mediumImpact();

    final roleId = spec.id;
    final userId = widget.userId;

    if (roleId != null && userId != null) {
      _assignRole(roleId, spec);
      return;
    }

    if (roleId == null && _fetchedRoles.isEmpty) {
      setState(() => _roleError = 'Could not load roles from server');
      return;
    }

    _showSuccessDialog(spec);
  }

  void _showSuccessDialog(_RoleSpec spec) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'role',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.8 + 0.2 * curved.value.clamp(0.0, 1.0),
            child: _RoleSuccessDialog(role: spec.fallbackTitle, isDark: _isDarkMode),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss dialog
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isRtl = l.locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              _buildBackground(),
              Positioned.fill(
                child: SafeArea(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_entrance, _float, _shimmer]),
                    builder: (context, _) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      _reveal(0.0, 0.22, _buildTopBar()),
                                      const SizedBox(height: 20),
                                      _reveal(0.05, 0.38, _buildHero()),
                                      const SizedBox(height: 10),
                                      _reveal(0.12, 0.42, _buildHeader(l)),
                                      const SizedBox(height: 34),
                                      _reveal(0.24, 0.62, _buildRoleCard(l, _roles[0]), dy: 24),
                                      const SizedBox(height: 16),
                                      _reveal(0.32, 0.70, _buildRoleCard(l, _roles[1]), dy: 24),
                                      const SizedBox(height: 16),
                                      _reveal(0.40, 0.78, _buildRoleCard(l, _roles[2]), dy: 24),
                                      if (_roleError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            _roleError!,
                                            style: const TextStyle(
                                              color: Color(0xFFE0533D),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      const Spacer(),
                                      _reveal(0.55, 1.0, _buildFooter(l)),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════ BACKGROUND ════════
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.5, -1.0),
              end: const Alignment(0.5, 1.2),
              colors: [_bgColor, _bgColor2],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_kAccent.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -70,
          left: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_kAccent.withValues(alpha: 0.04), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════ TOP BAR ════════
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleBtn(
          icon: Icons.arrow_back_rounded,
          color: _textColor,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        _circleBtn(
          icon: _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: _isDarkMode ? _kAccent : const Color(0xFF2C1810),
          onTap: _toggleDarkMode,
        ),
      ],
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: [
            BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) =>
              RotationTransition(turns: a, child: FadeTransition(opacity: a, child: c)),
          child: Icon(icon, key: ValueKey(icon), size: 20, color: color),
        ),
      ),
    );
  }

  // ════════ HERO ════════
  Widget _buildHero() {
    final bob = math.sin(_float.value * 2 * math.pi) * 7;
    final orbit = _float.value * 2 * math.pi;

    return SizedBox(
      height: 150,
      child: Center(
        child: Transform.translate(
          offset: Offset(0, bob),
          child: SizedBox(
            width: 170,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_kAccent.withValues(alpha: 0.14), Colors.transparent],
                    ),
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_kAccentLight, _kAccentDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.40),
                        blurRadius: 24,
                        spreadRadius: -4,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.people_alt_rounded,
                        color: Color(0xFF2C1810), size: 44),
                  ),
                ),
                for (int i = 0; i < _roles.length; i++)
                  Transform.translate(
                    offset: Offset(
                      math.cos(orbit + i * 2 * math.pi / 3) * 70,
                      math.sin(orbit + i * 2 * math.pi / 3) * 70,
                    ),
                    child: _orbitBadge(_roles[i].icon, _roles[i].tint),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orbitBadge(IconData icon, Color tint) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Icon(icon, size: 18, color: tint),
    );
  }

  // ════════ HEADER ════════
  Widget _buildHeader(AppLocalizations l) {
    return Column(
      children: [
        Text(
          _loc(l, 'chooseYourRole', 'Choose your role'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _loc(l, 'tellUsWhoYouAre', 'How would you like to use Savora?'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            height: 1.4,
            color: _subTextColor,
          ),
        ),
      ],
    );
  }

  // ════════ ROLE CARD ════════
  Widget _buildRoleCard(AppLocalizations l, _RoleSpec spec) {
    return _RoleCard(
      title: _loc(l, spec.titleKey, spec.fallbackTitle),
      subtitle: _loc(l, spec.subtitleKey, spec.fallbackSubtitle),
      spec: spec,
      isDark: _isDarkMode,
      cardColor: _cardColor,
      borderColor: _fieldBorderColor,
      shadowColor: _shadowColor,
      textColor: _textColor,
      subTextColor: _subTextColor,
      shimmer: _shimmer,
      onTap: () => _selectRole(spec),
    );
  }

  // ════════ FOOTER ════════
  Widget _buildFooter(AppLocalizations l) {
    return Text(
      _loc(l, 'changeRoleLater', 'You can change this anytime in settings'),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        color: _subTextColor.withValues(alpha: 0.8),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// ROLE SPEC
// ════════════════════════════════════════════════════════
class _RoleSpec {
  const _RoleSpec({
    this.id,
    required this.roleKey,
    required this.titleKey,
    required this.subtitleKey,
    required this.fallbackTitle,
    required this.fallbackSubtitle,
    required this.image,
    required this.icon,
    required this.tint,
  });
  final String? id; // API role _id (null for fallback)
  final String roleKey;
  final String titleKey;
  final String subtitleKey;
  final String fallbackTitle;
  final String fallbackSubtitle;
  final String image;
  final IconData icon;
  final Color tint;
}

// ════════════════════════════════════════════════════════
// ROLE CARD
// ════════════════════════════════════════════════════════
class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.spec,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.subTextColor,
    required this.shimmer,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final _RoleSpec spec;
  final bool isDark;
  final Color cardColor, borderColor, shadowColor, textColor, subTextColor;
  final AnimationController shimmer;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tint = widget.spec.tint;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _pressed
              ? tint.withValues(alpha: widget.isDark ? 0.18 : 0.08)
              : widget.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _pressed ? tint.withValues(alpha: 0.5) : widget.borderColor,
            width: _pressed ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _pressed ? tint.withValues(alpha: 0.22) : widget.shadowColor,
              blurRadius: _pressed ? 20 : 16,
              spreadRadius: _pressed ? -4 : -6,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              if (_pressed)
                Positioned(
                  left: -90 + widget.shimmer.value * 460,
                  top: 0,
                  bottom: 0,
                  width: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          tint.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: widget.isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.spec.image.startsWith('http')
                        ? Image.network(
                            widget.spec.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(widget.spec.icon, color: tint, size: 28),
                            ),
                          )
                        : Image.asset(
                            widget.spec.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(widget.spec.icon, color: tint, size: 28),
                            ),
                          ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: _pressed ? tint : widget.textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.5,
                            color: widget.subTextColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: _pressed ? tint : widget.textColor.withValues(alpha: 0.4),
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
// ROLE SUCCESS DIALOG
// ════════════════════════════════════════════════════════
class _RoleSuccessDialog extends StatefulWidget {
  const _RoleSuccessDialog({required this.role, required this.isDark});

  final String role;
  final bool isDark;

  @override
  State<_RoleSuccessDialog> createState() => _RoleSuccessDialogState();
}

class _RoleSuccessDialogState extends State<_RoleSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _check;

  String _loc(AppLocalizations l, String key, String fallback) {
    final v = l.t(key);
    if (v.isEmpty || v == key) return fallback;
    return v;
  }

  @override
  void initState() {
    super.initState();
    _check = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _check.forward();
    });
  }

  @override
  void dispose() {
    _check.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dark = widget.isDark;
    final cardColor = dark ? AppColors.espressoSoft : Colors.white;
    final textColor = dark ? AppColors.cream : const Color(0xFF1A1410);
    final subColor = dark ? AppColors.creamDim : const Color(0xFF6B6258);
    final border = dark ? AppColors.glassBorder : const Color(0xFFE8E4DE);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.4 : 0.15),
                blurRadius: 40,
                spreadRadius: -8,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _check,
                builder: (_, __) {
                  final t = Curves.easeOutBack.transform(_check.value);
                  return Transform.scale(
                    scale: t.clamp(0.0, 1.2),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_kAccentLight, _kAccentDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: -2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF2C1810),
                        size: 46,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              Text(
                _loc(l, 'youreAllSet', "You're all set!"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    height: 1.5,
                    color: subColor,
                  ),
                  children: [
                    TextSpan(text: '${_loc(l, 'accountReadyAs', 'Your account is ready as a')} '),
                    TextSpan(
                      text: widget.role,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _kAccent,
                      ),
                    ),
                    TextSpan(text: '.\n${_loc(l, 'pleaseLogInToContinue', 'Please log in to continue.')}'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}