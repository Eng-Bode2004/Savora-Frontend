import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/core/theme/theme_notifier.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/localization/app_localizations.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.orderId, this.driverId});

  final String orderId;
  final String? driverId;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _orderRating = 0;
  int _driverRating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.espressoSoft : Colors.white;
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor => _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_orderRating == 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate your order')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await SavoraApi.submitOrderRating(
        widget.orderId,
        rating: _orderRating,
        driverRating: _driverRating > 0 ? _driverRating : null,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      );
      if (!context.mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      Navigator.of(context).maybePop(true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    } finally {
      if (context.mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: _textColor),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Rate Your Experience',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              // ── Order Rating ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _fieldBorderColor, width: 0.5),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.restaurant_rounded, color: Color(0xFF2C1810), size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'How was your order?',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap a star to rate the food quality',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: _subTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StarRow(
                      rating: _orderRating,
                      onChanged: (v) => setState(() => _orderRating = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Driver Rating ──
              if (widget.driverId != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _fieldBorderColor, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _fieldBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _fieldBorderColor),
                        ),
                        child: Icon(Icons.local_shipping, color: _kAccentDark, size: 30),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'How was your driver?',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rate your delivery experience',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: _subTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StarRow(
                        rating: _driverRating,
                        onChanged: (v) => setState(() => _driverRating = v),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // ── Comment ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _fieldBorderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Feedback',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 500,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: _textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tell us about your experience...',
                        hintStyle: TextStyle(color: _subTextColor),
                        filled: true,
                        fillColor: _fieldBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _fieldBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _fieldBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _kAccent),
                        ),
                        counterStyle: TextStyle(color: _subTextColor, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: const Color(0xFF2C1810),
                    disabledBackgroundColor: _subTextColor.withOpacity(0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF2C1810),
                          ),
                        )
                      : const Text(
                          'Submit Rating',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
}

class _StarRow extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _StarRow({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(i + 1);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.elasticOut,
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                size: 40,
                color: filled ? _kAccent : _kAccent.withOpacity(0.3),
              ),
            ),
          ),
        );
      }),
    );
  }
}
