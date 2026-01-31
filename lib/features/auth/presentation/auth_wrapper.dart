import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../navigation/main_navigation_shell.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check for existing session after first frame
    // Only check if we're not already in a determined state (e.g., after logout)
    Future.microtask(() {
      final currentState = ref.read(authControllerProvider);
      if (currentState is AuthIdle) {
        // Already idle (logged out), no need to check
        return;
      }
      ref.read(authControllerProvider.notifier).checkAuth();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh KYC status when app comes back to foreground
    // This ensures verified status updates after admin verification
    if (state == AppLifecycleState.resumed) {
      final authState = ref.read(authControllerProvider);
      if (authState is AuthSuccess) {
        ref.invalidate(kycStatusControllerProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return switch (state) {
      AuthSuccess() => const MainNavigationShell(),
      AuthIdle() || AuthError() => const LoginScreen(),
      AuthLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}
