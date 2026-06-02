import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import 'track_order_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _progress;

  late int _tabIndex;

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  // ── active order data ──
  static const _kitchenName = "Grandma's Kitchen";
  static const _orderNo = 'Order #SVG-90210';
  static const _eta = '25–35';
  static const _progressValue = 0.65;
  static const _activeStep = 1;

  static const List<_Step> _steps = [
    _Step('Placed', Icons.check_circle_rounded),
    _Step('Cooking', Icons.soup_kitchen_rounded),
    _Step('Pickup', Icons.shopping_bag_rounded),
    _Step('Arrival', Icons.home_rounded),
  ];

  // ── history data ──
  static const List<_PastOrder> _history = [
    _PastOrder("Mama's Mahshi", '12 Oct 2023, 14:30', '#SVG-89210', 180,
        Color(0xFF6B3410), '🍲'),
    _PastOrder('The Grill Hub', '08 Oct 2023, 20:15', '#SVG-89004', 345,
        Color(0xFF7A2E1E), '🍢'),
    _PastOrder('Pizza Palazzo', '05 Oct 2023, 13:05', '#SVG-88762', 210,
        Color(0xFFC25A2E), '🍕'),
  ];

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _progress.dispose();
    super.dispose();
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

  // ── theme ──
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
                  animation: Listenable.merge([_entrance, _progress]),
                  builder: (context, _) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _reveal(0.0, 0.25, _buildTopBar()),
                            const SizedBox(height: 22),
                            _reveal(0.05, 0.32, _buildTabs()),
                            const SizedBox(height: 24),
                            if (_tabIndex == 0)
                              ..._buildActiveTab()
                            else
                              ..._buildHistoryTab(),
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

  // ════════ BACKGROUND ════════
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

  // ════════ TOP BAR ════════
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
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _fieldBgColor,
                child: Icon(Icons.person_rounded, size: 18, color: _subTextColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════ TABS — Active / History (segmented) ════════
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _fieldBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
      ),
      child: Row(
        children: [
          _segTab('Active', 0),
          _segTab('History', 1),
        ],
      ),
    );
  }

  Widget _segTab(String label, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _tabIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
                : null,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? const Color(0xFF2C1810) : _subTextColor,
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // ACTIVE TAB
  // ════════════════════════════════════════════
  List<Widget> _buildActiveTab() {
    return [
      _reveal(0.12, 0.40, _buildOngoingHeader()),
      const SizedBox(height: 14),
      _reveal(0.20, 0.60, _buildOrderCard()),
    ];
  }

  Widget _buildOngoingHeader() {
    return Row(
      children: [
        Text(
          'Ongoing Order',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '1 Active',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kAccentDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('🍲', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kitchenName,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _orderNo,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _eta,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _kAccentDark,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'min',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kAccentDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Est. Arrival',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: _subTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: _fieldBorderColor, height: 1, thickness: 0.5),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Preparing your meal',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              const Spacer(),
              Text(
                '${(_progressValue * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepTracker(),
          const SizedBox(height: 22),
          _buildTrackButton(),
        ],
      ),
    );
  }

  Widget _buildStepTracker() {
    final animated = _progressValue * _progress.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const dotSize = 34.0;
        final segment = (width - dotSize) / (_steps.length - 1);

        return Column(
          children: [
            SizedBox(
              height: dotSize,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: dotSize / 2,
                    right: dotSize / 2,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: _fieldBorderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: dotSize / 2,
                    child: Container(
                      height: 3,
                      width: (width - dotSize) * animated,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kAccentLight, _kAccentDark]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  for (int i = 0; i < _steps.length; i++)
                    Positioned(
                      left: i * segment,
                      child: _buildStepDot(i, dotSize),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < _steps.length; i++)
                  Expanded(
                    child: Text(
                      _steps[i].label,
                      textAlign: i == 0
                          ? TextAlign.start
                          : i == _steps.length - 1
                              ? TextAlign.end
                              : TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight:
                            i <= _activeStep ? FontWeight.w700 : FontWeight.w500,
                        color: i <= _activeStep ? _textColor : _subTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepDot(int index, double size) {
    final done = index < _activeStep;
    final active = index == _activeStep;
    final reached = index <= _activeStep;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: reached
            ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
            : null,
        color: reached ? null : _cardColor,
        border: Border.all(
          color: reached ? Colors.transparent : _fieldBorderColor,
          width: 1.5,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _kAccent.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        done ? Icons.check_rounded : _steps[index].icon,
        size: 17,
        color: reached ? const Color(0xFF2C1810) : _subTextColor,
      ),
    );
  }

  Widget _buildTrackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TrackOrderScreen(),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.8, -1.0),
            end: Alignment(0.8, 1.0),
            colors: [_kAccentLight, _kAccent, _kAccentDark],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: -4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF2C1810)),
            SizedBox(width: 8),
            Text(
              'Track Order',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C1810),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // HISTORY TAB
  // ════════════════════════════════════════════
  List<Widget> _buildHistoryTab() {
    return [
      for (int i = 0; i < _history.length; i++) ...[
        _reveal(0.10 + i * 0.06, 0.50 + i * 0.06, _buildHistoryCard(_history[i])),
        const SizedBox(height: 14),
      ],
      const SizedBox(height: 8),
      _reveal(0.40, 0.85, _buildPromoCard()),
    ];
  }

  Widget _buildHistoryCard(_PastOrder o) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/${o.name}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [o.tone, o.tone.withValues(alpha: 0.65)],
                      ),
                    ),
                    child: Center(
                        child: Text(o.emoji, style: const TextStyle(fontSize: 26))),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.name,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${o.date} · ${o.orderNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // delivered badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF35A853).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Delivered',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF35A853),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: _fieldBorderColor, height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'EGP ${o.price}',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kAccentDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TrackOrderScreen(),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_kAccentLight, _kAccentDark]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF2C1810)),
                      SizedBox(width: 6),
                      Text(
                        'Reorder',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kAccent.withValues(alpha: _isDarkMode ? 0.22 : 0.16),
            _kAccent.withValues(alpha: _isDarkMode ? 0.10 : 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kAccent.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missing your favorites?',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get 15% off on your next reorder today!',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: _subTextColor,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => HapticFeedback.mediumImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Claim Now',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C1810),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════
class _Step {
  const _Step(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _PastOrder {
  const _PastOrder(
      this.name, this.date, this.orderNo, this.price, this.tone, this.emoji);
  final String name, date, orderNo;
  final int price;
  final Color tone;
  final String emoji;
}
