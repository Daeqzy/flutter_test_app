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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),

        decoration: BoxDecoration(
          color: isDark
              ? colors.surfaceContainerHigh.withValues(alpha: 0.55)
              : colors.surfaceContainerHighest.withValues(alpha: 0.32),

          borderRadius: BorderRadius.circular(13),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            // ==================================================
            // ICON
            // ==================================================

            SizedBox(
              width: 32,
              height: 32,

              child: Center(child: Icon(icon, size: 17, color: colors.primary)),
            ),

            const SizedBox(width: 9),

            // ==================================================
            // CONTENT
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    label,

                    style: TextStyle(
                      fontSize: 9.5,

                      fontWeight: FontWeight.w600,

                      letterSpacing: 0.15,

                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 3),

                  if (selectable)
                    SelectableText(
                      value.trim(),

                      style: TextStyle(
                        fontSize: 12.5,

                        height: 1.35,

                        fontWeight: FontWeight.w600,

                        color: colors.onSurface,
                      ),
                    )
                  else
                    Text(
                      value.trim(),

                      style: TextStyle(
                        fontSize: 12.5,

                        height: 1.35,

                        fontWeight: FontWeight.w600,

                        color: colors.onSurface,
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // ACTION
            // ==================================================
            if (onTap != null) ...[
              const SizedBox(width: 8),

              Material(
                color: Colors.transparent,

                borderRadius: BorderRadius.circular(10),

                child: InkWell(
                  onTap: onTap,

                  borderRadius: BorderRadius.circular(10),

                  child: SizedBox(
                    width: 36,
                    height: 36,

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
