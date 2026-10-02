import 'package:flutter/material.dart';

class AppStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool showDot;

  const AppStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 120),

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.09),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.21 : 0.05),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          if (showDot)
            Container(
              width: 6,
              height: 6,

              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else if (icon != null)
            Icon(icon, size: 13, color: color),

          if (showDot || icon != null) const SizedBox(width: 5),

          Flexible(
            child: Text(
              text.trim(),

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
