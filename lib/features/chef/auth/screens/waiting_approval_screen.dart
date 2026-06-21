import 'package:flutter/material.dart';

const _kAccent = Color(0xFFE8A838);

class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildStepList(),
                  const SizedBox(height: 24),
                  _buildDoneButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE8E4DE).withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF1A1410),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(width: 4),
          Text(
            'Application Status',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1410),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All done!',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1410),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '6 of 6 steps completed',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B6258),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1,
            minHeight: 5,
            backgroundColor: const Color(0xFFE8E4DE),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kAccent.withValues(alpha: 0.12),
            _kAccent.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _kAccent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Transform.scale(
              scale: _pulse.value,
              child: child,
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                color: _kAccent,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Under Review',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1410),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Waiting for Admin Approval',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _kAccent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Thank you for completing all steps. Our team is reviewing your information. You will be notified once your kitchen is approved.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6258),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepList() {
    const steps = [
      ('Choose items Chief can make', Icons.restaurant_menu),
      ('Choose address', Icons.location_on),
      ('Upload Health certificate', Icons.medical_services),
      ('Upload National ID', Icons.badge),
      ('Upload Payment method', Icons.payment),
      ('Waiting for Admin Approval', Icons.hourglass_empty),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Icon(steps[i].$2, size: 18, color: const Color(0xFF6B6258)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  steps[i].$1,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1410),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDoneButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          foregroundColor: const Color(0xFF2C1810),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Back to Dashboard',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
