import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Verification Step enum ─────────────────────────────────────────────────────
enum VerificationStep { vehicle, zone, identity, review }

// ── Verification State ─────────────────────────────────────────────────────────
class VerificationState {
  final Map<VerificationStep, bool> completed;
  final VerificationStep activeStep;

  const VerificationState({
    required this.completed,
    required this.activeStep,
  });

  factory VerificationState.initial() => VerificationState(
        completed: {
          VerificationStep.vehicle: false,
          VerificationStep.zone: false,
          VerificationStep.identity: false,
          VerificationStep.review: false,
        },
        activeStep: VerificationStep.vehicle,
      );

  VerificationState copyWith({
    Map<VerificationStep, bool>? completed,
    VerificationStep? activeStep,
  }) =>
      VerificationState(
        completed: completed ?? this.completed,
        activeStep: activeStep ?? this.activeStep,
      );

  /// 0.0 – 1.0
  double get progress {
    final done = completed.values.where((v) => v).length;
    return done / completed.length;
  }

  int get progressPercent => (progress * 100).round();

  bool get isFullyVerified => completed.values.every((v) => v);

  bool isCompleted(VerificationStep step) => completed[step] ?? false;
}

// ── Notifier ───────────────────────────────────────────────────────────────────
class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier() : super(VerificationState.initial());

  void completeStep(VerificationStep step) {
    final updated = Map<VerificationStep, bool>.from(state.completed)
      ..[step] = true;

    // Advance activeStep to next incomplete step
    VerificationStep next = step;
    for (final s in VerificationStep.values) {
      if (!(updated[s] ?? false)) {
        next = s;
        break;
      }
    }

    state = state.copyWith(completed: updated, activeStep: next);
  }

  void setActiveStep(VerificationStep step) {
    state = state.copyWith(activeStep: step);
  }
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>(
  (ref) => VerificationNotifier(),
);
