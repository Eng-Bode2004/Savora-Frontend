import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  late List<_Notif> _today = [
    _Notif(
      _NotifType.order,
      'Order Update',
      "Your order from Grandma's Kitchen is being prepared!",
      '2 mins ago',
      tag: 'New',
      tagColor: _kAccent,
      unread: true,
    ),
    _Notif(
      _NotifType.promo,
      'Promotion',
      'Flash Sale! Get 20% off on all dessert items today.',
      '1 hour ago',
      tag: 'Limited Time',
      tagColor: const Color(0xFFE0533D),
      unread: true,
    ),
  ];

  late List<_Notif> _yesterday = [
    _Notif(
      _NotifType.delivery,
      'Delivery',
      "Order #SVG-89210 from Mama's Mahshi was delivered. How was your meal?",
      '14:35',
      action: 'Leave a Review',
    ),
    _Notif(
      _NotifType.system,
      'System Alert',
      "New payment method 'Visa •••• 4421' added successfully.",
      '10:15',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
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

  void _markAllRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in [..._today, ..._yesterday]) {
        n.unread = false;
      }
    });
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
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: _reveal(0.0, 0.25, _buildTopBar()),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _reveal(0.08, 0.34, _buildDayLabel('Today')),
                                  const SizedBox(height: 10),
                                  for (int i = 0; i < _today.length; i++) ...[
                                    _reveal(0.12 + i * 0.05, 0.50 + i * 0.05,
                                        _buildNotifCard(_today[i])),
                                    const SizedBox(height: 12),
                                  ],
                                  const SizedBox(height: 12),
                                  _reveal(0.28, 0.52, _buildDayLabel('Yesterday')),
                                  const SizedBox(height: 10),
                                  for (int i = 0; i < _yesterday.length; i++) ...[
                                    _reveal(0.34 + i * 0.05, 0.70 + i * 0.05,
                                        _buildNotifCard(_yesterday[i])),
                                    const SizedBox(height: 12),
                                  ],
                                  const SizedBox(height: 20),
                                  _reveal(0.55, 0.95, _buildFooter()),
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
          'Notifications',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _markAllRead,
          child: const Text(
            'Mark all as read',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kAccentDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _subTextColor,
      ),
    );
  }

  Widget _buildNotifCard(_Notif n) {
    final accent = _typeColor(n.type);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (n.unread) setState(() => n.unread = false);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 14,
              spreadRadius: -4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: n.unread
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_kAccentLight, _kAccentDark],
                        )
                      : null,
                  color: n.unread ? null : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: _isDarkMode ? 0.20 : 0.13),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_typeIcon(n.type), size: 21, color: accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: _textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  n.time,
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 11,
                                    color: _subTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.body,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12.5,
                                height: 1.4,
                                color: _subTextColor,
                              ),
                            ),
                            if (n.tag != null) ...[
                              const SizedBox(height: 8),
                              _buildTag(n.tag!, n.tagColor!),
                            ],
                            if (n.action != null) ...[
                              const SizedBox(height: 10),
                              _buildActionButton(n.action!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label) {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _fieldBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kAccentDark,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _fieldBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: _fieldBorderColor, width: 0.5),
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 24, color: _subTextColor),
          ),
          const SizedBox(height: 10),
          Text(
            'End of recent updates',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: _subTextColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(_NotifType t) {
    switch (t) {
      case _NotifType.order:
        return Icons.shopping_bag_rounded;
      case _NotifType.promo:
        return Icons.local_offer_rounded;
      case _NotifType.delivery:
        return Icons.check_circle_rounded;
      case _NotifType.system:
        return Icons.info_rounded;
    }
  }

  Color _typeColor(_NotifType t) {
    switch (t) {
      case _NotifType.order:
        return _kAccent;
      case _NotifType.promo:
        return const Color(0xFFE0533D);
      case _NotifType.delivery:
        return const Color(0xFF35A853);
      case _NotifType.system:
        return const Color(0xFF4A90D9);
    }
  }
}

enum _NotifType { order, promo, delivery, system }

class _Notif {
  _Notif(
    this.type,
    this.title,
    this.body,
    this.time, {
    this.tag,
    this.tagColor,
    this.action,
    this.unread = false,
  });

  final _NotifType type;
  final String title;
  final String body;
  final String time;
  final String? tag;
  final Color? tagColor;
  final String? action;
  bool unread;
}
