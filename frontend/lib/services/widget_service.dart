import 'package:flutter/services.dart';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('com.pocketa.widget');

  static Future<void> addExpenseFromWidget({
    required double amount,
    required String category,
    String? description,
  }) async {
    try {
      await _channel.invokeMethod('addExpense', {
        'amount': amount,
        'category': category,
        'description': description,
      });
    } catch (e) {
      print('Error adding expense from widget: $e');
    }
  }

  static Future<void> updateWidget() async {
    try {
      await _channel.invokeMethod('updateWidget');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}
