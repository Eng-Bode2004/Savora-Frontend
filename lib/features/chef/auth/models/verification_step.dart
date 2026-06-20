enum VerificationStepState { completed, inProgress, locked }

/// One row in the Partner Verification checklist.
class VerificationStep {
  const VerificationStep({
    required this.title,
    required this.description,
    required this.state,
  });

  final String title;
  final String description;
  final VerificationStepState state;
}
