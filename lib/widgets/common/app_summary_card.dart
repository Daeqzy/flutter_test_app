import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? detail;
  final Widget? trailing;

  const AppSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.detail,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [AppColors.primary, AppColors.primaryDark],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),

            blurRadius: 18,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          // ====================================================
          // ICON
          // ====================================================

          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: Colors.white, size: 22),
          ),

          const SizedBox(width: 13),

          // ====================================================
          // TEXT
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,

                  style: TextStyle(
                    fontSize: 11.5,

                    fontWeight: FontWeight.w500,

                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),

                if (detail != null && detail!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),

                  Text(
                    detail!,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 10.5,

                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
