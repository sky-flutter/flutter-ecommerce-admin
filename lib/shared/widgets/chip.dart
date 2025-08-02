import 'package:flutter/material.dart';

Widget buildStatusChip(String label, bool isActive, Color color,
    {bool isBorderOnly = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isBorderOnly
          ? Colors.transparent
          : isActive
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: isBorderOnly
          ? Border.all(
              color: isActive
                  ? color.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
            )
          : null,
    ),
    child: Text(
      label,
      style: TextStyle(
        color: isActive ? color : Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
