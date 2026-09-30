import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/notifications/notifications_bloc.dart';
import '../../bloc/notifications/notifications_event.dart';
import '../../bloc/notifications/notifications_state.dart';

import '../../widgets/common/app_loading_view.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/app_empty_view.dart';
import '../../widgets/common/app_section_header.dart';

import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
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

                const _NotificationsHero(),

                const SizedBox(height: 28),

                // ==================================================
                // SECTION HEADER
                // ==================================================
                const AppSectionHeader(
                  title: 'Activity center',
                  subtitle: 'Updates and alerts from your workspace',
                ),

                const SizedBox(height: 14),

                // ==================================================
                // LOADING
                // ==================================================
                if (state.isLoading)
                  const AppLoadingView(
                    title: 'Loading notifications',
                    message: 'Checking for recent workspace activity...',
                    boxed: true,
                  )
                else if (state.errorMessage != null)
                  AppErrorView(
                    title: 'Unable to load notifications',
                    message: state.errorMessage!,
                    boxed: true,
                    onRetry: () {
                      context.read<NotificationsBloc>().add(
                        const NotificationsRequested(),
                      );
                    },
                  )
                else
                  const AppEmptyView(
                    icon: Icons.notifications_none_rounded,
                    title: 'You’re all caught up',
                    message: 'New notifications and workspace updates will appear here when they become available.',
                    boxed: true,
                    badgeText: 'No new activity',
                    badgeIcon: Icons.check_circle_outline_rounded,
                    badgeColor: AppColors.success,
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

class _NotificationsHero extends StatelessWidget {
  const _NotificationsHero();

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
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 24,
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
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 14,
                          color: Colors.white,
                        ),

                        SizedBox(width: 5),

                        Text(
                          'Notifications',
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
                'Stay informed',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Important updates, alerts and workspace activity will appear here.',
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
