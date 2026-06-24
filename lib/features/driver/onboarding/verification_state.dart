import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';

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
  VerificationNotifier() : super(VerificationState.initial()) {
    _syncWithProfile();
    refreshProfile();
  }

  void _syncWithProfile() {
    final profile = authState.profileData;
    if (profile == null) return;
    
    final fullyVerified = profile['Verification_Status'] == 'approved' || profile['Is_Verified'] == true;
    
    final updated = Map<VerificationStep, bool>.from(state.completed);
    
    if (fullyVerified) {
      for (final step in VerificationStep.values) {
        updated[step] = true;
      }
    } else {
      if (profile['Vehicle_Status'] == 'verified') {
        updated[VerificationStep.vehicle] = true;
      }
      if (profile['Documents_Status'] == 'verified') {
        updated[VerificationStep.identity] = true;
      }
      if (profile['address_id'] != null || profile['region'] != null) {
        updated[VerificationStep.zone] = true;
      }
      if (profile['Verification_Status'] == 'approved' || profile['Is_Verified'] == true) {
        updated[VerificationStep.review] = true;
      }
    }
    
    VerificationStep next = VerificationStep.vehicle;
    for (final s in VerificationStep.values) {
      if (!(updated[s] ?? false)) {
        next = s;
        break;
      }
    }
    
    state = state.copyWith(completed: updated, activeStep: next);
    
    if (next == VerificationStep.review && profile['Verification_Status'] == 'not_submitted') {
      SavoraApi.verifyDriverStep(authState.profileId!, 'Verification_Status', 'pending_review').catchError((_) => {});
    }
    
    // Load local zone verified status
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('driver_zone_verified_${authState.profileId}') == true) {
        completeStep(VerificationStep.zone);
      }
    });
  }

  Future<void> refreshProfile() async {
    final profileId = authState.profileId;
    if (profileId == null) return;
    try {
      final res = await SavoraApi.getDriverProfile(profileId);
      final profileObj = res['profile'] as Map<String, dynamic>?;
      if (profileObj != null) {
        authState.setProfileData(profileObj);
        _syncWithProfile();
      }
    } catch (_) {}
  }

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

    if (step == VerificationStep.zone) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('driver_zone_verified_${authState.profileId}', true);
      });
    }

    if (next == VerificationStep.review && authState.profileId != null) {
      SavoraApi.verifyDriverStep(authState.profileId!, 'Verification_Status', 'pending_review').catchError((_) => {});
    }
  }

  void setActiveStep(VerificationStep step) {
    state = state.copyWith(activeStep: step);
  }
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>(
  (ref) => VerificationNotifier(),
);
