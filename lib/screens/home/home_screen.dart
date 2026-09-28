import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';

import '../../bloc/partners/partners_bloc.dart';
import '../../bloc/partners/partners_event.dart';
import '../../bloc/partners/partners_state.dart';

import '../../bloc/partner_connections/partner_connections_bloc.dart';
import '../../bloc/partner_connections/partner_connections_event.dart';

import '../../bloc/partner_agreements/partner_agreements_bloc.dart';
import '../../bloc/partner_agreements/partner_agreements_event.dart';

import '../../repositories/data_repository.dart';

import '../partner_connections_screen.dart';
import '../partner_agreements_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // WELCOME
            // ------------------------------------------------

            const Text(
              'Welcome',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'CODEX Computers',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            // ------------------------------------------------
            // QUICK ACTIONS
            // ------------------------------------------------
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.design_services_outlined,
                    title: 'Services',
                    onTap: () {
                      context.read<NavigationBloc>().add(
                        const NavigationTabChanged(1),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      context.read<NavigationBloc>().add(
                        const NavigationTabChanged(2),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.refresh_rounded,
                    title: 'Refresh',
                    onTap: () {
                      context.read<PartnersBloc>().add(
                        const PartnersRequested(),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      context.read<NavigationBloc>().add(
                        const NavigationTabChanged(3),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // PARTNERS HEADER
            // ------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Partners',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                IconButton(
                  tooltip: 'Refresh partners',
                  onPressed: () {
                    context.read<PartnersBloc>().add(const PartnersRequested());
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // PARTNERS
            // ------------------------------------------------
            BlocBuilder<PartnersBloc, PartnersState>(
              builder: (context, state) {
                // --------------------------------------------
                // LOADING
                // --------------------------------------------

                if (state.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // --------------------------------------------
                // ERROR
                // --------------------------------------------

                if (state.errorMessage != null) {
                  return _PartnersErrorView(
                    message: state.errorMessage!,
                    onRetry: () {
                      context.read<PartnersBloc>().add(
                        const PartnersRequested(),
                      );
                    },
                  );
                }

                // --------------------------------------------
                // EMPTY
                // --------------------------------------------

                if (state.partners.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 52,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No partners found.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // --------------------------------------------
                // SUCCESS
                // --------------------------------------------

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.partners.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final partner = state.partners[index];

                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --------------------------------
                            // PARTNER HEADER
                            // --------------------------------

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getPartnerInitial(partner.naziv),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        partner.naziv ?? 'Unnamed partner',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      if (_hasText(partner.mestoNaziv)) ...[
                                        const SizedBox(height: 6),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_city_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),

                                            const SizedBox(width: 5),

                                            Expanded(
                                              child: Text(
                                                partner.mestoNaziv!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      if (_hasText(partner.adresa)) ...[
                                        const SizedBox(height: 4),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),

                                            const SizedBox(width: 5),

                                            Expanded(
                                              child: Text(
                                                partner.adresa!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // --------------------------------
                            // TYPE / ID
                            // --------------------------------
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (partner.tipPartner != null)
                                  _PartnerInfoChip(
                                    label: 'Type ${partner.tipPartner}',
                                  ),

                                if (partner.id != null)
                                  _PartnerInfoChip(label: 'ID ${partner.id}'),
                              ],
                            ),

                            const SizedBox(height: 16),

                            const Divider(height: 1),

                            const SizedBox(height: 12),

                            // --------------------------------
                            // PARTNER ACTIONS
                            // --------------------------------
                            Row(
                              children: [
                                // ----------------------------
                                // CONNECTIONS
                                // ----------------------------

                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      final tp = partner.tipPartner;
                                      final p = partner.id;

                                      // p / ID cannot be 0.
                                      if (tp == null || p == null || p < 1) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Connections are not available for this partner.',
                                                ),
                                              ),
                                            );

                                        return;
                                      }

                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (_) =>
                                                PartnerConnectionsBloc(
                                                  context
                                                      .read<DataRepository>(),
                                                )..add(
                                                  PartnerConnectionsRequested(
                                                    tp: tp,
                                                    p: p,
                                                  ),
                                                ),
                                            child: PartnerConnectionsScreen(
                                              tp: tp,
                                              p: p,
                                              partnerName:
                                                  partner.naziv ?? 'Partner',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.lan_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Connections'),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // ----------------------------
                                // AGREEMENTS
                                // ----------------------------
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      final tp = partner.tipPartner;
                                      final p = partner.id;

                                      // Same backend rule:
                                      // partner ID / p must be > 0.
                                      if (tp == null || p == null || p < 1) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Agreements are not available for this partner.',
                                                ),
                                              ),
                                            );

                                        return;
                                      }

                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (_) =>
                                                PartnerAgreementsBloc(
                                                  context
                                                      .read<DataRepository>(),
                                                )..add(
                                                  PartnerAgreementsRequested(
                                                    tp: tp,
                                                    p: p,
                                                  ),
                                                ),
                                            child: PartnerAgreementsScreen(
                                              tp: tp,
                                              p: p,
                                              partnerName:
                                                  partner.naziv ?? 'Partner',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.description_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Agreements'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // RECENT ACTIVITY
            // ------------------------------------------------
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  title: const Text(
                    'No recent activity',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Your recent actions will appear here.'),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _getPartnerInitial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    return name.trim()[0].toUpperCase();
  }
}

// ----------------------------------------------------------
// QUICK ACTION CARD
// ----------------------------------------------------------

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// PARTNER INFO CHIP
// ----------------------------------------------------------

class _PartnerInfoChip extends StatelessWidget {
  final String label;

  const _PartnerInfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// PARTNERS ERROR VIEW
// ----------------------------------------------------------

class _PartnersErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PartnersErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Failed to load partners',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
