import 'package:flutter/material.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String currency;
  final bool showPlusSign;

  const AmountText(
      this.amount, {
        super.key,
        this.style,
        this.currency = 'AED',
        this.showPlusSign = false,
      });

  String _formatAmount(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatted = _formatAmount(amount.abs()); // absolute value for formatting
    String sign = amount < 0 ? '-' : (showPlusSign ? '+' : '');

    return Text(
      "$sign$currency $formatted",
      style: style ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
    );
  }
}