import 'package:flutter/material.dart';

class RushIndicator extends StatelessWidget {
  final String rushLevel;  // "Low", "Medium", "High"
  final int waitingCount;
  final String estimatedWait;

  const RushIndicator({
    super.key,
    required this.rushLevel,
    required this.waitingCount,
    required this.estimatedWait,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rush Level Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _dotColor.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          
          // Rush Level Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$rushLevel Rush",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _textColor,
                ),
              ),
              Text(
                "$waitingCount waiting • $estimatedWait",
                style: TextStyle(
                  fontSize: 11,
                  color: _textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _dotColor {
    switch (rushLevel) {
      case 'Low':
        return const Color(0xFF4CAF50); // Green
      case 'Medium':
        return const Color(0xFFFFC107); // Amber
      case 'High':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  Color get _backgroundColor {
    switch (rushLevel) {
      case 'Low':
        return const Color(0xFFE8F5E9); // Light green
      case 'Medium':
        return const Color(0xFFFFF8E1); // Light amber
      case 'High':
        return const Color(0xFFFFEBEE); // Light red
      default:
        return Colors.grey[100]!;
    }
  }

  Color get _borderColor {
    switch (rushLevel) {
      case 'Low':
        return const Color(0xFF4CAF50).withOpacity(0.3);
      case 'Medium':
        return const Color(0xFFFFC107).withOpacity(0.3);
      case 'High':
        return const Color(0xFFF44336).withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }

  Color get _textColor {
    switch (rushLevel) {
      case 'Low':
        return const Color(0xFF2E7D32); // Dark green
      case 'Medium':
        return const Color(0xFFF57C00); // Dark amber
      case 'High':
        return const Color(0xFFC62828); // Dark red
      default:
        return Colors.grey[700]!;
    }
  }
}
