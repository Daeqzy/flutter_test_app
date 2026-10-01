import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/preferences/preferences_bloc.dart';
import '../../bloc/preferences/preferences_event.dart';
import '../../bloc/preferences/preferences_state.dart';

import '../../widgets/common/app_section_header.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        toolbarHeight: 72,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Preferences',

              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,

                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Customize your workspace',

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,

                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // CONTENT
      // ========================================================
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HERO
                // ==================================================

                _PreferencesHero(themeMode: state.themeMode),

                const SizedBox(height: 28),

                // ==================================================
                // APPEARANCE
                // ==================================================
                const AppSectionHeader(
                  title: 'Appearance',
                  subtitle: 'Choose how CODEX looks on this device',
                ),

                const SizedBox(height: 14),

                _PreferenceCard(
                  child: Column(
                    children: [
                      _ThemeOption(
                        icon: Icons.settings_suggest_outlined,

                        title: 'System',

                        subtitle: 'Follow your device appearance',

                        value: ThemeMode.system,

                        selected: state.themeMode == ThemeMode.system,
                      ),

                      const _PreferenceDivider(),

                      _ThemeOption(
                        icon: Icons.light_mode_outlined,

                        title: 'Light',

                        subtitle: 'Always use the light theme',

                        value: ThemeMode.light,

                        selected: state.themeMode == ThemeMode.light,
                      ),

                      const _PreferenceDivider(),

                      _ThemeOption(
                        icon: Icons.dark_mode_outlined,

                        title: 'Dark',

                        subtitle: 'Always use the dark theme',

                        value: ThemeMode.dark,

                        selected: state.themeMode == ThemeMode.dark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // LOCAL SETTINGS
                // ==================================================
                const AppSectionHeader(
                  title: 'About preferences',
                  subtitle: 'Settings stored locally on this device',
                ),

                const SizedBox(height: 14),

                const _LocalPreferencesInfo(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _PreferencesHero extends StatelessWidget {
  final ThemeMode themeMode;

  const _PreferencesHero({required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final modeText = switch (themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

    final modeIcon = switch (themeMode) {
      ThemeMode.system => Icons.settings_suggest_outlined,

      ThemeMode.light => Icons.light_mode_outlined,

      ThemeMode.dark => Icons.dark_mode_outlined,
    };

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [colors.primary, colors.primary.withValues(alpha: 0.82)],
        ),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.20),

            blurRadius: 28,

            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Stack(
        children: [
          // ----------------------------------------------------
          // BACKGROUND DECORATION
          // ----------------------------------------------------

          Positioned(
            right: -35,
            top: -45,

            child: Container(
              width: 135,
              height: 135,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),

                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 30,
            bottom: -55,

            child: Container(
              width: 110,
              height: 110,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),

                shape: BoxShape.circle,
              ),
            ),
          ),

          // ----------------------------------------------------
          // CONTENT
          // ----------------------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),

                      borderRadius: BorderRadius.circular(15),

                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),

                    child: const Icon(
                      Icons.tune_rounded,

                      color: Colors.white,

                      size: 23,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(modeIcon, size: 14, color: Colors.white),

                        const SizedBox(width: 5),

                        Text(
                          modeText,

                          style: const TextStyle(
                            fontSize: 10,

                            fontWeight: FontWeight.w700,

                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Your workspace',

                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,

                  color: Colors.white,

                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Personalize how the CODEX application '
                'looks and behaves.',

                style: TextStyle(
                  height: 1.4,

                  fontSize: 13,

                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PREFERENCE CARD
// ============================================================

class _PreferenceCard extends StatelessWidget {
  final Widget child;

  const _PreferenceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        // Important:
        // visually separate the card from
        // the dark page background.
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.025),

            blurRadius: isDark ? 16 : 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: child,
    );
  }
}

// ============================================================
// THEME OPTION
// ============================================================

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final ThemeMode value;
  final bool selected;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: isDark ? 0.055 : 0.025)
          : Colors.transparent,

      borderRadius: BorderRadius.circular(22),

      child: InkWell(
        onTap: () {
          context.read<PreferencesBloc>().add(ThemeModeChanged(value));
        },

        borderRadius: BorderRadius.circular(22),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              // ================================================
              // ICON TILE
              // ================================================

              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: isDark ? 0.18 : 0.11)
                      : colors.surfaceContainerHighest,

                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(
                    color: selected
                        ? colors.primary.withValues(alpha: isDark ? 0.24 : 0.10)
                        : colors.outlineVariant,
                  ),
                ),

                child: Icon(
                  icon,

                  size: 21,

                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 14),

              // ================================================
              // TEXT
              // ================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 14,

                        fontWeight: FontWeight.w700,

                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,

                      style: TextStyle(
                        fontSize: 12,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ================================================
              // SELECTION INDICATOR
              // ================================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),

                width: 24,
                height: 24,

                decoration: BoxDecoration(
                  color: selected ? colors.primary : Colors.transparent,

                  shape: BoxShape.circle,

                  border: Border.all(
                    width: 2,

                    color: selected ? colors.primary : colors.outline,
                  ),
                ),

                child: selected
                    ? const Icon(
                        Icons.check_rounded,

                        size: 15,

                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _PreferenceDivider extends StatelessWidget {
  const _PreferenceDivider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Divider(height: 1, indent: 74, color: colors.outlineVariant);
  }
}

// ============================================================
// LOCAL PREFERENCES INFO
// ============================================================

class _LocalPreferencesInfo extends StatelessWidget {
  const _LocalPreferencesInfo();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.025),

            blurRadius: isDark ? 16 : 10,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.17 : 0.10),

              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.21 : 0.07),
              ),
            ),

            child: Icon(
              Icons.phone_android_rounded,

              size: 21,

              color: colors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Stored on this device',

                  style: TextStyle(
                    fontSize: 14,

                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Your appearance preferences are saved '
                  'locally and restored when you reopen the app.',

                  style: TextStyle(
                    height: 1.45,

                    fontSize: 12,

                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
