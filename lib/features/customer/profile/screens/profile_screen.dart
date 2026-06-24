import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/savora_api.dart';
import '../../../../state/providers/auth_provider.dart';
import '../../../customer/auth/screens/splash_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;

  bool _notifications = true;
  bool _isLoading = true;
  late bool _isDarkMode;

  String _userName = '';
  String _userEmail = '';
  String? _userAvatar;
  String? _profileId;

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
    _isDarkMode = themeModeNotifier.value == ThemeMode.dark;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    themeModeNotifier.addListener(_onThemeChange);
    _loadProfile();
  }

  @override
  void dispose() {
    _entrance.dispose();
    themeModeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() {
    if (mounted) {
      setState(() => _isDarkMode = themeModeNotifier.value == ThemeMode.dark);
    }
  }

  Future<void> _loadProfile() async {
    final authId = authState.userId;
    if (authId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await SavoraApi.getCustomerProfileByAuthId(authId);
      final profile = res['response'] as Map<String, dynamic>? ?? res;
      _userName = profile['name'] as String? ?? '';
      _userEmail = profile['email'] as String? ?? '';
      _userAvatar = profile['avatar'] as String?;
      _profileId = profile['_id'] as String? ?? profile['id'] as String?;
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    try {
      final uploaded = await SavoraApi.uploadCustomerProfileImage(bytes, picked.name);
      final imageUrl = uploaded['url'] as String?;
      if (imageUrl != null && _profileId != null) {
        await SavoraApi.updateCustomerProfile(profileId: _profileId!, data: {'avatar': imageUrl});
        setState(() => _userAvatar = imageUrl);
      }
    } catch (_) {}
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
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
                  color: _subTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.edit_rounded, color: _kAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Edit Name',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: TextStyle(color: _textColor, fontFamily: 'DM Sans'),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: _subTextColor, fontFamily: 'DM Sans'),
                  filled: true,
                  fillColor: _fieldBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(fontFamily: 'DM Sans', color: _subTextColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = controller.text.trim();
                        if (newName.isEmpty || _profileId == null) return;
                        try {
                          await SavoraApi.updateCustomerProfile(profileId: _profileId!, data: {'name': newName});
                          setState(() => _userName = newName);
                        } catch (_) {}
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccent,
                        foregroundColor: const Color(0xFF2C1810),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700)),
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

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(feature, style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700)),
        content: Text('$feature is coming soon!', style: TextStyle(fontFamily: 'DM Sans', color: _subTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600, color: _kAccent)),
          ),
        ],
      ),
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

  void _toggleDarkMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDarkMode = !_isDarkMode;
      themeModeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
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

  void _logout() {
    HapticFeedback.mediumImpact();
    authState.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
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
        body: Center(child: CircularProgressIndicator(color: _kAccent)),
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
                            _reveal(0.12, 0.40, _buildSectionLabel('My Account')),
                            const SizedBox(height: 10),
                            _reveal(0.16, 0.48, _buildAccountSection()),
                            const SizedBox(height: 24),
                            _reveal(0.24, 0.52, _buildSectionLabel('Preferences')),
                            const SizedBox(height: 10),
                            _reveal(0.28, 0.60, _buildPreferencesSection(l)),
                            const SizedBox(height: 24),
                            _reveal(0.36, 0.64, _buildSectionLabel('Support')),
                            const SizedBox(height: 10),
                            _reveal(0.40, 0.72, _buildSupportSection()),
                            const SizedBox(height: 24),
                            _reveal(0.50, 0.85, _buildLogoutButton()),
                            const SizedBox(height: 14),
                            _reveal(0.55, 0.90, _buildVersion()),
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
          onTap: _toggleDarkMode,
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
        Stack(
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
                child: _userAvatar != null
                    ? Image.network(_userAvatar!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarPlaceholder())
                    : _avatarPlaceholder(),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: GestureDetector(
                onTap: _pickAndUploadAvatar,
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
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _userName.isEmpty ? 'User' : _userName,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _userEmail.isEmpty ? (authState.email ?? '') : _userEmail,
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

  Widget _buildAccountSection() {
    return _card([
      _tile(Icons.person_outline_rounded, 'Edit Profile', onTap: _editName),
      _divider(),
      _tile(Icons.location_on_outlined, 'Saved Addresses', onTap: () => _showComingSoon('Saved Addresses')),
      _divider(),
      _tile(Icons.credit_card_rounded, 'Payment Methods', onTap: () => _showComingSoon('Payment Methods')),
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
          onChanged: (_) => _toggleDarkMode(),
        ),
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _card([
      _tile(Icons.help_outline_rounded, 'Help Center', onTap: () {}),
      _divider(),
      _tile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
      _divider(),
      _tile(Icons.description_outlined, 'Terms of Service', onTap: () {}),
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

  Widget _buildVersion() {
    return Center(
      child: Text(
        'Savora v1.0.0 \u00B7 Made with \u2665 in Cairo',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 11,
          color: _subTextColor.withValues(alpha: 0.7),
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