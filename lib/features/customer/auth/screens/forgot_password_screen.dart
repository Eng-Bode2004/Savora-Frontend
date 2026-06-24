import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/savora_api.dart';
import 'otp_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _identifierFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  // State machine: identifier → otp → new password
  String? _userId;
  bool _otpVerified = false;
  bool _showNewPassword = false;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF161618);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor => _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);

  @override
  void dispose() {
    _identifierController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      _showError('Please enter your email or phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await SavoraApi.forgotPassword(identifier);
      final data = result['data'] as Map<String, dynamic>?;
      final userId = data?['userId'] as String?;
      if (userId == null) throw Exception('Failed to get user ID');

      final isEmail = identifier.contains('@');

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            contact: identifier,
            userId: userId,
            isDarkMode: _isDarkMode,
            viaEmail: isEmail,
            onVerified: () {
              // Pop back to this screen, now show new password fields
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ).then((verified) {
        if (verified == true && mounted) {
          setState(() {
            _userId = userId;
            _otpVerified = true;
            _showNewPassword = true;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (newPassword != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SavoraApi.resetPassword(_userId!, newPassword);
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'DM Sans')),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: _fieldBorderColor),
                    ),
                    child: Icon(Icons.arrow_back_rounded, color: _textColor, size: 20),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _showNewPassword ? 'Set New Password' : 'Reset Password',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showNewPassword
                      ? 'Enter your new password'
                      : 'Enter your email or phone number to receive a verification code',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: _subTextColor,
                  ),
                ),
                const SizedBox(height: 32),

                if (!_showNewPassword) ...[
                  _buildTextField(
                    controller: _identifierController,
                    focusNode: _identifierFocus,
                    hint: 'Email or phone number',
                    icon: Icons.email_outlined,
                    isPassword: false,
                  ),
                  const SizedBox(height: 24),
                  _buildButton(
                    label: 'Send Verification Code',
                    isLoading: _isLoading,
                    onTap: _sendOtp,
                  ),
                ],

                if (_showNewPassword) ...[
                  _buildTextField(
                    controller: _newPasswordController,
                    focusNode: _passwordFocus,
                    hint: 'New password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmFocus,
                    hint: 'Confirm new password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  _buildButton(
                    label: 'Reset Password',
                    isLoading: _isLoading,
                    onTap: _resetPassword,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isPassword,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _fieldBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? _kAccent.withValues(alpha: 0.55) : _fieldBorderColor,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [BoxShadow(color: _kAccent.withValues(alpha: 0.16), blurRadius: 14, spreadRadius: 1)]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? (hint.contains('New') || hint.contains('Confirm') ? _obscurePassword : false) : false,
        style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _textColor),
        cursorColor: _kAccent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _subTextColor.withValues(alpha: 0.6)),
          prefixIcon: Icon(icon, size: 20, color: focused ? _kAccent : _subTextColor.withValues(alpha: 0.5)),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () => setState(() {
                    if (hint.contains('Confirm')) {
                      _obscureConfirm = !_obscureConfirm;
                    } else {
                      _obscurePassword = !_obscurePassword;
                    }
                  }),
                  child: Icon(
                    (hint.contains('Confirm') ? _obscureConfirm : _obscurePassword)
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20, color: _subTextColor.withValues(alpha: 0.5),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kAccentLight, _kAccent, _kAccentDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: -4, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C1810))))
              : Text(label, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2C1810), letterSpacing: 0.3)),
        ),
      ),
    );
  }
}