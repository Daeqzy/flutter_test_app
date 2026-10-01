import 'package:flutter/material.dart';

class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final bool boxed;

  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: isDark ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.error.withValues(alpha: isDark ? 0.20 : 0.05),
              ),
            ),
            child: Icon(Icons.cloud_off_rounded, size: 32, color: colors.error),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.4,
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: 180,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text('Try again'),
            ),
          ),
        ],
      ),
    );

    if (!boxed) {
      return Center(child: SingleChildScrollView(child: content));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.02),
            blurRadius: isDark ? 16 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: content,
    );
  }
}
