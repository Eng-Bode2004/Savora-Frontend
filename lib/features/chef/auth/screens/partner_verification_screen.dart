import 'package:flutter/material.dart';
import 'package:savora_app/features/chef/auth/screens/verification_theme.dart';
import 'package:savora_app/features/chef/auth/screens/Select%20Specialized%20Categories.dart';
import 'location_selection_screen.dart';
import 'health_certificate_screen.dart';
import 'id_photo_screen.dart';
import 'payment_method_screen.dart';
import 'waiting_approval_screen.dart';


class PartnerVerificationScreen extends StatefulWidget {
  const PartnerVerificationScreen({super.key});

  @override
  State<PartnerVerificationScreen> createState() =>
      _PartnerVerificationScreenState();
}

class _PartnerVerificationScreenState
    extends State<PartnerVerificationScreen> with TickerProviderStateMixin {
  final List<_StepState> _steps = [
    _StepState(label: 'Choose items Chief can make', icon: Icons.restaurant_menu),
    _StepState(label: 'Choose address', icon: Icons.location_on),
    _StepState(label: 'Upload Health certificate', icon: Icons.medical_services),
    _StepState(label: 'Upload National ID', icon: Icons.badge),
    _StepState(label: 'Upload Payment method', icon: Icons.payment),
    _StepState(label: 'Waiting for Admin Approval', icon: Icons.hourglass_empty),
  ];

  int _currentStep = 0;

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    if (index < 0 || index >= _steps.length) return;
    if (index > 0 && !_steps[index - 1].completed) return;
    setState(() => _currentStep = index);
    _openStepScreen(index);
  }

  Future<void> _openStepScreen(int index) async {
    switch (index) {
      case 0:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SelectSpecializedCategories(),
          ),
        );
        if (result == true && mounted) {
          setState(() => _steps[0].completed = true);
          _advanceIfReady();
        }
        break;
      case 1:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LocationSelectionScreen(),
          ),
        );
        if (result == true && mounted) {
          setState(() => _steps[1].completed = true);
          _advanceIfReady();
        }
        break;
      case 2:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HealthCertificateScreen(),
          ),
        );
        if (result == true && mounted) {
          setState(() => _steps[2].completed = true);
          _advanceIfReady();
        }
        break;
      case 3:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const IdPhotoScreen(),
          ),
        );
        if (result == true && mounted) {
          setState(() => _steps[3].completed = true);
          _advanceIfReady();
        }
        break;
      case 4:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PaymentMethodScreen(),
          ),
        );
        if (result == true && mounted) {
          setState(() => _steps[4].completed = true);
          _advanceIfReady();
        }
        break;
      case 5:
        _steps[5].completed = true;
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WaitingApprovalScreen(),
            ),
          );
        }
        break;
    }
  }

  void _advanceIfReady() {
    if (_currentStep < _steps.length - 1 &&
        _steps[_currentStep].completed) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _currentStep = _currentStep + 1);
        }
      });
    }
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
                  _buildStepList(),
                  const SizedBox(height: 28),
                  _buildContinueButton(),
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Text(
            'Verification',
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
    final completedCount = _steps.where((s) => s.completed).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete your profile',
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
          '$completedCount of ${_steps.length} steps completed',
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
            value: completedCount / _steps.length,
            minHeight: 5,
            backgroundColor: const Color(0xFFE8E4DE),
            valueColor: const AlwaysStoppedAnimation(kVfAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildStepList() {
    return Column(
      children: List.generate(_steps.length, (i) {
        final step = _steps[i];
        final isCurrent = i == _currentStep;
        final isCompleted = step.completed;
        final isLocked = i > 0 && !_steps[i - 1].completed;
        final canTap = !isLocked && !isCompleted;

        return GestureDetector(
          onTap: canTap ? () => _goToStep(i) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isCurrent
                  ? kVfAccent.withValues(alpha: 0.07)
                  : isCompleted
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.05)
                      : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent
                    ? kVfAccent
                    : isCompleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE8E4DE),
                width: isCurrent || isCompleted ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildStepIndicator(i, isCurrent, isCompleted, isLocked),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.label,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14,
                                fontWeight:
                                    isCurrent ? FontWeight.w700 : FontWeight.w600,
                                color: isLocked
                                    ? const Color(0xFFC9BFB0)
                                    : const Color(0xFF1A1410),
                              ),
                            ),
                          ),
                          if (isCompleted)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF4CAF50), size: 20),
                          if (isCurrent && !isCompleted)
                            _AnimatedHand(bounce: _bounce),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepIndicator(
      int index, bool isCurrent, bool isCompleted, bool isLocked) {
    if (isCompleted) {
      return Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
      );
    }
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isCurrent ? kVfAccent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent
              ? kVfAccent
              : isLocked
                  ? const Color(0xFFE8E4DE)
                  : const Color(0xFFC9BFB0),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isCurrent
                ? Colors.white
                : isLocked
                    ? const Color(0xFFC9BFB0)
                    : const Color(0xFF6B6258),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final current = _currentStep;
    final allDone = _steps.every((s) => s.completed);

    if (allDone) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WaitingApprovalScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'All steps completed — View status',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _goToStep(current),
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: Text(
          _steps[current].completed
              ? 'Next step'
              : 'Continue — Step ${current + 1}',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kVfAccent,
          foregroundColor: const Color(0xFF2C1810),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}



class _AnimatedHand extends StatelessWidget {
  const _AnimatedHand({required this.bounce});

  final Animation<double> bounce;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bounce,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, bounce.value),
        child: child,
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.touch_app_rounded, color: kVfAccent, size: 22),
      ),
    );
  }
}

class _StepState {
  _StepState({required this.label, required this.icon});

  final String label;
  final IconData icon;
  bool completed = false;
}
