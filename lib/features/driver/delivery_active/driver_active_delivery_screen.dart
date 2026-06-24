import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savora_app/features/driver/providers/driver_state.dart';

class DriverActiveDeliveryScreen extends ConsumerStatefulWidget {
  const DriverActiveDeliveryScreen({super.key});

  @override
  ConsumerState<DriverActiveDeliveryScreen> createState() =>
      _DriverActiveDeliveryScreenState();
}

class _DriverActiveDeliveryScreenState
    extends ConsumerState<DriverActiveDeliveryScreen> {
  double _sliderValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(driverOrdersProvider);
    final activeOrder =
        orders.where((o) => o.status == 'active').firstOrNull;
    final cs = Theme.of(context).colorScheme;

    if (activeOrder == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Active Delivery'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/driver/dashboard');
              }
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping, size: 80, color: cs.outlineVariant),
              const SizedBox(height: 16),
              Text('No Active Delivery',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text('You do not have any active deliveries.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/driver/orders'),
                child: const Text('Find Orders'),
              ),
            ],
          ),
        ),
      );
    }

    final steps = ['accepted', 'pickedup', 'on-the-way', 'delivered'];
    final currentStepIndex =
        steps.indexOf(activeOrder.deliveryStep ?? 'accepted');

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery ${activeOrder.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/driver/dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.map, color: cs.primary),
            onPressed: () => context.push('/driver/active_delivery/map'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => context.push('/driver/active_delivery/map'),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: cs.surfaceContainerHighest),
                    Center(
                        child: Icon(Icons.map,
                            size: 48, color: cs.outlineVariant)),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.navigation,
                                color: cs.onPrimary, size: 16),
                            const SizedBox(width: 8),
                            Text('Navigate',
                                style: TextStyle(
                                    color: cs.onPrimary,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ================= CHEF DETAILS =================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.storefront, color: cs.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('CHEF / PICKUP',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: cs.primary.withOpacity(0.12),
                        backgroundImage: activeOrder.chefImage.isNotEmpty
                            ? NetworkImage(activeOrder.chefImage)
                            : null,
                        child: activeOrder.chefImage.isEmpty
                            ? Icon(Icons.person, color: cs.primary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activeOrder.chefName.isNotEmpty ? activeOrder.chefName : activeOrder.pickupName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            if (activeOrder.chefPhone.isNotEmpty)
                              Text(activeOrder.chefPhone,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      if (activeOrder.chefPhone.isNotEmpty)
                        IconButton(icon: Icon(Icons.phone, color: cs.primary), onPressed: () {}),
                    ],
                  ),
                  if (activeOrder.chefAddress.isNotEmpty || activeOrder.pickupAddress.isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeOrder.chefAddress.isNotEmpty ? activeOrder.chefAddress : activeOrder.pickupAddress,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ================= CUSTOMER DETAILS =================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: cs.secondary.withOpacity(0.12),
                            backgroundImage: activeOrder.customerAvatar != null
                                ? NetworkImage(activeOrder.customerAvatar!)
                                : null,
                            child: activeOrder.customerAvatar == null
                                ? Icon(Icons.person, color: cs.secondary)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activeOrder.customerName,
                                  style: Theme.of(context).textTheme.titleLarge),
                              Row(
                                children: [
                                  Icon(Icons.star, color: cs.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${activeOrder.customerRating} Customer',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (activeOrder.customerPhone.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.phone),
                              onPressed: () {},
                              color: cs.onSurfaceVariant,
                            ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline),
                            onPressed: () {},
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (activeOrder.customerPhone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.call_outlined, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(activeOrder.customerPhone,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: cs.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DELIVERY ADDRESS',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10, letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            if (activeOrder.dropoffLabel.isNotEmpty)
                              Text(activeOrder.dropoffLabel,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(activeOrder.dropoffAddress,
                                style: Theme.of(context).textTheme.bodyLarge),
                            if (activeOrder.dropoffCity.isNotEmpty)
                              Text(activeOrder.dropoffCity,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            if (activeOrder.deliveryNotes != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.primary.withOpacity(0.2)),
                                ),
                                child: Text(
                                  '"${activeOrder.deliveryNotes}"',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: cs.primary, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _TimelineStep(
                    title: 'Order Accepted',
                    subtitle: '12:15 PM',
                    isCompleted: currentStepIndex >= 0,
                    isActive: currentStepIndex == 0,
                    onTap: () => ref
                        .read(driverOrdersProvider.notifier)
                        .updateDeliveryStep(activeOrder.id, 'accepted'),
                  ),
                  _TimelineStep(
                    title: 'Picked Up',
                    subtitle: '12:30 PM',
                    isCompleted: currentStepIndex >= 1,
                    isActive: currentStepIndex == 1,
                    onTap: () => ref
                        .read(driverOrdersProvider.notifier)
                        .updateDeliveryStep(activeOrder.id, 'pickedup'),
                  ),
                  _TimelineStep(
                    title: 'On the Way',
                    subtitle: 'In Progress',
                    isCompleted: currentStepIndex >= 2,
                    isActive: currentStepIndex == 2,
                    onTap: () => ref
                        .read(driverOrdersProvider.notifier)
                        .updateDeliveryStep(activeOrder.id, 'on-the-way'),
                  ),
                  _TimelineStep(
                    title: 'Delivered',
                    subtitle: 'Pending',
                    isCompleted: currentStepIndex >= 3,
                    isActive: currentStepIndex == 3,
                    isLast: true,
                    onTap: () => ref
                        .read(driverOrdersProvider.notifier)
                        .updateDeliveryStep(activeOrder.id, 'delivered'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Stack(
            children: [
              Center(
                child: Text('Slide to Complete',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 16, color: cs.primary)),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: cs.primary,
                  overlayColor: cs.primary.withOpacity(0.2),
                  trackHeight: 64,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 28),
                ),
                child: Slider(
                  value: _sliderValue,
                  onChanged: (val) => setState(() => _sliderValue = val),
                  onChangeEnd: (val) {
                    if (val > 0.9) {
                      setState(() => _sliderValue = 1.0);
                      ref
                          .read(driverOrdersProvider.notifier)
                          .completeOrder(activeOrder.id);
                      context.go('/driver/dashboard');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Delivery Completed! Earned \$${activeOrder.estPayout.toStringAsFixed(2)}'),
                        ),
                      );
                    } else {
                      setState(() => _sliderValue = 0.0);
                    }
                  },
                ),
              ),
              Builder(
                builder: (context) => IgnorePointer(
                  child: Container(
                    width: MediaQuery.of(context).size.width * _sliderValue,
                    height: 64,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final VoidCallback onTap;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? cs.primary : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isCompleted ? cs.primary : cs.outlineVariant),
                ),
                child: isCompleted
                    ? Icon(Icons.check, size: 16, color: cs.onPrimary)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted
                      ? cs.primary
                      : cs.outlineVariant.withOpacity(0.5),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isActive
                            ? cs.primary
                            : (isCompleted
                                ? cs.onSurface
                                : cs.onSurfaceVariant),
                      ),
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context).textTheme.labelSmall),
                if (!isLast) const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
