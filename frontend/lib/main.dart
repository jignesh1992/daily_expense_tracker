import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pocketa_expense_tracker/services/firebase_service.dart';
import 'package:pocketa_expense_tracker/screens/splash_screen.dart';
import 'package:pocketa_expense_tracker/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: PocketaExpenseTracker(),
    ),
  );
}

class PocketaExpenseTracker extends StatelessWidget {
  const PocketaExpenseTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocketa: Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
