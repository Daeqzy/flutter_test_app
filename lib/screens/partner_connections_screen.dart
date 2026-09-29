import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/partner_connections/partner_connections_bloc.dart';
import '../bloc/partner_connections/partner_connections_event.dart';
import '../bloc/partner_connections/partner_connections_state.dart';

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
      appBar: AppBar(title: Text(partnerName)),

      body: BlocBuilder<PartnerConnectionsBloc, PartnerConnectionsState>(
        builder: (context, state) {
          // ------------------------------------------------
          // LOADING
          // ------------------------------------------------

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ------------------------------------------------
          // ERROR
          // ------------------------------------------------

          if (state.errorMessage != null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () {
                context.read<PartnerConnectionsBloc>().add(
                  PartnerConnectionsRequested(tp: tp, p: p),
                );
              },
            );
          }

          // ------------------------------------------------
          // EMPTY
          // ------------------------------------------------

          if (state.connections.isEmpty) {
            return _EmptyView(partnerName: partnerName);
          }

          // ------------------------------------------------
          // SUCCESS
          // ------------------------------------------------

          return Column(
            children: [
              // --------------------------------------------
              // HEADER
              // --------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Connections',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${state.connections.length} '
                      'connection${state.connections.length == 1 ? '' : 's'} found',

                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Tap a connection to view details',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------
              // CONNECTION LIST
              // --------------------------------------------
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PartnerConnectionsBloc>().add(
                      PartnerConnectionsRequested(tp: tp, p: p),
                    );
                  },

                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),

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

                      return Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,

                        child: ExpansionTile(
                          // Keeps expansion state
                          // while scrolling.
                          key: PageStorageKey(
                            'connection_'
                            '${connection.id ?? index}_'
                            '$index',
                          ),

                          maintainState: true,

                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),

                          // ----------------------------
                          // CONNECTION ICON
                          // ----------------------------
                          leading: Container(
                            width: 46,
                            height: 46,

                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Icon(
                              _getConnectionIcon(connection.naziv),

                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),

                          // ----------------------------
                          // CONNECTION NAME
                          // ----------------------------
                          title: Text(
                            connection.naziv ?? 'Unnamed connection',

                            maxLines: 2,

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // ----------------------------
                          // ID + STATUS
                          // ----------------------------
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),

                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,

                              children: [
                                if (connection.id != null)
                                  Text(
                                    'Connection #${connection.id}',

                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

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

                          // ----------------------------
                          // EXPANDED CONTENT
                          // ----------------------------
                          children: [
                            if (hasDetails) ...[
                              const Divider(),

                              const SizedBox(height: 8),

                              if (_hasText(connection.adresa))
                                _ConnectionInfoRow(
                                  icon: Icons.location_on_outlined,

                                  label: 'Address',

                                  value: connection.adresa!,
                                ),

                              if (_hasText(connection.publicIp))
                                _ConnectionInfoRow(
                                  icon: Icons.public,

                                  label: 'Public IP',

                                  value: connection.publicIp!,
                                ),

                              if (_hasText(connection.ddnsName))
                                _ConnectionInfoRow(
                                  icon: Icons.language,

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
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                ),

                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 18,
                                      color: Colors.grey.shade500,
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      'No additional details available.',

                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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

  // ----------------------------------------------------------
  // HAS TEXT
  // ----------------------------------------------------------

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // ----------------------------------------------------------
  // HAS CONNECTION DETAILS
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // CONNECTION ICON
  // ----------------------------------------------------------

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

// ----------------------------------------------------------
// STATUS BADGE
// ----------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final String text;

  const _StatusBadge({required this.isActive, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel_outlined,

            size: 14,
            color: color,
          ),

          const SizedBox(width: 4),

          Text(
            text.trim(),

            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// CONNECTION INFORMATION ROW
// ----------------------------------------------------------

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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, size: 19, color: Colors.grey.shade600),

          const SizedBox(width: 12),

          SizedBox(
            width: 75,

            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value.trim(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// EMPTY VIEW
// ----------------------------------------------------------

class _EmptyView extends StatelessWidget {
  final String partnerName;

  const _EmptyView({required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.link_off_rounded,

                size: 38,

                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No connections found',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '$partnerName currently has no connection records.',

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// ERROR VIEW
// ----------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.error_outline_rounded,

                size: 40,

                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Unable to load connections',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              message,

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh),

              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
