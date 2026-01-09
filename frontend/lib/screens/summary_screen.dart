import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketa_expense_tracker/models/expense.dart';
import 'package:pocketa_expense_tracker/providers/summary_provider.dart';
import 'package:pocketa_expense_tracker/utils/constants.dart';
import 'package:pocketa_expense_tracker/widgets/loading_indicator.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Color _getCategoryColor(Category category) {
    return AppConstants.categoryColors[category.name] ?? Colors.grey;
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_car;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.entertainment:
        return Icons.movie;
      case Category.bills:
        return Icons.receipt;
      case Category.other:
        return Icons.category;
    }
  }

  Widget _buildCategoryIcon(Category category) {
    final color = _getCategoryColor(category);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Icon(
        _getCategoryIcon(category),
        color: color,
        size: 20,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadSummaryForTab(_tabController.index);
      }
    });
    // Delay loading to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummaryForTab(0);
    });
  }

  void _loadSummaryForTab(int index) {
    final now = DateTime.now();
    switch (index) {
      case 0: // Daily
        ref.read(summaryProvider.notifier).loadDailySummary(null);
        break;
      case 1: // Weekly
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        ref.read(summaryProvider.notifier).loadWeeklySummary(
              startDate: startOfWeek,
              endDate: endOfWeek,
            );
        break;
      case 2: // Monthly
        ref.read(summaryProvider.notifier).loadMonthlySummary(
              year: now.year,
              month: now.month,
            );
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(summaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailySummary(summaryState),
          _buildWeeklySummary(summaryState),
          _buildMonthlySummary(summaryState),
        ],
      ),
    );
  }

  Widget _buildDailySummary(SummaryState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    final summary = state.dailySummary;
    if (summary == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ₹${summary.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('${summary.count} expenses'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...summary.breakdown.map((breakdown) => Card(
                child: ListTile(
                  leading: _buildCategoryIcon(breakdown.category),
                  title: Text(breakdown.category.displayName),
                  subtitle: Text('${breakdown.count} expenses'),
                  trailing: Text(
                    '₹${breakdown.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(SummaryState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    final summary = state.weeklySummary;
    if (summary == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ₹${summary.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('${summary.count} expenses'),
                  const SizedBox(height: 8),
                  Text(
                    '${summary.startDate} to ${summary.endDate}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...summary.breakdown.map((breakdown) => Card(
                child: ListTile(
                  leading: _buildCategoryIcon(breakdown.category),
                  title: Text(breakdown.category.displayName),
                  subtitle: Text('${breakdown.count} expenses'),
                  trailing: Text(
                    '₹${breakdown.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(SummaryState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    final summary = state.monthlySummary;
    if (summary == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ₹${summary.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('${summary.count} expenses'),
                  const SizedBox(height: 8),
                  Text(
                    '${summary.month} ${summary.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...summary.breakdown.map((breakdown) => Card(
                child: ListTile(
                  leading: _buildCategoryIcon(breakdown.category),
                  title: Text(breakdown.category.displayName),
                  subtitle: Text('${breakdown.count} expenses'),
                  trailing: Text(
                    '₹${breakdown.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
