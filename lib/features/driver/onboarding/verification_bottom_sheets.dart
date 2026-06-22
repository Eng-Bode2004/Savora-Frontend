import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  static const _types = ['دراجة نارية', 'سيارة', 'دراجة هوائية', 'شاحنة صغيرة'];

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
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('حفظ البيانات'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(verificationProvider.notifier)
        .completeStep(VerificationStep.vehicle);
    Navigator.pop(context);
  }
}

// ── 2 · Delivery Zone Bottom Sheet ───────────────────────────────────────────
class DeliveryZoneBottomSheet extends ConsumerWidget {
  const DeliveryZoneBottomSheet({super.key});

  static void show(BuildContext context) =>
      _showSheet(context, const DeliveryZoneBottomSheet());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Container(
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
                      Text('وسط المدينة – المنطقة A', style: tt.bodyLarge),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('تغيير')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('تأكيد الموقع'),
            onPressed: () {
              ref
                  .read(verificationProvider.notifier)
                  .completeStep(VerificationStep.zone);
              Navigator.pop(context);
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
  final Map<String, bool> _uploaded = {
    'الهوية الوطنية – الوجه الأمامي': false,
    'الهوية الوطنية – الوجه الخلفي': false,
    'رخصة القيادة': false,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final allUploaded = _uploaded.values.every((v) => v);

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
          ..._uploaded.keys.map((label) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _UploadTile(
                  label: label,
                  uploaded: _uploaded[label]!,
                  onTap: () =>
                      setState(() => _uploaded[label] = !_uploaded[label]!),
                  cs: cs,
                  tt: tt,
                ),
              )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_outlined),
            label: const Text('إرسال للمراجعة'),
            onPressed: allUploaded
                ? () {
                    ref
                        .read(verificationProvider.notifier)
                        .completeStep(VerificationStep.identity);
                    Navigator.pop(context);
                  }
                : null,
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
