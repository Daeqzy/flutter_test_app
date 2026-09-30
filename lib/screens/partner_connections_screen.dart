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
    return Scaffold(
      backgroundColor: AppColors.background,

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
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 2),

            const Text(
              'Connections',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Material(
              color: AppColors.surface,
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
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 21,
                    color: AppColors.textPrimary,
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
                      '${state.connections.length} connection${state.connections.length == 1 ? '' : 's'} available',
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.025),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),

                          child: ExpansionTile(
                            // IMPORTANT:
                            // preserves expansion while scrolling
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
                                    AppColors.primary.withValues(alpha: 0.14),
                                    AppColors.primary.withValues(alpha: 0.06),
                                  ],
                                ),

                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: Icon(
                                _getConnectionIcon(connection.naziv),
                                color: AppColors.primary,
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

                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
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

                                  _StatusBadge(
                                    isActive: connection.aktivenBool == true,

                                    text:
                                        connection.aktivenString ??
                                        (connection.aktivenBool == true
                                            ? 'Active'
                                            : 'Inactive'),
                                  ),
                                ],
                              ),
                            ),

                            // ==================================
                            // EXPANDED DETAILS
                            // ==================================
                            children: [
                              const Divider(),

                              const SizedBox(height: 12),

                              if (hasDetails) ...[
                                if (_hasText(connection.adresa))
                                  _ConnectionInfoRow(
                                    icon: Icons.location_on_outlined,
                                    label: 'Address',
                                    value: connection.adresa!,
                                  ),

                                if (_hasText(connection.publicIp))
                                  _ConnectionInfoRow(
                                    icon: Icons.public_rounded,
                                    label: 'Public IP',
                                    value: connection.publicIp!,
                                  ),

                                if (_hasText(connection.ddnsName))
                                  _ConnectionInfoRow(
                                    icon: Icons.language_rounded,
                                    label: 'DDNS',
                                    value: connection.ddnsName!,
                                  ),

                                if (_hasText(connection.lanInfo))
                                  _ConnectionInfoRow(
                                    icon: Icons.lan_outlined,
                                    label: 'LAN',
                                    value: connection.lanInfo!,
                                  ),

                                if (_hasText(connection.osInfo))
                                  _ConnectionInfoRow(
                                    icon: Icons.desktop_windows_outlined,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Icon(
            Icons.tag_rounded,
            size: 12,
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: 4),

          Text(
            '$id',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final String text;

  const _StatusBadge({required this.isActive, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 6,
            height: 6,

            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 5),

          Text(
            text.trim(),

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONNECTION DETAIL ROW
// ============================================================

class _ConnectionInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _ConnectionInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),

        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),

          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 34,
              height: 34,

              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),

                borderRadius: BorderRadius.circular(10),
              ),

              child: Icon(icon, size: 17, color: AppColors.primary),
            ),

            const SizedBox(width: 11),

            SizedBox(
              width: 72,

              child: Padding(
                padding: const EdgeInsets.only(top: 2),

                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Text(
                value.trim(),

                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
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
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),

        borderRadius: BorderRadius.circular(14),
      ),

      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),

          SizedBox(width: 9),

          Expanded(
            child: Text(
              'No additional details available for this connection.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
