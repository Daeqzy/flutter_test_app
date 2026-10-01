import 'package:flutter/material.dart';

class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  final bool boxed;

  final String? badgeText;
  final IconData? badgeIcon;
  final Color? badgeColor;

  const AppEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.boxed = false,
    this.badgeText,
    this.badgeIcon,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final resolvedBadgeColor = badgeColor ?? colors.primary;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 30, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),

          if (badgeText != null) ...[
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: resolvedBadgeColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeIcon != null) ...[
                    Icon(badgeIcon, size: 15, color: resolvedBadgeColor),

                    const SizedBox(width: 6),
                  ],

                  Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: resolvedBadgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (!boxed) {
      return Center(child: content);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: content,
    );
  }
}
