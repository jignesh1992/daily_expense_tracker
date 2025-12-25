import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showCurrency;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.style,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: showCurrency ? '₹' : '',
      decimalDigits: 2,
    );

    return Text(
      formatter.format(amount),
      style: style ?? Theme.of(context).textTheme.headlineMedium,
    );
  }
}
