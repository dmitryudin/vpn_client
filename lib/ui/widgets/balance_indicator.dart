import 'package:flutter/material.dart';

class BalanceIndicator extends StatefulWidget {
  final int initialBalance;

  BalanceIndicator({required this.initialBalance});

  @override
  _BalanceIndicatorState createState() => _BalanceIndicatorState();
}

class _BalanceIndicatorState extends State<BalanceIndicator> {
  late int balance;

  @override
  void initState() {
    super.initState();
    balance = widget.initialBalance;
    _scheduleDailyDeduction();
  }

  void _scheduleDailyDeduction() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);
    Future.delayed(duration, () {
      setState(() {
        balance -= 1;
      });
      _scheduleDailyDeduction();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Баланс: $balance',
          style: TextStyle(
            fontSize: 24,
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 20),
        CircularProgressIndicator(
          value: balance / 10,
          backgroundColor: colorScheme.background,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ],
    );
  }
}
