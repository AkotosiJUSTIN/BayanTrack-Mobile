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
    debugPrint('[AuthWrapper] Initializing...');

    // Only validate the session on initial startup
    Future.microtask(() {
      final currentState = ref.read(authControllerProvider);
      if (currentState is AuthInitial) {
        debugPrint('[AuthWrapper] Running initial checkAuth()');
        ref.read(authControllerProvider.notifier).checkAuth();
      } else {
        debugPrint(
          '[AuthWrapper] Skipping checkAuth() - state is ${currentState.runtimeType}',
        );
      }
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
    debugPrint('[AuthWrapper] AuthState changed: ${state.runtimeType}');

    return switch (state) {
      AuthSuccess() => const MainNavigationShell(),
      AuthIdle() || AuthError() => const LoginScreen(),
      AuthInitial() || AuthLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}
