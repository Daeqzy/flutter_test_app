import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/partners/partners_bloc.dart';
import '../../bloc/partners/partners_event.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';

import '../../repositories/data_repository.dart';

import '../home/partners_screen.dart';

// ============================================================
// SERVICES SCREEN
// ============================================================

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADER
            // ==================================================

            BlocBuilder<UserBloc, UserState>(
              buildWhen: (previous, current) {
                return previous.authenticatedUsername !=
                    current.authenticatedUsername;
              },

              builder: (context, state) {
                final username = state.authenticatedUsername.trim().isNotEmpty
                    ? state.authenticatedUsername
                    : 'CODEX User';

                return _ServicesHeader(username: username);
              },
            ),

            const SizedBox(height: 24),

            // ==================================================
            // WORKSPACE
            // ==================================================
            const _SectionHeader(
              title: 'Workspace services',
              subtitle:
                  'Quick access to partner information and business tools.',
            ),

            const SizedBox(height: 12),

            // ==================================================
            // PARTNER DIRECTORY
            // ==================================================
            _LargeServiceCard(
              icon: Icons.business_rounded,

              title: 'Partner Directory',

              subtitle: 'Search and browse all available CODEX partners.',

              badge: 'Directory',

              onTap: () {
                _openPartners(context, instruction: null);
              },
            ),

            const SizedBox(height: 14),

            // ==================================================
            // CONNECTIONS + AGREEMENTS
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: _ServiceCard(
                    icon: Icons.lan_outlined,

                    title: 'Connections',

                    subtitle: 'Remote access, network and system information.',

                    onTap: () {
                      _openPartners(
                        context,
                        instruction: 'Select a partner and tap Connections.',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _ServiceCard(
                    icon: Icons.description_outlined,

                    title: 'Agreements',

                    subtitle: 'View partner agreements and their status.',

                    onTap: () {
                      _openPartners(
                        context,
                        instruction: 'Select a partner and tap Agreements.',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // CONTACTS + LOCATIONS
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: _ServiceCard(
                    icon: Icons.people_outline_rounded,

                    title: 'Contacts',

                    subtitle:
                        'Partner phone numbers, email and contact information.',

                    onTap: () {
                      _openPartners(
                        context,
                        instruction: 'Select a partner and tap Contacts.',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _ServiceCard(
                    icon: Icons.map_outlined,

                    title: 'Locations',

                    subtitle:
                        'Find partner addresses and open their map location.',

                    onTap: () {
                      _openPartners(
                        context,
                        instruction:
                            'Select a partner and tap the location icon.',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // PARTNER WORKFLOW
            // ==================================================
            const _SectionHeader(
              title: 'Partner workflow',
              subtitle: 'All business information starts from a partner.',
            ),

            const SizedBox(height: 14),

            _WorkflowCard(isDark: isDark),

            const SizedBox(height: 20),

            // ==================================================
            // DATA INFO
            // ==================================================
            const _DataInfoCard(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // OPEN PARTNER DIRECTORY
  // ==========================================================

  void _openPartners(BuildContext context, {required String? instruction}) {
    final repository = context.read<DataRepository>();

    final messenger = ScaffoldMessenger.of(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              PartnersBloc(repository)..add(const PartnersRequested()),

          child: const PartnersScreen(),
        ),
      ),
    );

    // ----------------------------------------------------------
    // OPTIONAL FEATURE INSTRUCTION
    // ----------------------------------------------------------

    if (instruction != null) {
      Future.delayed(const Duration(milliseconds: 350), () {
        messenger.hideCurrentSnackBar();

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: 20,
                ),

                const SizedBox(width: 10),

                Expanded(child: Text(instruction)),
              ],
            ),

            behavior: SnackBarBehavior.floating,

            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }
}

// ============================================================
// SERVICES HEADER
// ============================================================

class _ServicesHeader extends StatelessWidget {
  final String username;

  const _ServicesHeader({required this.username});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [colors.primary, colors.primary.withValues(alpha: 0.86)],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.10),

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

            child: const Icon(
              Icons.grid_view_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 13),

          // ====================================================
          // TEXT
          // ====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Services',

                  style: TextStyle(
                    fontSize: 18,

                    fontWeight: FontWeight.w800,

                    letterSpacing: -0.35,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Workspace for $username',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 11.5,

                    fontWeight: FontWeight.w500,

                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Access partner tools and business information.',

                  style: TextStyle(
                    fontSize: 11,

                    height: 1.35,

                    color: Colors.white.withValues(alpha: 0.68),
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

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;

  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

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

        const SizedBox(height: 4),

        Text(
          subtitle,

          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ============================================================
// LARGE SERVICE CARD
// ============================================================

class _LargeServiceCard extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final String badge;

  final VoidCallback onTap;

  const _LargeServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? colors.surfaceContainerHigh : colors.surface,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.65),
            ),
          ),

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.08),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, size: 22, color: colors.primary),
              ),

              const SizedBox(width: 13),

              // ==================================================
              // CONTENT
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,

                            style: TextStyle(
                              fontSize: 14.5,

                              fontWeight: FontWeight.w700,

                              color: colors.onSurface,
                            ),
                          ),
                        ),

                        Text(
                          badge,

                          style: TextStyle(
                            fontSize: 9.5,

                            fontWeight: FontWeight.w700,

                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,

                      style: TextStyle(
                        fontSize: 11.5,

                        height: 1.35,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,

                size: 20,

                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SERVICE CARD
// ============================================================

class _ServiceCard extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? colors.surfaceContainerHigh : colors.surface,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          constraints: const BoxConstraints(minHeight: 154),

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.65),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ICON / ARROW
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,

                    decoration: BoxDecoration(
                      color: colors.primary.withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(icon, size: 20, color: colors.primary),
                  ),

                  // IMPORTANT:
                  // This Spacer is safe because
                  // it is inside a Row.
                  const Spacer(),

                  Icon(
                    Icons.arrow_outward_rounded,

                    size: 17,

                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),

              // IMPORTANT:
              // Do NOT use Spacer here.
              // The old vertical Spacer caused
              // the login/MainScreen layout issue.
              const SizedBox(height: 18),

              // ==================================================
              // TITLE
              // ==================================================
              Text(
                title,

                style: TextStyle(
                  fontSize: 14,

                  fontWeight: FontWeight.w700,

                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 5),

              // ==================================================
              // DESCRIPTION
              // ==================================================
              Text(
                subtitle,

                maxLines: 3,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 11,

                  height: 1.35,

                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WORKFLOW CARD
// ============================================================

class _WorkflowCard extends StatelessWidget {
  final bool isDark;

  const _WorkflowCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),

      child: const Column(
        children: [
          _WorkflowStep(
            number: '1',

            icon: Icons.business_outlined,

            title: 'Choose partner',

            subtitle: 'Search the partner directory.',
          ),

          _WorkflowConnector(),

          _WorkflowStep(
            number: '2',

            icon: Icons.touch_app_outlined,

            title: 'Choose an action',

            subtitle: 'Connections, agreements, contacts or map.',
          ),

          _WorkflowConnector(),

          _WorkflowStep(
            number: '3',

            icon: Icons.cloud_done_outlined,

            title: 'Load live data',

            subtitle: 'Retrieve the selected partner data from the backend.',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WORKFLOW STEP
// ============================================================

class _WorkflowStep extends StatelessWidget {
  final String number;

  final IconData icon;

  final String title;

  final String subtitle;

  const _WorkflowStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        // ====================================================
        // STEP NUMBER
        // ====================================================

        Container(
          width: 32,
          height: 32,

          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.08),

            borderRadius: BorderRadius.circular(10),
          ),

          child: Text(
            number,

            style: TextStyle(
              fontSize: 11,

              fontWeight: FontWeight.w800,

              color: colors.primary,
            ),
          ),
        ),

        const SizedBox(width: 11),

        // ====================================================
        // ICON
        // ====================================================
        Icon(icon, size: 18, color: colors.primary),

        const SizedBox(width: 11),

        // ====================================================
        // TEXT
        // ====================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: TextStyle(
                  fontSize: 12.5,

                  fontWeight: FontWeight.w700,

                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,

                style: TextStyle(
                  fontSize: 10.5,

                  height: 1.35,

                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WORKFLOW CONNECTOR
// ============================================================

class _WorkflowConnector extends StatelessWidget {
  const _WorkflowConnector();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 15),

      child: Align(
        alignment: Alignment.centerLeft,

        child: Container(
          width: 1,

          height: 16,

          color: colors.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

// ============================================================
// REAL APPLICATION DATA
// ============================================================

class _DataInfoCard extends StatelessWidget {
  const _DataInfoCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: isDark ? 0.07 : 0.045),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(Icons.info_outline_rounded, size: 19, color: colors.primary),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Real application data',

                  style: TextStyle(
                    fontSize: 12.5,

                    fontWeight: FontWeight.w700,

                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Connections, agreements and contacts are loaded '
                  'from the backend after selecting a partner.',

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
