import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/partner_connections/partner_connections_bloc.dart';
import '../bloc/partner_connections/partner_connections_event.dart';
import '../bloc/partner_connections/partner_connections_state.dart';

import '../theme/app_theme.dart';

import '../widgets/common/app_loading_view.dart';
import '../widgets/common/app_error_view.dart';
import '../widgets/common/app_empty_view.dart';
import '../widgets/common/app_summary_card.dart';
import '../widgets/common/app_info_row.dart';
import '../widgets/common/app_status_badge.dart';

class PartnerConnectionsScreen extends StatelessWidget {
  final int tp;
  final int p;
  final String partnerName;

  const PartnerConnectionsScreen({
    super.key,
    required this.tp,
    required this.p,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 8,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              partnerName,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Connections',

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),

            child: Material(
              color: isDark ? colors.surfaceContainerHigh : colors.surface,

              borderRadius: BorderRadius.circular(14),

              child: InkWell(
                borderRadius: BorderRadius.circular(14),

                onTap: () {
                  context.read<PartnerConnectionsBloc>().add(
                    PartnerConnectionsRequested(tp: tp, p: p),
                  );
                },

                child: Container(
                  width: 44,
                  height: 44,

                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outlineVariant),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.refresh_rounded,
                    size: 21,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // CONTENT
      // ========================================================
      body: BlocBuilder<PartnerConnectionsBloc, PartnerConnectionsState>(
        builder: (context, state) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (state.isLoading) {
            return const AppLoadingView(
              title: 'Loading connections',
              message: 'Retrieving connection records...',
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (state.errorMessage != null) {
            return AppErrorView(
              title: 'Unable to load connections',

              message: state.errorMessage!,

              onRetry: () {
                context.read<PartnerConnectionsBloc>().add(
                  PartnerConnectionsRequested(tp: tp, p: p),
                );
              },
            );
          }

          // ----------------------------------------------------
          // EMPTY
          // ----------------------------------------------------

          if (state.connections.isEmpty) {
            return AppEmptyView(
              icon: Icons.hub_outlined,

              title: 'No connections found',

              message: '$partnerName currently has no connection records.',
            );
          }

          // ----------------------------------------------------
          // SUCCESS
          // ----------------------------------------------------

          return Column(
            children: [
              // ==================================================
              // SUMMARY
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),

                child: AppSummaryCard(
                  icon: Icons.hub_outlined,

                  title: 'Connection records',

                  subtitle:
                      '${state.connections.length} '
                      'connection${state.connections.length == 1 ? '' : 's'} '
                      'available',

                  detail: partnerName,

                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 13,
                          color: Colors.white,
                        ),

                        SizedBox(width: 5),

                        Text(
                          'Tap to expand',

                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // LIST
              // ==================================================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PartnerConnectionsBloc>().add(
                      PartnerConnectionsRequested(tp: tp, p: p),
                    );
                  },

                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),

                    itemCount: state.connections.length,

                    separatorBuilder: (_, __) => const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      final connection = state.connections[index];

                      final hasDetails = _hasConnectionDetails(
                        address: connection.adresa,
                        publicIp: connection.publicIp,
                        ddns: connection.ddnsName,
                        lan: connection.lanInfo,
                        os: connection.osInfo,
                      );

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? colors.surfaceContainerHigh
                              : colors.surface,

                          borderRadius: BorderRadius.circular(22),

                          border: Border.all(color: colors.outlineVariant),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.24 : 0.025,
                              ),

                              blurRadius: isDark ? 18 : 12,

                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),

                          child: ExpansionTile(
                            // IMPORTANT:
                            // Keep expansion state while scrolling.
                            key: PageStorageKey(
                              'connection_'
                              '${connection.id ?? index}_'
                              '$index',
                            ),

                            maintainState: true,

                            tilePadding: const EdgeInsets.fromLTRB(
                              15,
                              10,
                              14,
                              10,
                            ),

                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              17,
                            ),

                            iconColor: colors.onSurfaceVariant,

                            collapsedIconColor: colors.onSurfaceVariant,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),

                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),

                            // ==================================
                            // ICON
                            // ==================================
                            leading: Container(
                              width: 48,
                              height: 48,

                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,

                                  colors: [
                                    colors.primary.withValues(
                                      alpha: isDark ? 0.24 : 0.14,
                                    ),

                                    colors.primary.withValues(
                                      alpha: isDark ? 0.12 : 0.06,
                                    ),
                                  ],
                                ),

                                border: Border.all(
                                  color: colors.primary.withValues(
                                    alpha: isDark ? 0.24 : 0.08,
                                  ),
                                ),

                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: Icon(
                                _getConnectionIcon(connection.naziv),

                                color: colors.primary,

                                size: 22,
                              ),
                            ),

