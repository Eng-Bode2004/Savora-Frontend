import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/savora_api.dart';
import '../../../../state/providers/auth_provider.dart';
import 'package:savora_app/features/customer/auth/screens/splash_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class ChefProfileScreen extends StatefulWidget {
  const ChefProfileScreen({super.key});

  @override
  State<ChefProfileScreen> createState() => _ChefProfileScreenState();
}

class _ChefProfileScreenState extends State<ChefProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  final _nameController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _notifications = true;
  bool _kitchenOpen = true;
  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  String _name = '';
  String? _profileId;
  String _phone = '';
  String _email = '';
  String? _profileImage;

  static const List<_Lang> _languages = [
    _Lang('en', 'English', '🇬🇧'),
    _Lang('ar', 'العربية', '🇸🇦'),
    _Lang('es', 'Español', '🇪🇸'),
    _Lang('zh', '中文', '🇨🇳'),
    _Lang('fr', 'Français', '🇫🇷'),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loadProfile();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final pid = authState.profileId;
    if (pid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await SavoraApi.getChiefProfile(pid);
      final profile = res['profile'] as Map<String, dynamic>? ?? res;
      _name = profile['name'] as String? ?? '';
      _phone = profile['phone'] as String? ?? '';
      _email = authState.email ?? '';
      _kitchenOpen = profile['kitchen_open'] as bool? ?? true;
      _profileImage = profile['profile_image'] as String?;
      _profileId = pid;
      _nameController.text = _name;
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    try {
      final uploaded = await SavoraApi.uploadChiefProfileImage(bytes, picked.name);
      final imageUrl = uploaded['url'] as String?;
      if (imageUrl != null && _profileId != null) {
        await SavoraApi.updateChiefProfile(_profileId!, {'profile_image': imageUrl});
        setState(() => _profileImage = imageUrl);
      }
    } catch (_) {}
  }

  Future<void> _saveName() async {
    if (_profileId == null || _nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await SavoraApi.updateChiefProfile(_profileId!, {'name': _nameController.text.trim()});
      setState(() => _name = _nameController.text.trim());
    } catch (_) {}
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _toggleKitchen(bool value) async {
    if (_profileId == null) return;
    final previous = _kitchenOpen;
    setState(() => _kitchenOpen = value);
    try {
      await SavoraApi.setKitchenStatus(_profileId!, value);
    } catch (_) {
      setState(() => _kitchenOpen = previous);
    }
  }

  void _logout() {
    authState.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
    );
  }

  double _t(double start, double end) {
    final v = _entrance.value.clamp(start, end);
    return ((v - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _ease(double t) => 1.0 - math.pow(1.0 - t, 3.5).toDouble();

  Widget _reveal(double start, double end, Widget child, {double dy = 22}) {
    final t = _ease(_t(start, end));
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  _Lang get _currentLang => _languages.firstWhere(
        (l) => l.code == localeProvider.locale.languageCode,
        orElse: () => _languages.first,
      );

  void _openLanguagePicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (_) => _LanguageSheet(
        languages: _languages,
        current: localeProvider.locale.languageCode,
        isDark: _isDarkMode,
        onSelect: (code) {
          HapticFeedback.selectionClick();
          localeProvider.setLocale(Locale(code));
          Navigator.of(context).pop();
          setState(() {});
        },
      ),
    );
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
    final l = AppLocalizations.of(context);
    final isRtl = l.locale.languageCode == 'ar';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: CircularProgressIndicator(color: _kAccent),
        ),
      );
    }

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
                            const SizedBox(height: 20),
                            _reveal(0.05, 0.32, _buildProfileHeader()),
                            const SizedBox(height: 28),
                            _reveal(0.12, 0.40, _buildSectionLabel('Edit Name')),
                            const SizedBox(height: 10),
                            _reveal(0.16, 0.48, _buildEditNameCard()),
                            const SizedBox(height: 24),
                            _reveal(0.24, 0.52, _buildSectionLabel('Preferences')),
                            const SizedBox(height: 10),
                            _reveal(0.28, 0.60, _buildPreferencesSection(l)),
                            const SizedBox(height: 24),
                            _reveal(0.36, 0.64, _buildSectionLabel('Account')),
                            const SizedBox(height: 10),
                            _reveal(0.40, 0.72, _buildAccountSection()),
                            const SizedBox(height: 24),
                            _reveal(0.50, 0.85, _buildLogoutButton()),
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
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text('🍴', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 10),
        Text(
          'Savora',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() {
            _isDarkMode = !_isDarkMode;
            themeModeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
          }),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: _fieldBorderColor, width: 0.5),
            ),
            child: Icon(
              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 18,
              color: _isDarkMode ? _kAccent : const Color(0xFF2C1810),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kAccent, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.3),
                      blurRadius: 18,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.network(_profileImage!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarPlaceholder())
                      : _avatarPlaceholder(),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
                    shape: BoxShape.circle,
                    border: Border.all(color: _bgColor, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 12, color: Color(0xFF2C1810)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _name.isEmpty ? 'Chef' : _name,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _email.isEmpty ? _phone : _email,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: _subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: _fieldBgColor,
      child: Icon(Icons.person_rounded, size: 44, color: _subTextColor),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: _kAccentDark,
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(color: _fieldBorderColor, height: 1, thickness: 0.5),
      );

  Widget _buildEditNameCard() {
    return _card([
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: TextField(
          controller: _nameController,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: _subTextColor, fontFamily: 'DM Sans'),
            filled: true,
            fillColor: _fieldBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _fieldBorderColor, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _fieldBorderColor, width: 0.5),
            ),
            prefixIcon: Icon(Icons.person_outline_rounded, color: _subTextColor, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
      _divider(),
      Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveName,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: const Color(0xFF2C1810),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2C1810)))
                : const Text(
                    'Save Name',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildPreferencesSection(AppLocalizations l) {
    return _card([
      _tile(
        Icons.notifications_none_rounded,
        'Notifications',
        trailing: Switch.adaptive(
          value: _notifications,
          activeTrackColor: _kAccent,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => _notifications = v);
          },
        ),
      ),
      _divider(),
      _tile(
        Icons.translate_rounded,
        'Language',
        subtitle: _currentLang.label,
        onTap: _openLanguagePicker,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_currentLang.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _subTextColor),
          ],
        ),
      ),
      _divider(),
      _tile(
        Icons.dark_mode_outlined,
        'Dark Mode',
        trailing: Switch.adaptive(
          value: _isDarkMode,
          activeTrackColor: _kAccent,
          onChanged: (_) => setState(() {
            _isDarkMode = !_isDarkMode;
            themeModeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
          }),
        ),
      ),
    ]);
  }

  Widget _buildAccountSection() {
    return _card([
      _tile(Icons.store_outlined, 'Kitchen Open',
        trailing: Switch.adaptive(
          value: _kitchenOpen,
          activeTrackColor: _kAccent,
          onChanged: _toggleKitchen,
        ),
      ),
      _divider(),
      _tile(Icons.phone_outlined, _phone, onTap: () {}),
      _divider(),
      _tile(Icons.email_outlined, _email, onTap: () {}),
    ]);
  }

  Widget _tile(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: _isDarkMode ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: _kAccentDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 15, color: _subTextColor.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFE0533D).withValues(alpha: _isDarkMode ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE0533D).withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE0533D)),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE0533D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lang {
  const _Lang(this.code, this.label, this.flag);
  final String code, label, flag;
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({
    required this.languages,
    required this.current,
    required this.isDark,
    required this.onSelect,
  });

  final List<_Lang> languages;
  final String current;
  final bool isDark;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final sheetColor = isDark ? AppColors.espressoSoft : Colors.white;
    final textColor = isDark ? AppColors.cream : const Color(0xFF161618);
    final subColor = isDark ? AppColors.muted : const Color(0xFF8A8A8A);
    final fieldBorder = isDark ? AppColors.glassBorder : const Color(0xFFE8E4DE);
    final tileBg = isDark ? AppColors.glass : const Color(0xFFF5F3EF);

    return Container(
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: subColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.language_rounded, color: _kAccent, size: 22),
              const SizedBox(width: 10),
              Text(
                'Choose language',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...languages.map((lang) {
            final selected = lang.code == current;
            return GestureDetector(
              onTap: () => onSelect(lang.code),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? _kAccent.withValues(alpha: isDark ? 0.16 : 0.10)
                      : tileBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? _kAccent.withValues(alpha: 0.5) : fieldBorder,
                    width: selected ? 1.4 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        lang.label,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: _kAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 16, color: Color(0xFF2C1810)),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}