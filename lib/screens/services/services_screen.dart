import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/services/services_bloc.dart';
import '../../bloc/services/services_event.dart';
import '../../bloc/services/services_state.dart';
import '../../widgets/common/app_loading_view.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/app_empty_view.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/app_section_header.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HERO
                // ==================================================

                const _ServicesHero(),

                const SizedBox(height: 28),

                // ==================================================
                // SEARCH SECTION
                // ==================================================
                const AppSectionHeader(
                  title: 'Service catalog',
                  subtitle: 'Find services available in your workspace',
                ),

                const SizedBox(height: 14),

                TextField(
                  onChanged: (value) {
                    context.read<ServicesBloc>().add(
                      ServicesSearchChanged(value),
                    );
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // AVAILABLE SERVICES
                // ==================================================
                const AppSectionHeader(
                  title: 'Available services',
                  subtitle: 'Your CODEX tools will appear below',
                ),

                const SizedBox(height: 14),

                // ==================================================
                // LOADING
                // ==================================================
                if (state.isLoading)
                  const AppLoadingView(
                    title: 'Loading services',
                    message: 'Checking for available workspace services...',
                    boxed: true,
                  )
                else if (state.errorMessage != null)
                  AppErrorView(
                    title: 'Unable to load services',
                    message: state.errorMessage!,
                    boxed: true,
                    onRetry: () {
                      context.read<ServicesBloc>().add(
                        const ServicesRequested(),
                      );
                    },
                  )
                else
                  const AppEmptyView(
                    icon: Icons.widgets_outlined,
                    title: 'No services available yet',
                    message: 'Services provided by the application will appear here when they become available.',
                    boxed: true,
                    badgeText: 'Nothing to display',
                    badgeIcon: Icons.info_outline_rounded,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _ServicesHero extends StatelessWidget {
  const _ServicesHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
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
            right: 35,
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
                    ),

                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.apps_rounded, color: Colors.white, size: 14),

                        SizedBox(width: 5),

                        Text(
                          'Services',
                          style: TextStyle(
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
                'CODEX Services',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Access tools and services available in your workspace.',
                style: TextStyle(
                  height: 1.4,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
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
