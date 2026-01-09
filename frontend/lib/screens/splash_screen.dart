import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketa_expense_tracker/providers/auth_provider.dart';
import 'package:pocketa_expense_tracker/screens/login_screen.dart';
import 'package:pocketa_expense_tracker/screens/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  void _navigate(AuthState authState) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    if (authState.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen to auth state changes and navigate when loading completes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        _navigate(next);
      }
    });

    // If already loaded (not loading), navigate immediately
    if (!authState.isLoading && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigate(authState);
      });
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
