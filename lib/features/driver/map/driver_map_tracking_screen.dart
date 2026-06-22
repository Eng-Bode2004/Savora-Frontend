import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverMapTrackingScreen extends StatelessWidget {
  const DriverMapTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: cs.surface),
          CustomPaint(
            size: Size.infinite,
            painter: _StreetGridPainter(cs.outlineVariant),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: cs.surfaceContainer,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/driver/active_delivery');
                  }
                },
              ),
            ),
          ),
          Positioned(
              top: 250,
              left: 100,
              child: Icon(Icons.storefront, size: 48, color: cs.primary)),
          const Positioned(
              top: 400,
              right: 100,
              child: Icon(Icons.location_on, size: 48, color: Colors.blueAccent)),
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Card(
              color: cs.surfaceContainerHighest.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.turn_right,
                              color: cs.onPrimary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('In 500 feet',
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                              Text('Turn Right on Ocean Drive',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('12 min',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: cs.primary)),
                        Text('2.1 mi',
                            style: Theme.of(context).textTheme.bodyLarge),
                        Text('12:45 PM ETA',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/driver/active_delivery');
                        }
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Exit Navigation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.surface,
                        foregroundColor: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreetGridPainter extends CustomPainter {
  final Color color;
  _StreetGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 4;

    for (double i = 0; i < size.height; i += 80) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    for (double i = 0; i < size.width; i += 80) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    final routePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(125, 290)
      ..lineTo(125, 420)
      ..lineTo(280, 420);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
