import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketa_expense_tracker/providers/auth_provider.dart';
import 'package:pocketa_expense_tracker/providers/expense_provider.dart';
import 'package:pocketa_expense_tracker/providers/summary_provider.dart';
import 'package:pocketa_expense_tracker/screens/voice_input_screen.dart';
import 'package:pocketa_expense_tracker/screens/manual_entry_screen.dart';
import 'package:pocketa_expense_tracker/screens/expense_list_screen.dart';
import 'package:pocketa_expense_tracker/screens/summary_screen.dart';
import 'package:pocketa_expense_tracker/screens/login_screen.dart';
import 'package:pocketa_expense_tracker/widgets/expense_card.dart';
import 'package:pocketa_expense_tracker/widgets/category_chip.dart';
import 'package:pocketa_expense_tracker/widgets/loading_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load data once when the screen is first mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        ref.read(summaryProvider.notifier).loadDailySummary(null);
        ref.read(expenseProvider.notifier).loadExpenses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final summaryState = ref.watch(summaryProvider);
    final expenseState = ref.watch(expenseProvider);

    // Listen to auth state changes and navigate to login when user logs out
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocketa Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SummaryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).signOut();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expenseProvider.notifier).loadExpenses();
          await ref.read(summaryProvider.notifier).loadDailySummary(null);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (summaryState.isLoading)
                        const LoadingIndicator()
                      else if (summaryState.dailySummary != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${summaryState.dailySummary!.total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${summaryState.dailySummary!.count} expenses',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (summaryState.dailySummary!.breakdown.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: summaryState.dailySummary!.breakdown
                                    .map((breakdown) => CategoryChip(
                                          category: breakdown.category,
                                          amount: breakdown.amount,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        )
                      else
                        Text(
                          'No expenses today',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VoiceInputScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.mic),
                      label: const Text('Voice'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ManualEntryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Manual'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recent Expenses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ExpenseListScreen(),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (expenseState.isLoading)
                const LoadingIndicator()
              else if (expenseState.expenses.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No expenses yet',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                )
              else
                ...expenseState.expenses.take(5).map((expense) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExpenseCard(expense: expense),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
