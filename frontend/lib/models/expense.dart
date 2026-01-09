enum Category {
  food,
  transport,
  shopping,
  entertainment,
  bills,
  other;

  static Category fromString(String value) {
    return Category.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Category.other,
    );
  }

  String get displayName {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.transport:
        return 'Transport';
      case Category.shopping:
        return 'Shopping';
      case Category.entertainment:
        return 'Entertainment';
      case Category.bills:
        return 'Bills';
      case Category.other:
        return 'Other';
    }
  }
}

class Expense {
  final String id;
  final String userId;
  final double amount;
  final Category category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Parse the date string and extract just the date part (YYYY-MM-DD)
    // This avoids timezone conversion issues
    final dateString = json['date'] as String;
    final parsedDate = DateTime.parse(dateString);
    
    // Extract date components from UTC to avoid timezone shifts
    // Then create a local date with those components
    final utcDate = parsedDate.isUtc ? parsedDate : parsedDate.toUtc();
    final localDate = DateTime(
      utcDate.year,
      utcDate.month,
      utcDate.day,
    );
    
    return Expense(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: Category.fromString(json['category'] as String),
      description: json['description'] as String?,
      date: localDate,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    // Convert date to UTC midnight to avoid timezone shifts
    // This ensures Jan 6 stays Jan 6 regardless of timezone
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category.name,
      'description': description,
      // Send as UTC midnight to avoid timezone conversion issues
      'date': utcDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    Category? category,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
