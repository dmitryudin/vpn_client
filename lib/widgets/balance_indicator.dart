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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Balance: $balance',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 20),
        CircularProgressIndicator(
          value: balance / 10,
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }
}
