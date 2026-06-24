import 'package:flutter/material.dart';
import '../../features/customer/auth/screens/login_screen.dart';

void showAuthRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Color(0xFFE8A838), size: 26),
          SizedBox(width: 10),
          Text(
            'Sign In Required',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: const Text(
        'You need to sign in or create an account to continue.',
        style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, height: 1.4, color: Color(0xFF666666)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel',
              style: TextStyle(fontFamily: 'DM Sans', color: Color(0xFF999999))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8A838),
            foregroundColor: const Color(0xFF2C1810),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Sign In',
              style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}
