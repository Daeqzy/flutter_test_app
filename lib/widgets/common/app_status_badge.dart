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
      constraints: const BoxConstraints(maxWidth: 130),

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.10 : 0.06),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          if (showDot)
            Container(
              width: 5,
              height: 5,

              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else if (icon != null)
            Icon(icon, size: 11, color: color),

          if (showDot || icon != null) const SizedBox(width: 4),

          Flexible(
            child: Text(
              text.trim(),

              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 9.5,
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
