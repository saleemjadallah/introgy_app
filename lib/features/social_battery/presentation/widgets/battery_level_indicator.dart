import 'package:flutter/material.dart';

class BatteryLevelIndicator extends StatelessWidget {
  final double level;

  const BatteryLevelIndicator({
    super.key,
    required this.level,
  }) : assert(level >= 0 && level <= 1, 'Level must be between 0 and 1');

  Color _getBatteryColor(double level) {
    if (level < 0.3) {
      return Colors.red;
    } else if (level < 0.6) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getBatteryText(double level) {
    if (level < 0.3) {
      return 'Low';
    } else if (level < 0.6) {
      return 'Medium';
    } else {
      return 'High';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBatteryColor(level);
    final text = _getBatteryText(level);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Battery Level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${(level * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: level,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 20,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.battery_full,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement update battery level
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
