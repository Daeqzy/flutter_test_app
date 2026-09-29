import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/partners/partners_bloc.dart';
import '../../bloc/partners/partners_event.dart';
import '../../bloc/partners/partners_state.dart';

import '../../bloc/partner_connections/partner_connections_bloc.dart';
import '../../bloc/partner_connections/partner_connections_event.dart';

import '../../bloc/partner_agreements/partner_agreements_bloc.dart';
import '../../bloc/partner_agreements/partner_agreements_event.dart';

import '../../bloc/partner_contacts/partner_contacts_bloc.dart';
import '../../bloc/partner_contacts/partner_contacts_event.dart';

import '../../repositories/data_repository.dart';

import '../partner_connections_screen.dart';
import '../partner_agreements_screen.dart';
import '../partner_contacts_screen.dart';

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partners'),

        actions: [
          IconButton(
            tooltip: 'Refresh partners',

            onPressed: () {
              context.read<PartnersBloc>().add(const PartnersRequested());
            },

            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: BlocBuilder<PartnersBloc, PartnersState>(
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
            return _PartnersErrorView(
              message: state.errorMessage!,

              onRetry: () {
                context.read<PartnersBloc>().add(const PartnersRequested());
              },
            );
          }

          // ------------------------------------------------
          // BACKEND RETURNED NO PARTNERS
          // ------------------------------------------------

          if (state.allPartners.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.business_outlined, size: 60, color: Colors.grey),

                  SizedBox(height: 16),

                  Text(
                    'No partners found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          // ------------------------------------------------
          // SUCCESS
          // ------------------------------------------------

          return Column(
            children: [
              // ============================================
              // SEARCH
              // ============================================

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

                child: TextFormField(
                  initialValue: state.searchQuery,

                  onChanged: (value) {
                    context.read<PartnersBloc>().add(
                      PartnersSearchChanged(value),
                    );
                  },

                  decoration: InputDecoration(
                    hintText: 'Search partner by name...',

                    prefixIcon: const Icon(Icons.search_rounded),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),

                    filled: true,

                    fillColor: Colors.white,
                  ),
                ),
              ),

              // ============================================
              // CITY + SORT
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),

                child: Row(
                  children: [
                    // --------------------------------------
                    // CITY
                    // --------------------------------------

                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'City',

                          prefixIcon: const Icon(Icons.location_city_outlined),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.selectedCity,

                            isExpanded: true,

                            items: [
                              const DropdownMenuItem(
                                value: 'All',
                                child: Text('All cities'),
                              ),

                              ...state.cities.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city,

                                  child: Text(
                                    city,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],

                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              context.read<PartnersBloc>().add(
                                PartnersCityChanged(value),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // --------------------------------------
                    // SORT
                    // --------------------------------------
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Sort',

                          prefixIcon: const Icon(Icons.sort_rounded),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PartnerSortOption>(
                            value: state.sortOption,

                            isExpanded: true,

                            items: PartnerSortOption.values.map((option) {
                              return DropdownMenuItem<PartnerSortOption>(
                                value: option,

                                child: Text(
                                  _sortLabel(option),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              context.read<PartnersBloc>().add(
                                PartnersSortChanged(value),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // RESULT COUNT
              // ============================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),

                child: Row(
                  children: [
                    Text(
                      '${state.partners.length} of '
                      '${state.allPartners.length} partners',

                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // NO SEARCH RESULTS
              // ============================================
              if (state.partners.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 54,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No matching partners',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Try changing the search or city filter.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              // ============================================
              // LAZY PARTNER LIST
              // ============================================
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),

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
                              // ----------------------------
                              // HEADER
                              // ----------------------------

                              Row(
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

                                                  overflow:
                                                      TextOverflow.ellipsis,

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

                                                  overflow:
                                                      TextOverflow.ellipsis,

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

                              // ----------------------------
                              // TYPE / ID
                              // ----------------------------
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

                              // ----------------------------
                              // CONNECTIONS / AGREEMENTS
                              // ----------------------------
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _openConnections(
                                          context,
                                          partner.tipPartner,
                                          partner.id,
                                          partner.naziv,
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

                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {
                                        _openAgreements(
                                          context,
                                          partner.tipPartner,
                                          partner.id,
                                          partner.naziv,
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

                              const SizedBox(height: 10),

                              // ----------------------------
                              // CONTACTS
                              // ----------------------------
                              SizedBox(
                                width: double.infinity,

                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _openContacts(
                                      context,
                                      partner.tipPartner,
                                      partner.id,
                                      partner.naziv,
                                    );
                                  },

                                  icon: const Icon(
                                    Icons.people_outline_rounded,
                                    size: 18,
                                  ),

                                  label: const Text('Contacts'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // SORT LABEL
  // ----------------------------------------------------------

  String _sortLabel(PartnerSortOption option) {
    switch (option) {
      case PartnerSortOption.nameAZ:
        return 'Name A-Z';

      case PartnerSortOption.nameZA:
        return 'Name Z-A';

      case PartnerSortOption.cityAZ:
        return 'City A-Z';

      case PartnerSortOption.cityZA:
        return 'City Z-A';

      case PartnerSortOption.idAscending:
        return 'ID Low-High';

      case PartnerSortOption.idDescending:
        return 'ID High-Low';
    }
  }

  // ----------------------------------------------------------
  // CONNECTIONS
  // ----------------------------------------------------------

  void _openConnections(
    BuildContext context,
    int? tp,
    int? p,
    String? partnerName,
  ) {
    if (tp == null || p == null || p < 1) {
      _showUnavailableMessage(context, 'Connections');

      return;
    }

    final repository = context.read<DataRepository>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              PartnerConnectionsBloc(repository)
                ..add(PartnerConnectionsRequested(tp: tp, p: p)),

          child: PartnerConnectionsScreen(
            tp: tp,
            p: p,
            partnerName: partnerName ?? 'Partner',
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // AGREEMENTS
  // ----------------------------------------------------------

  void _openAgreements(
    BuildContext context,
    int? tp,
    int? p,
    String? partnerName,
  ) {
    if (tp == null || p == null || p < 1) {
      _showUnavailableMessage(context, 'Agreements');

      return;
    }

    final repository = context.read<DataRepository>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              PartnerAgreementsBloc(repository)
                ..add(PartnerAgreementsRequested(tp: tp, p: p)),

          child: PartnerAgreementsScreen(
            tp: tp,
            p: p,
            partnerName: partnerName ?? 'Partner',
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CONTACTS
  // ----------------------------------------------------------

  void _openContacts(
    BuildContext context,
    int? tp,
    int? p,
    String? partnerName,
  ) {
    if (tp == null || p == null || p < 1) {
      _showUnavailableMessage(context, 'Contacts');

      return;
    }

    final repository = context.read<DataRepository>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              PartnerContactsBloc(repository)
                ..add(PartnerContactsRequested(tp: tp, p: p)),

          child: PartnerContactsScreen(
            tp: tp,
            p: p,
            partnerName: partnerName ?? 'Partner',
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _getPartnerInitial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    return name.trim()[0].toUpperCase();
  }

  void _showUnavailableMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature are not available for this partner.')),
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
// ERROR VIEW
// ----------------------------------------------------------

class _PartnersErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PartnersErrorView({required this.message, required this.onRetry});

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
              'Unable to load partners',

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

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
