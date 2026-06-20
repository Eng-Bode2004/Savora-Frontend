import 'package:flutter/material.dart';

class StepData {
  final String label;
  IconData icon;
  final bool isActive;
  bool isCompleted;
  bool isError;

  StepData({
    required this.label,
    required this.icon,
    required this.isActive,
    this.isCompleted = false,
    this.isError = false,
  });
}
