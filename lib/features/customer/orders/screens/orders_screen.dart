import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/savora_api.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../state/providers/auth_provider.dart';
import 'track_order_screen.dart';
import 'rating_screen.dart';

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

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  // ── real order data ──
  List<Map<String, dynamic>> _orders = [];
  bool _loadingOrders = true;
  String? _orderError;

  static const List<_Step> _steps = [
    _Step('Placed', Icons.check_circle_rounded),
    _Step('Cooking', Icons.soup_kitchen_rounded),
    _Step('Pickup', Icons.shopping_bag_rounded),
    _Step('Arrival', Icons.home_rounded),
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
    _loadOrders();
    themeModeNotifier.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    themeModeNotifier.removeListener(_onThemeChange);
    _entrance.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onThemeChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadOrders() async {
    final uid = authState.userId;
    if (uid == null) return;
    try {
      final data = await SavoraApi.getCustomerOrders(uid);
      setState(() {
        _orders = List<Map<String, dynamic>>.from(data['orders'] ?? []);
        _loadingOrders = false;
      });
    } catch (e) {
      setState(() {
        _orderError = e.toString();
        _loadingOrders = false;
      });
    }
  }

  Map<String, dynamic>? get _activeOrder {
    final active = _orders.where((o) {
      final s = (o['order_status'] as String?) ?? '';
      return !['completed', 'cancelled'].contains(s);
    }).toList();
    active.sort((a, b) {
      final da = DateTime.tryParse(a['createdAt'] as String? ?? '') ?? DateTime(2000);
      final db = DateTime.tryParse(b['createdAt'] as String? ?? '') ?? DateTime(2000);
      return db.compareTo(da);
    });
    return active.isNotEmpty ? active.first : null;
  }

  List<Map<String, dynamic>> get _pastOrders {
    final past = _orders.where((o) {
      final s = (o['order_status'] as String?) ?? '';
      return ['completed', 'cancelled'].contains(s);
    }).toList();
    past.sort((a, b) {
      final da = DateTime.tryParse(a['createdAt'] as String? ?? '') ?? DateTime(2000);
      final db = DateTime.tryParse(b['createdAt'] as String? ?? '') ?? DateTime(2000);
      return db.compareTo(da);
    });
    return past;
  }

  // Helper: order status → step index
  int _statusToStep(String status) {
    switch (status) {
      case 'accepted':
        return 1;
      case 'preparing':
        return 1;
      case 'ready':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
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
    if (_loadingOrders) {
      return [
        const SizedBox(height: 80),
        Center(
          child: CircularProgressIndicator(color: _kAccentDark),
        ),
      ];
    }
    if (_orderError != null) {
      return [
        const SizedBox(height: 80),
        Center(
          child: GestureDetector(
            onTap: _loadOrders,
            child: Column(
              children: [
                Icon(Icons.error_outline, color: _subTextColor, size: 40),
                const SizedBox(height: 8),
                Text('Tap to retry', style: TextStyle(color: _subTextColor)),
              ],
            ),
          ),
        ),
      ];
    }
    final order = _activeOrder;
    if (order == null) {
      return [
        _reveal(0.12, 0.40, _buildOngoingHeader()),
        const SizedBox(height: 14),
        _reveal(0.20, 0.60, _buildEmptyOrders()),
      ];
    }
    return [
      _reveal(0.12, 0.40, _buildOngoingHeader()),
      const SizedBox(height: 14),
      _reveal(0.20, 0.60, _buildOrderCard(order)),
    ];
  }

  int get _activeCount => _orders.where((o) {
    final s = (o['order_status'] as String?) ?? '';
    return !['completed', 'cancelled'].contains(s);
  }).length;

  Widget _buildEmptyOrders() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_rounded, size: 48, color: _subTextColor),
          const SizedBox(height: 12),
          Text('No active orders',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, color: _subTextColor)),
          const SizedBox(height: 4),
          Text('Browse dishes and place your first order!',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: _subTextColor)),
        ],
      ),
    );
  }

  Widget _buildOngoingHeader() {
    final count = _activeCount;
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
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count Active',
              style: const TextStyle(
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final firstItem = items.isNotEmpty ? items.first : <String, dynamic>{};
    final name = (firstItem['name'] as String?) ?? 'Order';
    final orderNo = order['_id'] as String? ?? '';
    final shortId = orderNo.length > 8 ? orderNo.substring(orderNo.length - 8).toUpperCase() : orderNo;
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final status = (order['order_status'] as String?) ?? 'pending';
    final step = _statusToStep(status);
    final progress = (step + 1) / _steps.length;
    final statusLabels = {
      'pending': 'Pending approval',
      'accepted': 'Preparing your meal',
      'preparing': 'Preparing your meal',
      'ready': 'Ready for pickup',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
    };
    final statusLabel = statusLabels[status] ?? status;

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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#$shortId',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: _fieldBorderColor, height: 1, thickness: 0.5),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                statusLabel,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
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
          _buildStepTracker(step, progress),
          const SizedBox(height: 22),
          _buildTrackButton(),
        ],
      ),
    );
  }

  Widget _buildStepTracker(int activeStep, double progressValue) {
    final animated = progressValue * _progress.value;

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
                      child: _buildStepDot(i, dotSize, activeStep),
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
                            i <= activeStep ? FontWeight.w700 : FontWeight.w500,
                        color: i <= activeStep ? _textColor : _subTextColor,
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

  Widget _buildStepDot(int index, double size, int activeStep) {
    final done = index < activeStep;
    final active = index == activeStep;
    final reached = index <= activeStep;

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
    if (_loadingOrders) {
      return [
        const SizedBox(height: 80),
        Center(
          child: CircularProgressIndicator(color: _kAccentDark),
        ),
      ];
    }
    final past = _pastOrders;
    if (past.isEmpty) {
      return [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 48, color: _subTextColor),
              const SizedBox(height: 12),
              Text('No past orders yet',
                  style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, color: _subTextColor)),
            ],
          ),
        ),
      ];
    }
    return [
      for (int i = 0; i < past.length; i++) ...[
        _reveal(0.10 + i * 0.06, 0.50 + i * 0.06, _buildHistoryCard(past[i])),
        const SizedBox(height: 14),
      ],
      const SizedBox(height: 8),
      _reveal(0.40, 0.85, _buildPromoCard()),
    ];
  }

  Widget _buildHistoryCard(Map<String, dynamic> order) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final firstItem = items.isNotEmpty ? items.first : <String, dynamic>{};
    final name = (firstItem['name'] as String?) ?? 'Order';
    final orderNo = order['_id'] as String? ?? '';
    final shortId = orderNo.length > 8 ? orderNo.substring(orderNo.length - 8).toUpperCase() : orderNo;
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final createdAt = order['createdAt'] as String? ?? '';
    final dateStr = createdAt.isNotEmpty
        ? createdAt.substring(0, 10).split('-').reversed.join('/')
        : '';
    final status = (order['order_status'] as String?) ?? '';
    final isCancelled = status == 'cancelled';
    final badgeColor = isCancelled ? const Color(0xFFD32F2F) : const Color(0xFF35A853);
    final badgeLabel = isCancelled ? 'Cancelled' : 'Delivered';

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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kAccent, _kAccentDark],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('🍽', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$dateStr · #$shortId',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
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
                'EGP ${total.toInt()}',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kAccentDark,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (order['rating'] == null && !isCancelled)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RatingScreen(
                              orderId: orderNo,
                              driverId: order['driver_id'] as String?,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
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
                            Icon(Icons.star_rounded, size: 16, color: Color(0xFF2C1810)),
                            SizedBox(width: 6),
                            Text(
                              'Rate',
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
                  if (order['rating'] == null && !isCancelled)
                    const SizedBox(width: 8),
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
                        gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
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
