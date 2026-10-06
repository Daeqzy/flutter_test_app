import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppSectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colors.onSurface,
          ),
        ),

        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 3),

          Text(
            subtitle!,

            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
