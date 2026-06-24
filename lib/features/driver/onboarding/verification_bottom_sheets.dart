import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';
import 'driver_location_setup_screen.dart' as savora_driver_location;
import 'verification_state.dart';

// ── Shared bottom-sheet launcher helper ───────────────────────────────────────
void _showSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    ),
  );
}

// ── 1 · Vehicle Information Bottom Sheet ─────────────────────────────────────
class VehicleInfoBottomSheet extends ConsumerStatefulWidget {
  const VehicleInfoBottomSheet({super.key});

  static void show(BuildContext context) =>
      _showSheet(context, const VehicleInfoBottomSheet());

  @override
  ConsumerState<VehicleInfoBottomSheet> createState() =>
      _VehicleInfoBottomSheetState();
}

class _VehicleInfoBottomSheetState
    extends ConsumerState<VehicleInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _type;
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  XFile? _vehicleImage;
  bool _isSaving = false;

  static const _types = ['دراجة نارية', 'سيارة', 'دراجة هوائية', 'شاحنة صغيرة'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _vehicleImage = pickedFile;
      });
    }
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(
                  title: 'بيانات المركبة', icon: Icons.two_wheeler, cs: cs, tt: tt),
              const SizedBox(height: 20),
              Text('نوع المركبة', style: tt.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: _inputDec(cs, 'اختر نوع المركبة'),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                validator: (v) => v == null ? 'يرجى اختيار نوع المركبة' : null,
                onChanged: (v) => setState(() => _type = v),
                dropdownColor: cs.surfaceContainerHighest,
              ),
              const SizedBox(height: 16),
              Text('موديل المركبة', style: tt.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _modelCtrl,
                textDirection: TextDirection.rtl,
                decoration: _inputDec(cs, 'مثال: تويوتا كامري 2022'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'يرجى إدخال موديل المركبة' : null,
              ),
              const SizedBox(height: 16),
              Text('رقم اللوحة', style: tt.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _plateCtrl,
                textDirection: TextDirection.rtl,
                decoration: _inputDec(cs, 'مثال: أ ب ج 1234'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'يرجى إدخال رقم اللوحة' : null,
              ),
              const SizedBox(height: 16),
              Text('صورة المركبة', style: tt.labelLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: _vehicleImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: kIsWeb
                              ? Image.network(_vehicleImage!.path, fit: BoxFit.cover, width: double.infinity)
                              : Image.file(File(_vehicleImage!.path), fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: cs.primary, size: 32),
                            const SizedBox(height: 8),
                            Text('اضغط لإرفاق صورة', style: tt.bodyMedium),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('حفظ البيانات'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vehicleImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إرفاق صورة للمركبة')));
      return;
    }
    
    setState(() => _isSaving = true);
    try {
      final profileId = authState.profileId;
      if (profileId != null) {
        final bytes = await _vehicleImage!.readAsBytes();
        final uploadRes = await SavoraApi.uploadDriverVehicleImage(bytes, _vehicleImage!.path.split('/').last);
        final imageUrl = uploadRes['data']['URL'];

        await SavoraApi.updateDriverProfile(profileId, {
          'vehicle': {
             'type': _type == 'دراجة نارية' ? 'bike' : _type == 'سيارة' ? 'car' : _type == 'شاحنة صغيرة' ? 'van' : 'scooter',
             'model': _modelCtrl.text,
             'plate': _plateCtrl.text,
             'image': imageUrl,
          }
        });
        await SavoraApi.verifyDriverStep(profileId, 'Vehicle_Status', 'verified');
      }

      ref.read(verificationProvider.notifier).completeStep(VerificationStep.vehicle);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── 2 · Delivery Zone Bottom Sheet ───────────────────────────────────────────
class DeliveryZoneBottomSheet extends ConsumerStatefulWidget {
  const DeliveryZoneBottomSheet({super.key});

  static void show(BuildContext context) =>
      _showSheet(context, const DeliveryZoneBottomSheet());

  @override
  ConsumerState<DeliveryZoneBottomSheet> createState() => _DeliveryZoneBottomSheetState();
}

class _DeliveryZoneBottomSheetState extends ConsumerState<DeliveryZoneBottomSheet> {
  Map<String, dynamic>? _selectedLocation;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(
              title: 'اختيار منطقة التوصيل',
              icon: Icons.location_on_outlined,
              cs: cs,
              tt: tt),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const savora_driver_location.DriverLocationSetupScreen()),
              );
              if (result != null) {
                setState(() => _selectedLocation = result);
              }
            },
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 180),
                    painter: _MapGridPainter(cs.outlineVariant.withOpacity(0.3)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: cs.primary),
                      const SizedBox(height: 8),
                      Text('خريطة اختيار المنطقة', style: tt.bodyMedium),
                    ],
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.my_location, size: 14, color: cs.onPrimary),
                        const SizedBox(width: 6),
                        Text('موقعي الحالي',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onPrimary)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedLocation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                    child: Icon(Icons.location_on, color: cs.onPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المنطقة المختارة', style: tt.labelSmall),
                        Text(_selectedLocation!['addressName'], style: tt.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(_selectedLocation!['addressDetails'], style: tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('تأكيد الموقع'),
            onPressed: (_selectedLocation == null || _isSaving) ? null : () async {
              setState(() => _isSaving = true);
              try {
                final profileId = authState.profileId;
                if (profileId != null) {
                  final addressRes = await SavoraApi.createAddress({
                    'street': _selectedLocation!['addressName'],
                    'city': _selectedLocation!['addressDetails'],
                    'country': 'Egypt',
                    'latitude': _selectedLocation!['latitude'],
                    'longitude': _selectedLocation!['longitude'],
                    'label': 'Delivery Zone',
                    'user_id': authState.userId,
                    'Profile_id': profileId,
                  });
                  final addressId = addressRes['_id'] ?? addressRes['id'];

                  // Update driver profile with region
                  await SavoraApi.updateDriverProfile(profileId, {
                    'region': _selectedLocation!['addressDetails'],
                    'address_id': addressId,
                  });
                }

                ref.read(verificationProvider.notifier).completeStep(VerificationStep.zone);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
              } finally {
                if (mounted) setState(() => _isSaving = false);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── 3 · Identity Verification Bottom Sheet ───────────────────────────────────
class IdentityVerificationBottomSheet extends ConsumerStatefulWidget {
  const IdentityVerificationBottomSheet({super.key});

  static void show(BuildContext context) =>
      _showSheet(context, const IdentityVerificationBottomSheet());

  @override
  ConsumerState<IdentityVerificationBottomSheet> createState() =>
      _IdentityVerificationBottomSheetState();
}

class _IdentityVerificationBottomSheetState
    extends ConsumerState<IdentityVerificationBottomSheet> {
  final Map<String, XFile?> _files = {
    'الهوية الوطنية – الوجه الأمامي': null,
    'الهوية الوطنية – الوجه الخلفي': null,
    'رخصة القيادة': null,
    'استمارة المركبة': null,
  };
  
  bool _isSaving = false;

  Future<void> _pickImage(String label) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _files[label] = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final allUploaded = _files.values.every((v) => v != null);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(
              title: 'رفع المستندات',
              icon: Icons.badge_outlined,
              cs: cs,
              tt: tt),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.secondary.withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: cs.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يرجى التأكد من وضوح الصور وظهور جميع البيانات بشكل صحيح لتسريع عملية التفعيل.',
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._files.keys.map((label) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _UploadTile(
                  label: label,
                  uploaded: _files[label] != null,
                  onTap: () => _pickImage(label),
                  cs: cs,
                  tt: tt,
                ),
              )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_outlined),
            label: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('إرسال للمراجعة'),
            onPressed: (allUploaded && !_isSaving) ? _submitDocs : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: cs.outlineVariant.withOpacity(0.3),
            ),
          ),
          if (!allUploaded) ...[
            const SizedBox(height: 8),
            Center(
              child: Text('يرجى رفع جميع المستندات أولاً',
                  style: tt.labelSmall?.copyWith(color: cs.error)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitDocs() async {
    setState(() => _isSaving = true);
    try {
      final profileId = authState.profileId;
      if (profileId != null) {
        // Upload ID Front
        final idFrontFile = _files['الهوية الوطنية – الوجه الأمامي']!;
        final idFrontRes = await SavoraApi.uploadDriverIdFront(await idFrontFile.readAsBytes(), idFrontFile.path.split('/').last);
        final idFrontUrl = idFrontRes['data']['URL'];

        // Upload ID Back
        final idBackFile = _files['الهوية الوطنية – الوجه الخلفي']!;
        final idBackRes = await SavoraApi.uploadDriverIdBack(await idBackFile.readAsBytes(), idBackFile.path.split('/').last);
        final idBackUrl = idBackRes['data']['URL'];

        // Upload License
        final licenseFile = _files['رخصة القيادة']!;
        final licenseRes = await SavoraApi.uploadDriverLicenseFront(await licenseFile.readAsBytes(), licenseFile.path.split('/').last);
        final licenseUrl = licenseRes['data']['URL'];

        // Upload Vehicle License
        final vehicleLicenseFile = _files['استمارة المركبة']!;
        final vehicleLicenseRes = await SavoraApi.uploadDriverVehicleLicense(await vehicleLicenseFile.readAsBytes(), vehicleLicenseFile.path.split('/').last);
        final vehicleLicenseUrl = vehicleLicenseRes['data']['URL'];

        // Update Driver Profile
        await SavoraApi.updateDriverProfile(profileId, {
           'documents': {
              'id_front': idFrontUrl,
              'id_back': idBackUrl,
           },
           'license': {
              'front_image': licenseUrl,
              'vehicle_license_image': vehicleLicenseUrl,
           }
        });
        
        await SavoraApi.verifyDriverStep(profileId, 'Documents_Status', 'verified');
        await SavoraApi.verifyDriverStep(profileId, 'Verification_Status', 'pending_review');
      }

      ref.read(verificationProvider.notifier).completeStep(VerificationStep.identity);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── 4 · Account Review Bottom Sheet ──────────────────────────────────────────
class AccountReviewBottomSheet extends ConsumerWidget {
  const AccountReviewBottomSheet({super.key});

  static void show(BuildContext context) =>
      _showSheet(context, const AccountReviewBottomSheet());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.35),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.verified_outlined, size: 72, color: cs.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text('جاري مراجعة بياناتك',
              textAlign: TextAlign.center,
              style: tt.displaySmall?.copyWith(color: cs.primary)),
          const SizedBox(height: 12),
          Text(
            'يقوم فريقنا حالياً بمراجعة البيانات والمستندات المقدمة. سيتم إشعارك فور الانتهاء من عملية التحقق.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 24),
          _ReviewInfoTile(
            icon: Icons.timer_outlined,
            label: 'الوقت المتوقع للمراجعة',
            value: '24 – 48 ساعة',
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 10),
          _ReviewInfoTile(
            icon: Icons.pending_outlined,
            label: 'حالة التحقق',
            value: 'قيد المراجعة',
            cs: cs,
            tt: tt,
            valueColor: Colors.orange,
          ),
          const SizedBox(height: 10),
          _ReviewInfoTile(
            icon: Icons.support_agent_outlined,
            label: 'تواصل مع الدعم',
            value: 'support@savora.app',
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(verificationProvider.notifier)
                  .completeStep(VerificationStep.review);
              Navigator.pop(context);
            },
            child: const Text('إغلاق'),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme cs;
  final TextTheme tt;

  const _SheetHeader(
      {required this.title,
      required this.icon,
      required this.cs,
      required this.tt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cs.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Text(title, style: tt.titleLarge),
      ],
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final bool uploaded;
  final VoidCallback onTap;
  final ColorScheme cs;
  final TextTheme tt;

  const _UploadTile({
    required this.label,
    required this.uploaded,
    required this.onTap,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: uploaded
              ? cs.primaryContainer.withOpacity(0.2)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploaded ? cs.primary : cs.outlineVariant,
            width: uploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: uploaded
                  ? Container(
                      key: const ValueKey('check'),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: cs.primary, shape: BoxShape.circle),
                      child:
                          Icon(Icons.check, color: cs.onPrimary, size: 18),
                    )
                  : Container(
                      key: const ValueKey('upload'),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.outlineVariant.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.upload_file_outlined,
                          color: cs.onSurfaceVariant, size: 18),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: tt.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    uploaded ? 'تم الرفع بنجاح' : 'اضغط لرفع الصورة',
                    style: tt.labelSmall?.copyWith(
                      color: uploaded ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!uploaded)
              Icon(Icons.arrow_back_ios_new,
                  size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ReviewInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;
  final Color? valueColor;

  const _ReviewInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
    required this.tt,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: tt.bodyMedium)),
          Text(value,
              style: tt.bodyLarge?.copyWith(color: valueColor ?? cs.primary)),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final Color color;
  _MapGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

InputDecoration _inputDec(ColorScheme cs, String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error),
      ),
    );
