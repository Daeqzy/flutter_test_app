import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/preferences/preferences_bloc.dart';
import '../../bloc/preferences/preferences_event.dart';
import '../../bloc/preferences/preferences_state.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/app_section_header.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        toolbarHeight: 68,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Preferences',

              style: TextStyle(
                fontSize: 18,

                fontWeight: FontWeight.w800,

                letterSpacing: -0.3,

                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Customize your workspace',

              style: TextStyle(
                fontSize: 11.5,

                fontWeight: FontWeight.w500,

                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),

      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _PreferencesHero(themeMode: state.themeMode),

                const SizedBox(height: 24),

                const AppSectionHeader(
                  title: 'Appearance',

                  subtitle: 'Choose how CODEX looks on this device',
                ),

                const SizedBox(height: 12),

                _PreferenceCard(
                  child: Column(
                    children: [
                      _ThemeOption(
                        icon: Icons.settings_suggest_outlined,

                        title: 'System',

                        subtitle: 'Follow your device appearance',

                        value: ThemeMode.system,

                        selected: state.themeMode == ThemeMode.system,

                        accent: AppColors.partnersAccent,
                      ),

                      const _PreferenceDivider(),

                      _ThemeOption(
                        icon: Icons.light_mode_outlined,

                        title: 'Light',

                        subtitle: 'Always use the light theme',

                        value: ThemeMode.light,

                        selected: state.themeMode == ThemeMode.light,

                        accent: AppColors.notificationsAccent,
                      ),

                      const _PreferenceDivider(),

                      _ThemeOption(
                        icon: Icons.dark_mode_outlined,

                        title: 'Dark',

                        subtitle: 'Always use the dark theme',

                        value: ThemeMode.dark,

                        selected: state.themeMode == ThemeMode.dark,

                        accent: AppColors.profileAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                const AppSectionHeader(
                  title: 'About preferences',

                  subtitle: 'Settings stored locally on this device',
                ),

                const SizedBox(height: 12),

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

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [
            AppColors.preferencesAccent,

            AppColors.preferencesAccentDark,
          ],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: AppColors.preferencesAccent.withValues(alpha: 0.13),

            blurRadius: 18,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46,

            height: 46,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.tune_rounded,

              size: 22,

              color: Colors.white,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Your workspace',

                  style: TextStyle(
                    fontSize: 17,

                    fontWeight: FontWeight.w800,

                    letterSpacing: -0.3,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Personalize the CODEX experience.',

                  style: TextStyle(
                    fontSize: 11,

                    height: 1.35,

                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Icon(modeIcon, size: 18, color: Colors.white),

              const SizedBox(height: 4),

              Text(
                modeText,

                style: TextStyle(
                  fontSize: 9.5,

                  fontWeight: FontWeight.w700,

                  color: Colors.white.withValues(alpha: 0.88),
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
// CARD
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
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),

      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
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

  final Color accent;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? accent.withValues(alpha: isDark ? 0.075 : 0.035)
          : Colors.transparent,

      child: InkWell(
        onTap: () {
          context.read<PreferencesBloc>().add(ThemeModeChanged(value));
        },

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

          child: Row(
            children: [
              Container(
                width: 38,

                height: 38,

                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.16 : 0.08),

                  borderRadius: BorderRadius.circular(11),
                ),

                child: Icon(icon, size: 19, color: accent),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 13.5,

                        fontWeight: FontWeight.w700,

                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,

                      style: TextStyle(
                        fontSize: 10.5,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              AnimatedContainer(
                duration: const Duration(milliseconds: 180),

                width: 22,

                height: 22,

                decoration: BoxDecoration(
                  color: selected ? accent : Colors.transparent,

                  shape: BoxShape.circle,

                  border: Border.all(
                    width: selected ? 0 : 1.5,

                    color: selected ? accent : colors.outlineVariant,
                  ),
                ),

                child: selected
                    ? const Icon(
                        Icons.check_rounded,

                        size: 14,

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

    return Divider(
      height: 1,

      indent: 64,

      endIndent: 14,

      color: colors.outlineVariant.withValues(alpha: 0.60),
    );
  }
}

// ============================================================
// LOCAL INFO
// ============================================================

class _LocalPreferencesInfo extends StatelessWidget {
  const _LocalPreferencesInfo();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      decoration: BoxDecoration(
        color: AppColors.preferencesAccent.withValues(
          alpha: isDark ? 0.08 : 0.045,
        ),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.phone_android_rounded,

            size: 19,

            color: AppColors.preferencesAccent,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Stored on this device',

                  style: TextStyle(
                    fontSize: 12.5,

                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Your appearance preference is stored locally '
                  'and restored when you reopen CODEX.',

                  style: TextStyle(
                    fontSize: 10.5,

                    height: 1.4,

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
