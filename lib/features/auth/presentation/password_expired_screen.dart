import 'package:flutter/material.dart';

import 'change_password_screen.dart';

class PasswordExpiredScreen extends StatelessWidget {
  const PasswordExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: ChangePasswordScreen(requiredChange: true),
    );
  }
}
