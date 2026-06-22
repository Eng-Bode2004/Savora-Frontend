import 'package:flutter/material.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';
import 'package:savora_app/features/chef/auth/screens/location_setup_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kBackground = Color(0xFFF8F6F2);
const _kWhite = Colors.white;
const _kDarkText = Color(0xFF1A1410);
const _kMutedText = Color(0xFF6B6258);
const _kBorder = Color(0xFFE8E4DE);

class CustomerVerificationScreen extends StatefulWidget {
  const CustomerVerificationScreen({super.key});

  @override
  State<CustomerVerificationScreen> createState() =>
      _CustomerVerificationScreenState();
}

class _CustomerVerificationScreenState
    extends State<CustomerVerificationScreen> with TickerProviderStateMixin {
  final List<_StepState> _steps = [
    _StepState(label: 'Add payment method', icon: Icons.payment),
    _StepState(label: 'Enter your address', icon: Icons.location_on),
    _StepState(label: 'Select food you prefer', icon: Icons.restaurant_menu),
  ];

  int _currentStep = 0;
  bool _loadingStatus = true;

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
    _loadStepStatuses();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStepStatuses() async {
    final profileId = authState.profileId;
    if (profileId == null) {
      if (mounted) setState(() => _loadingStatus = false);
      return;
    }
    try {
      final data = await SavoraApi.getCustomerProfileByAuthId(authState.userId!);
      final profile = data['response'] as Map<String, dynamic>?;
      if (profile == null) {
        if (mounted) setState(() => _loadingStatus = false);
        return;
      }
      if (profile['Is_Payment_Method_Verified'] == true) {
        _steps[0].completed = true;
      }
      if (profile['Is_Address_Verified'] == true) {
        _steps[1].completed = true;
      }
      if (profile['IS_Favorite_Items_Verified'] == true) {
        _steps[2].completed = true;
      }
      if (mounted) setState(() => _loadingStatus = false);
    } catch (_) {
      if (mounted) setState(() => _loadingStatus = false);
    }
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
        final providerName = await _showProviderPicker();
        if (providerName == null || !mounted) return;
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _PaymentDetailScreen(providerName: providerName),
          ),
        );
        if (success == true && mounted) {
          setState(() => _steps[0].completed = true);
          _advanceIfReady();
        }
        break;
      case 1:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LocationSetupScreen(),
          ),
        );
        if (result != null && mounted) {
          final profileId = authState.profileId;
          if (profileId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile ID not found'), backgroundColor: Colors.red),
            );
            break;
          }
          final details = (result['addressDetails'] as String?) ?? '';
          final parts = details.split(',');
          final addressData = {
            'Profile_id': profileId,
            'longitude': result['longitude'],
            'latitude': result['latitude'],
            'city': parts.isNotEmpty ? parts[0].trim() : '',
            'country': parts.length > 1 ? parts.last.trim() : '',
            'street': (result['addressName'] as String?) ?? '',
            'label': (result['addressName'] as String?) ?? '',
            'address_type': 'home',
            'is_primary': true,
          };
          try {
            await SavoraApi.createAddress(addressData);
            await SavoraApi.updateCustomerVerificationStep(
              profileId: profileId,
              step: 'address',
            );
            if (mounted) {
              setState(() => _steps[1].completed = true);
              _advanceIfReady();
            }
          } catch (e) {
            if (mounted) {
              final msg = e.toString().replaceFirst("Exception: ", "");
              final isOutsideZone = msg.toLowerCase().contains("outside all service areas") ||
                  msg.toLowerCase().contains("outside all service");
              if (isOutsideZone) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('This location is outside our service area. Please choose a location within a supported zone.', style: TextStyle(fontFamily: 'DM Sans', fontSize: 14)),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFE65100),
                    duration: const Duration(seconds: 6),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14)),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            }
          }
        }
        break;
      case 2:
        final result = await _showFoodSelection();
        if (result == true && mounted) {
          setState(() => _steps[2].completed = true);
          _advanceIfReady();
        }
        break;
    }
  }

  Future<String?> _showProviderPicker() async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _ProviderPickerSheet(),
    );
  }

  Future<bool?> _showFoodSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _CustomerFoodSelectionScreen(),
      ),
    );
    return result;
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
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _loadingStatus
                  ? const Center(
                      child: CircularProgressIndicator(color: _kAccent))
                  : ListView(
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
        color: _kWhite,
        border: Border(
          bottom: BorderSide(color: _kBorder.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: _kDarkText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          const Text(
            'Verification',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kDarkText,
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
        const Text(
          'Complete your profile',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _kDarkText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$completedCount of ${_steps.length} steps completed',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _kMutedText,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: completedCount / _steps.length,
            minHeight: 5,
            backgroundColor: _kBorder,
            valueColor: const AlwaysStoppedAnimation(_kAccent),
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
                  ? _kAccent.withValues(alpha: 0.07)
                  : isCompleted
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.05)
                      : _kWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent
                    ? _kAccent
                    : isCompleted
                        ? const Color(0xFF4CAF50)
                        : _kBorder,
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
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isLocked
                                    ? const Color(0xFFC9BFB0)
                                    : _kDarkText,
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
        color: isCurrent ? _kAccent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent
              ? _kAccent
              : isLocked
                  ? _kBorder
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
                    : _kMutedText,
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
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'All steps completed — Done',
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
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
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
        child: Icon(Icons.touch_app_rounded, color: _kAccent, size: 22),
      ),
    );
  }
}