                            // ==================================
                            // NAME
                            // ==================================
                            title: Text(
                              connection.naziv ?? 'Unnamed connection',

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: 15,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),

                            // ==================================
                            // ID + STATUS
                            // ==================================
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 7),

                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,

                                crossAxisAlignment: WrapCrossAlignment.center,

                                children: [
                                  if (connection.id != null)
                                    _IdBadge(id: connection.id!),

                                  AppStatusBadge(
                                    text:
                                        connection.aktivenString
                                                ?.trim()
                                                .isNotEmpty ==
                                            true
                                        ? connection.aktivenString!
                                        : connection.aktivenBool == true
                                        ? 'Active'
                                        : 'Inactive',

                                    color: connection.aktivenBool == true
                                        ? AppColors.success
                                        : colors.onSurfaceVariant,

                                    showDot: true,
                                  ),
                                ],
                              ),
                            ),

                            // ==================================
                            // EXPANDED DETAILS
                            // ==================================
                            children: [
                              Divider(color: colors.outlineVariant),

                              const SizedBox(height: 12),

                              if (hasDetails) ...[
                                if (_hasText(connection.adresa))
                                  AppInfoRow(
                                    icon: Icons.location_on_outlined,
                                    label: 'Address',
                                    value: connection.adresa!,
                                  ),

                                if (_hasText(connection.publicIp))
                                  AppInfoRow(
                                    icon: Icons.public_rounded,
                                    label: 'Public IP',
                                    value: connection.publicIp!,
                                  ),

                                if (_hasText(connection.ddnsName))
                                  AppInfoRow(
                                    icon: Icons.language_rounded,
                                    label: 'DDNS',
                                    value: connection.ddnsName!,
                                  ),

                                if (_hasText(connection.lanInfo))
                                  AppInfoRow(
                                    icon: Icons.lan_outlined,
                                    label: 'LAN',
                                    value: connection.lanInfo!,
                                  ),

                                if (_hasText(connection.osInfo))
                                  AppInfoRow(
                                    icon: Icons.computer_outlined,
                                    label: 'OS',
                                    value: connection.osInfo!,
                                    isLast: true,
                                  ),
                              ] else
                                const _NoDetailsView(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // HAS TEXT
  // ==========================================================

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // ==========================================================
  // HAS DETAILS
  // ==========================================================

  bool _hasConnectionDetails({
    required String? address,
    required String? publicIp,
    required String? ddns,
    required String? lan,
    required String? os,
  }) {
    return _hasText(address) ||
        _hasText(publicIp) ||
        _hasText(ddns) ||
        _hasText(lan) ||
        _hasText(os);
  }

  // ==========================================================
  // CONNECTION ICON
  // ==========================================================

  IconData _getConnectionIcon(String? name) {
    final value = name?.toLowerCase() ?? '';

    if (value.contains('rdp')) {
      return Icons.desktop_windows_rounded;
    }

    if (value.contains('anydesk')) {
      return Icons.screen_share_rounded;
    }

    if (value.contains('router') || value.contains('firewall')) {
      return Icons.router_outlined;
    }

    return Icons.computer_rounded;
  }
}

// ============================================================
// ID BADGE
// ============================================================

class _IdBadge extends StatelessWidget {
  final int id;

  const _IdBadge({required this.id});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHighest
            : colors.surfaceContainerHighest.withValues(alpha: 0.55),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.80 : 0.45),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(Icons.tag_rounded, size: 12, color: colors.onSurfaceVariant),

          const SizedBox(width: 4),

          Text(
            '$id',

            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NO DETAILS
// ============================================================

class _NoDetailsView extends StatelessWidget {
  const _NoDetailsView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: colors.outlineVariant),
      ),

      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'No additional details available for this connection.',

              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
