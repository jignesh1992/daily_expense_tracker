import 'package:pocketa_expense_tracker/models/expense.dart';

class CategoryBreakdown {
  final Category category;
  final double amount;
  final int count;

  CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.count,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: Category.fromString(json['category'] as String),
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'amount': amount,
      'count': count,
    };
  }
}

class DailySummary {
  final String date;
  final double total;
  final int count;
  final List<CategoryBreakdown> breakdown;

  DailySummary({
    required this.date,
    required this.total,
    required this.count,
    required this.breakdown,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] as String,
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
      breakdown: (json['breakdown'] as List)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total': total,
      'count': count,
      'breakdown': breakdown.map((e) => e.toJson()).toList(),
    };
  }
}

class WeeklySummary {
  final String week;
  final String startDate;
  final String endDate;
  final double total;
  final int count;
  final List<CategoryBreakdown> breakdown;
  final List<DailyTotal> dailyTotals;

  WeeklySummary({
    required this.week,
    required this.startDate,
    required this.endDate,
    required this.total,
    required this.count,
    required this.breakdown,
    required this.dailyTotals,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      week: json['week'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
      breakdown: (json['breakdown'] as List)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyTotals: (json['dailyTotals'] as List)
          .map((e) => DailyTotal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlySummary {
  final String month;
  final int year;
  final double total;
  final int count;
  final List<CategoryBreakdown> breakdown;
  final List<DailyTotal> dailyTotals;

  MonthlySummary({
    required this.month,
    required this.year,
    required this.total,
    required this.count,
    required this.breakdown,
    required this.dailyTotals,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      month: json['month'] as String,
      year: json['year'] as int,
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
      breakdown: (json['breakdown'] as List)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyTotals: (json['dailyTotals'] as List)
          .map((e) => DailyTotal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyTotal {
  final String date;
  final double total;

  DailyTotal({
    required this.date,
    required this.total,
  });

  factory DailyTotal.fromJson(Map<String, dynamic> json) {
    return DailyTotal(
      date: json['date'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }
}
