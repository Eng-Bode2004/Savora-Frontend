import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/savora_api.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../state/cart_state.dart';
import '../../../../state/providers/auth_provider.dart';
import '../../../../shared/widgets/auth_gate.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  List<Map<String, dynamic>> _paymentProviders = [];
  Map<String, dynamic>? _selectedProvider;
  Uint8List? _paymentImageBytes;
  String? _paymentImageName;
  String? _paymentImageUrl;
  bool _submitting = false;
  bool _loadingProviders = true;
  double _deliveryFee = 0;
  bool _loadingFee = true;

  bool get _isAuth => authState.isLoggedIn;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor => _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);

  @override
  void initState() {
    super.initState();
    _loadProviders();
    _loadDeliveryFee();
    _initCart();
  }

  Future<void> _loadDeliveryFee() async {
    final fee = await SavoraApi.getAverageDeliveryFee();
    if (mounted) setState(() { _deliveryFee = fee; _loadingFee = false; });
  }

  Future<void> _initCart() async {
    await cartState.ensureLoaded();
    if (mounted) setState(() {});
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await SavoraApi.getActivePaymentProviders();
      if (mounted) setState(() { _paymentProviders = providers; _loadingProviders = false; });
    } catch (_) {
      if (mounted) setState(() { _loadingProviders = false; });
    }
  }

  Future<void> _pickPaymentImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _paymentImageBytes = bytes;
        _paymentImageName = picked.name;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (!_isAuth) {
      showAuthRequiredDialog(context);
      return;
    }
    await cartState.ensureLoaded();
    if (_selectedProvider == null) {
      _showSnackBar('Please select a payment method');
      return;
    }
    if (_paymentImageBytes == null) {
      _showSnackBar('Please upload payment receipt image');
      return;
    }
    if (cartState.items.isEmpty) {
      _showSnackBar('Your cart is empty — add items first');
      return;
    }
    setState(() => _submitting = true);

    try {
      final imgResult = await SavoraApi.uploadPaymentImage(
        _paymentImageBytes!,
        _paymentImageName ?? 'payment.jpg',
      );
      final imgData = imgResult['data'];
      final paymentUrl = (imgData is Map<String, dynamic> ? imgData['URL'] : null) as String? ??
          (imgResult['URL'] as String?);

      final providerName = _selectedProvider!['name'] as String? ??
          _selectedProvider!['Provider'] as String? ??
          'Unknown';

      // Auto-assign chef if not already set
      String? chefId = cartState.chefId;
      if (chefId == null) {
        final now = DateTime.now();
        final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final items = cartState.items.map((item) => {
          'dish_id': item.dishId,
          'qty': item.qty,
        }).toList();
        final bestChef = await SavoraApi.findBestChef(items: items, date: date);
        chefId = bestChef['chef_id'] as String?;
      }

      final orderData = {
        'customer_id': authState.userId,
        'customer_name': authState.name ?? authState.email ?? 'Customer',
        'chef_id': chefId,
        'items': cartState.items.map((item) => {
          'dish_id': item.dishId,
          'name': item.name,
          'price': item.unitPrice,
          'qty': item.qty,
          'add_ons': item.addOns.map((a) => {'name': a.name, 'price': a.price}).toList(),
        }).toList(),
        'total': cartState.total + _deliveryFee.toInt(),
        'payment_method': providerName,
        'payment_image': paymentUrl ?? '',
      };

      await SavoraApi.createOrder(orderData);
      await cartState.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order placed! Awaiting payment verification.'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'DM Sans')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildBody()),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(bottom: BorderSide(color: _subTextColor.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: _textColor,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          Text('Checkout', style: TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w700, color: _textColor)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderSummary(),
        const SizedBox(height: 20),
        _buildPaymentMethodSection(),
        const SizedBox(height: 20),
        _buildPaymentUploadSection(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w700, color: _textColor)),
          const SizedBox(height: 12),
          ...cartState.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: Text('${item.name} ×${item.qty}', style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _textColor))),
                Text('EGP ${item.totalPrice}', style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w600, color: _textColor)),
              ],
            ),
          )),
          const Divider(),
          Row(
            children: [
              Expanded(child: Text('Delivery Fee', style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _subTextColor))),
              _loadingFee
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent))
                : Text('EGP ${_deliveryFee.toInt()}', style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w600, color: _textColor)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Text('Total', style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w800, color: _textColor))),
              Text('EGP ${cartState.total + _deliveryFee.toInt()}', style: const TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w800, color: _kAccentDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w700, color: _textColor)),
          const SizedBox(height: 12),
          if (_loadingProviders)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: _kAccent),
            ))
          else if (_paymentProviders.isEmpty)
            Text('No payment providers available', style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _subTextColor))
          else
            ..._paymentProviders.map((provider) {
              final name = provider['name'] as String? ?? provider['Provider'] as String? ?? '';
              final key = (provider['key'] as String?)?.isNotEmpty == true
                  ? provider['key'] as String
                  : (provider['account'] as String?) ?? (provider['wallet'] as String?) ?? '';
              final isSelected = _selectedProvider == provider;
              return GestureDetector(
                onTap: () => setState(() => _selectedProvider = provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _kAccent.withValues(alpha: 0.08) : _fieldBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? _kAccent : _fieldBorderColor, width: isSelected ? 1.5 : 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                              size: 22, color: isSelected ? _kAccent : _subTextColor),
                          const SizedBox(width: 12),
                          Text(name, style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w600, color: _textColor)),
                        ],
                      ),
                      if (isSelected && key.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _kAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: _kAccentDark),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _textColor),
                                    children: [
                                      const TextSpan(text: 'Send payment to: '),
                                      TextSpan(
                                        text: key,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: _kAccentDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Clipboard.setData(ClipboardData(text: key)),
                                child: Icon(Icons.copy_rounded, size: 18, color: _kAccentDark),
                              ),
                        ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Payment Receipt', style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w700, color: _textColor)),
          const SizedBox(height: 4),
          Text('Take a screenshot or photo of your payment confirmation', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: _subTextColor)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickPaymentImage,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: _fieldBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _fieldBorderColor, width: 0.5),
              ),
              child: _paymentImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.memory(_paymentImageBytes!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_rounded, size: 36, color: _subTextColor),
                        const SizedBox(height: 8),
                        Text('Tap to upload receipt', style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _subTextColor)),
                      ],
                    ),
            ),
          ),
          if (_paymentImageName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_paymentImageName!, style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: _subTextColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _fieldBorderColor, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _submitting ? null : _submitOrder,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kAccentLight, _kAccent, _kAccentDark]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _submitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2C1810)))
                : Text('Place Order — EGP ${cartState.total + _deliveryFee.toInt()}',
                    style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2C1810))),
          ),
        ),
      ),
    );
  }
}