// ─── Provider Picker Bottom Sheet ───────────────────────────────

class _ProviderPickerSheet extends StatefulWidget {
  const _ProviderPickerSheet();

  @override
  State<_ProviderPickerSheet> createState() => _ProviderPickerSheetState();
}

class _ProviderPickerSheetState extends State<_ProviderPickerSheet> {
  List<Map<String, dynamic>> _providers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final providers = await SavoraApi.getActivePaymentProviders();
      if (mounted) setState(() { _providers = providers; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Could not load payment providers'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choose Payment Provider',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _kDarkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select your preferred provider',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: _kMutedText,
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: _kAccent),
              ),
            )
          else if (_error != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 40, color: _kMutedText),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _kMutedText)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(foregroundColor: _kAccent),
                  ),
                ],
              ),
            )
          else if (_providers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No payment providers available', style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _kMutedText)),
              ),
            )
          else
            ...List.generate(_providers.length, (i) {
              final provider = _providers[i];
              final name = (provider['name'] as String?) ??
                  (provider['Provider'] as String?) ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _kWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, color: _kAccent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w600, color: _kDarkText)),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: _kMutedText, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─── Payment Detail Entry Screen ────────────────────────────────

class _PaymentDetailScreen extends StatefulWidget {
  const _PaymentDetailScreen({required this.providerName});

  final String providerName;

