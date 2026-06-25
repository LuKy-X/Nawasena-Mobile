import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';

class StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double fontSize;

  const StatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
