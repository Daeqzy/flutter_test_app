import 'package:flutter/material.dart';

class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  final bool selectable;
  final bool isLast;

  final VoidCallback? onTap;
  final IconData? actionIcon;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.selectable = false,
    this.isLast = false,
    this.onTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),

        decoration: BoxDecoration(
          color: isDark
              ? colors.surfaceContainerHighest
              : colors.surfaceContainerHighest.withValues(alpha: 0.55),

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: colors.outlineVariant.withValues(
              alpha: isDark ? 0.75 : 0.40,
            ),
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Container(
              width: 36,
              height: 36,

              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: isDark ? 0.17 : 0.10),

                borderRadius: BorderRadius.circular(11),

                border: Border.all(
                  color: colors.primary.withValues(alpha: isDark ? 0.20 : 0.05),
                ),
              ),

              child: Icon(icon, size: 17, color: colors.primary),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    label,

                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 3),

                  if (selectable)
                    SelectableText(
                      value.trim(),

                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    )
                  else
                    Text(
                      value.trim(),

                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                ],
              ),
            ),

            if (onTap != null) ...[
              const SizedBox(width: 8),

              Material(
                color: colors.primary.withValues(alpha: isDark ? 0.17 : 0.10),

                borderRadius: BorderRadius.circular(12),

                child: InkWell(
                  borderRadius: BorderRadius.circular(12),

                  onTap: onTap,

                  child: Container(
                    width: 40,
                    height: 40,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: colors.primary.withValues(
                          alpha: isDark ? 0.20 : 0.05,
                        ),
                      ),
                    ),

                    child: Icon(
                      actionIcon ?? Icons.arrow_outward_rounded,

                      size: 18,

                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
