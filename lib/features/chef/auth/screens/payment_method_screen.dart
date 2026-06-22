import 'package:flutter/material.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/features/chef/auth/screens/verification_theme.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String? profileId;
  const PaymentMethodScreen({super.key, this.profileId});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedProvider;
  String _details = '';
  bool _isSaving = false;

  Future<void> _pickProvider() async {
    final provider = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProviderPickerSheet(),
    );
    if (provider != null && mounted) {
      setState(() => _selectedProvider = provider);
    }
  }

  bool get _ready => _selectedProvider != null && _details.isNotEmpty;

  Future<void> _submit() async {
    if (!_ready) return;
    if (widget.profileId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile not loaded.'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    try {
      await SavoraApi.uploadPaymentMethod(
        profileId: widget.profileId!,
        provider: _selectedProvider!,
        details: _details,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kVfBackground,
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
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildProviderSection(),
                  if (_selectedProvider != null) ...[
                    const SizedBox(height: 14),
                    _buildDetailField(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
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
        color: kVfWhite,
        border: Border(bottom: BorderSide(color: kVfBorder.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: kVfDarkText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Text(
            'Payment Method',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w700, color: kVfDarkText),
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
          'Payment Details',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 22, fontWeight: FontWeight.w800, color: kVfDarkText, height: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose your payment provider and enter your details.',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w400, color: kVfMutedText, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kVfAccent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kVfAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kVfAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.account_balance, color: kVfAccent, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secure & Encrypted', style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w700, color: kVfDarkText)),
                const SizedBox(height: 4),
                Text('Your payment information is encrypted and never shared.',
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w400, color: kVfMutedText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection() {
    if (_selectedProvider == null) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _pickProvider,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text('Choose Payment Provider',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: kVfAccent, foregroundColor: const Color(0xFF2C1810),
            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _pickProvider,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kVfWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kVfAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.credit_card_rounded, color: kVfAccent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_selectedProvider!,
                  style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w600, color: kVfDarkText)),
            ),
            const Icon(Icons.edit_rounded, color: kVfMutedText, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'e.g. phone number or account ID',
        hintStyle: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: kVfLightText),
        labelText: 'Your ${_selectedProvider} details',
        filled: true,
        fillColor: kVfWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kVfBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kVfBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kVfAccent, width: 1.5)),
      ),
      style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w500, color: kVfDarkText),
      onChanged: (v) => setState(() => _details = v.trim()),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (_ready && !_isSaving) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kVfAccent, foregroundColor: const Color(0xFF2C1810),
          disabledBackgroundColor: kVfBorder, disabledForegroundColor: kVfMutedText,
          elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C1810)))
            : Text('Save Payment Method', style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── Provider Picker Bottom Sheet ────────────────────────────────

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
            child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: kVfBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Choose Payment Provider',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 20, fontWeight: FontWeight.w800, color: kVfDarkText)),
          const SizedBox(height: 6),
          const Text('Select your preferred provider',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: kVfMutedText)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: kVfAccent),
              ),
            )
          else if (_error != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 40, color: kVfMutedText),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: kVfMutedText)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(foregroundColor: kVfAccent),
                  ),
                ],
              ),
            )
          else if (_providers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No payment providers available',
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: kVfMutedText)),
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
                      color: kVfWhite, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kVfBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, color: kVfAccent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w600, color: kVfDarkText)),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: kVfMutedText, size: 16),
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