  @override
  State<_PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<_PaymentDetailScreen> {
  final _detailsController = TextEditingController();
  bool _saving = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _detailsController.addListener(() {
      setState(() => _hasText = _detailsController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_detailsController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final profileId = authState.profileId;
      if (profileId == null) {
        if (mounted) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile ID not found — please log in again'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      final methodInfo = '${widget.providerName}: ${_detailsController.text.trim()}';
      await SavoraApi.updateCustomerProfile(
        profileId: profileId,
        data: {'payment_method': methodInfo},
      );
      await SavoraApi.updateCustomerVerificationStep(
        profileId: profileId,
        step: 'payment_method',
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kDarkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.providerName,
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w700, color: _kDarkText),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.credit_card_rounded, color: _kAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    widget.providerName,
                    style: const TextStyle(fontFamily: 'DM Sans', fontSize: 22, fontWeight: FontWeight.w800, color: _kDarkText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Enter your payment details',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w700, color: _kDarkText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsController,
              autofocus: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Your ${widget.providerName} details',
                hintText: 'e.g. phone number or account ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kAccent, width: 2),
                ),
              ),
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 16, color: _kDarkText),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSave(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: !_hasText || _saving ? null : _onSave,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _kDarkText))
                    : const Icon(Icons.check_rounded, size: 22),
                label: Text(
                  _saving ? 'Saving...' : 'Save Payment Method',
                  style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasText ? _kAccent : _kBorder,
                  foregroundColor: _hasText ? _kDarkText : _kMutedText,
                  disabledBackgroundColor: _kBorder,
                  disabledForegroundColor: _kMutedText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
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

// ─── Food Selection Screen (Step 3) ─────────────────────────────

enum _FoodView { categories, subcategories, dishes }

class _CustomerFoodSelectionScreen extends StatefulWidget {
  const _CustomerFoodSelectionScreen();

  @override
  State<_CustomerFoodSelectionScreen> createState() =>
      _CustomerFoodSelectionScreenState();
}

class _CustomerFoodSelectionScreenState
    extends State<_CustomerFoodSelectionScreen> {
  _FoodView _currentView = _FoodView.categories;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  List<Map<String, dynamic>> _dishes = [];

  Map<String, dynamic>? _currentCategory;
  Map<String, dynamic>? _currentSubcategory;

  final Set<String> _selectedDishIds = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _subLoading = false;
  bool _dishLoading = false;
  String? _error;
  String _lang = 'english';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<String> _getLanguageCode(Map<String, dynamic> data) {
    final d = data['data'];
    if (d is Map<String, dynamic> && d['language'] is String) {
      return Future.value(d['language'] as String);
    }
    if (data['language'] is String) {
      return Future.value(data['language'] as String);
    }
    return Future.value('en');
  }

  String _mapLang(String raw) {
    final code = raw.trim().toLowerCase();
    if (code == 'en' || code == 'english') return 'english';
    if (code == 'ar' || code == 'arabic') return 'arabic';
    if (code == 'es' || code == 'spanish') return 'spanish';
    if (code == 'fr' || code == 'french') return 'french';
    if (code == 'zh' || code == 'chinese') return 'chinese';
    return 'english';
  }

  Future<List<Map<String, dynamic>>> _extractList(
      Map<String, dynamic> data) {
    if (data['response'] is List) {
      return Future.value(
          List<Map<String, dynamic>>.from(data['response']));
    }
    if (data['dishes'] is List) {
      return Future.value(List<Map<String, dynamic>>.from(data['dishes']));
    }
    if (data['data'] is List) {
      return Future.value(List<Map<String, dynamic>>.from(data['data']));
    }
    if (data['categories'] is List) {
      return Future.value(
          List<Map<String, dynamic>>.from(data['categories']));
    }
    if (data['records'] is List) {
      return Future.value(List<Map<String, dynamic>>.from(data['records']));
    }
    if (data['result'] is List) {
      return Future.value(List<Map<String, dynamic>>.from(data['result']));
    }
    return Future.value([]);
  }

  String _name(dynamic item) {
    if (item is! Map<String, dynamic>) return '';
    final langKey = '${_lang}_name';
    return (item[langKey] as String?) ??
        (item['name'] as String?) ??
        (item['english_name'] as String?) ??
        (item['_id'] as String?) ??
        '';
  }

  String _imageUrl(dynamic item) {
    if (item is! Map<String, dynamic>) return '';
    return (item['image'] as String?) ?? '';
  }

  Future<void> _loadCategories() async {
    try {
      final userId = authState.userId;
      if (userId == null) {
        setState(() {
          _error = 'User ID not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final langData = await SavoraApi.getUserLanguage(userId);
      final rawLang = await _getLanguageCode(langData);
      _lang = _mapLang(rawLang);

      final catData = await SavoraApi.getCategoriesByLanguage(_lang);
      final list = await _extractList(catData);

      setState(() {
        _categories = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _onCategoryTap(Map<String, dynamic> cat) async {
    final catId = cat['_id'] as String?;
    if (catId == null) return;

    setState(() {
      _currentView = _FoodView.subcategories;
      _currentCategory = cat;
      _subLoading = true;
      _subcategories = [];
    });

    try {
      final subData = await SavoraApi.getSubcategoriesByCategory(catId);
      final list = await _extractList(subData);
      if (mounted) {
        setState(() {
          _subcategories = list;
          _subLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _subLoading = false);
    }
  }

  Future<void> _onSubcategoryTap(Map<String, dynamic> sub) async {
    final subId = sub['_id'] as String?;
    if (subId == null) return;

    setState(() {
      _currentView = _FoodView.dishes;
      _currentSubcategory = sub;
      _dishLoading = true;
      _dishes = [];
    });

    try {
      final dishData = await SavoraApi.getDishesBySubcategory(subId);
      final list = await _extractList(dishData);
      if (mounted) {
        setState(() {
          _dishes = list;
          _dishLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _dishLoading = false);
    }
  }

  Future<void> _onContinue() async {
    if (_selectedDishIds.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final profileId = authState.profileId;
      if (profileId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile ID not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      await SavoraApi.updateCustomerProfile(
        profileId: profileId,
        data: {'preferred_dishes': _selectedDishIds.toList()},
      );
      await SavoraApi.updateCustomerVerificationStep(
        profileId: profileId,
        step: 'favorite_items',
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
                _buildBottomActionBar(),
              ],
            ),
            if (_isSaving)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: _kAccent),
                      SizedBox(height: 16),
                      Text('Saving your selection...',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _kAccent));
    }
    if (_error != null) return _buildErrorState();

    switch (_currentView) {
      case _FoodView.categories:
        return _buildCategoriesList();
      case _FoodView.subcategories:
        return _buildSubcategoriesList();
      case _FoodView.dishes:
        return _buildDishesList();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 64, color: _kMutedText),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _kMutedText,
                  fontSize: 16,
                  fontFamily: 'DM Sans'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadCategories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: _kDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    String title;
    VoidCallback? onBack;

    switch (_currentView) {
      case _FoodView.categories:
        title = 'Select Food';
        onBack = () => Navigator.of(context).pop();
        break;
      case _FoodView.subcategories:
        title = _name(_currentCategory);
        onBack = () {
          setState(() {
            _currentView = _FoodView.categories;
            _currentCategory = null;
            _subcategories = [];
          });
        };
        break;
      case _FoodView.dishes:
        title = _name(_currentSubcategory);
        onBack = () {
          setState(() {
            _currentView = _FoodView.subcategories;
            _currentSubcategory = null;
            _dishes = [];
          });
        };
        break;
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _kWhite,
        border: Border(
            bottom: BorderSide(color: _kBorder.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: _kDarkText,
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kDarkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (_categories.isEmpty) {
      return const Center(
        child: Text('No categories available',
            style: TextStyle(
                color: _kMutedText,
                fontFamily: 'DM Sans',
                fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final image = _imageUrl(cat);
        final name = _name(cat);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _onCategoryTap(cat),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image), fit: BoxFit.cover)
                    : null,
                color: image.isEmpty ? _kBorder : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(16),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoriesList() {
    if (_subLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _kAccent));
    }

    if (_subcategories.isEmpty) {
      return const Center(
        child: Text('No subcategories found',
            style: TextStyle(
                color: _kMutedText,
                fontFamily: 'DM Sans',
                fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _subcategories.length,
      itemBuilder: (context, index) {
        final sub = _subcategories[index];
        final image = _imageUrl(sub);
        final name = _name(sub);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _onSubcategoryTap(sub),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image), fit: BoxFit.cover)
                    : null,
                color: image.isEmpty ? _kBorder : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(14),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDishesList() {
    if (_dishLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _kAccent));
    }

    if (_dishes.isEmpty) {
      return const Center(
        child: Text('No dishes found',
            style: TextStyle(
                color: _kMutedText,
                fontFamily: 'DM Sans',
                fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _dishes.length,
      itemBuilder: (context, index) {
        final dish = _dishes[index];
        final dishId = dish['_id'] as String? ?? '';
        final image = _imageUrl(dish);
        final name = _name(dish);
        final isSelected = _selectedDishIds.contains(dishId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDishIds.remove(dishId);
                } else {
                  _selectedDishIds.add(dishId);
                }
              });
            },
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _kAccent : _kBorder,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected
                    ? _kAccent.withValues(alpha: 0.08)
                    : _kWhite,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(11)),
                    child: image.isNotEmpty
                        ? Image.network(image,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover)
                        : Container(
                            width: 90,
                            height: 90,
                            color: _kBorder,
                            child: Icon(Icons.restaurant,
                                color: _kMutedText)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _kDarkText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? _kAccent : _kBorder,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    final count = _selectedDishIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kBackground.withValues(alpha: 0.95),
        border: Border(
            top: BorderSide(color: _kBorder.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: count > 0 && !_isSaving ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: count > 0 ? _kAccent : _kBorder,
              foregroundColor: count > 0 ? _kDarkText : _kMutedText,
              disabledBackgroundColor: _kBorder,
              disabledForegroundColor: _kMutedText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: count > 0 ? 4 : 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kDarkText))
                : Text(
                    count > 0
                        ? 'Confirm $count dish${count > 1 ? "es" : ""}'
                        : 'Select dishes to continue',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
