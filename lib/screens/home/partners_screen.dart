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

import '../../services/partner_location_service.dart';

import '../../theme/app_theme.dart';

import '../partner_connections_screen.dart';
import '../partner_agreements_screen.dart';
import '../partner_contacts_screen.dart';
import '../partner_map_screen.dart';

import '../../widgets/common/app_loading_view.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/app_empty_view.dart';

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

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
        titleSpacing: 8,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Partners',

              style: TextStyle(
                fontSize: 20,

                fontWeight: FontWeight.w800,

                letterSpacing: -0.4,

                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Company directory',

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
              color: colors.surfaceContainer,

              borderRadius: BorderRadius.circular(14),

              child: InkWell(
                borderRadius: BorderRadius.circular(14),

                onTap: () {
                  context.read<PartnersBloc>().add(const PartnersRequested());
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
      body: BlocBuilder<PartnersBloc, PartnersState>(
        builder: (context, state) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (state.isLoading) {
            return const AppLoadingView(
              title: 'Loading partners',

              message: 'Retrieving partner records...',
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (state.errorMessage != null) {
            return AppErrorView(
              title: 'Unable to load partners',

              message: state.errorMessage!,

              onRetry: () {
                context.read<PartnersBloc>().add(const PartnersRequested());
              },
            );
          }

          // ----------------------------------------------------
          // BACKEND RETURNED NOTHING
          // ----------------------------------------------------

          if (state.allPartners.isEmpty) {
            return const AppEmptyView(
              icon: Icons.business_outlined,

              title: 'No partners found',

              message: 'There are currently no partner records available.',
            );
          }

          // ----------------------------------------------------
          // SUCCESS
          // ----------------------------------------------------

          return Column(
            children: [
              // ==================================================
              // TOP CONTENT
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),

                child: Column(
                  children: [
                    // ============================================
                    // DIRECTORY SUMMARY
                    // ============================================

                    _DirectorySummary(partnerCount: state.allPartners.length),

                    const SizedBox(height: 14),

                    // ============================================
                    // SEARCH
                    // ============================================
                    TextFormField(
                      initialValue: state.searchQuery,

                      style: TextStyle(
                        color: colors.onSurface,

                        fontSize: 14,

                        fontWeight: FontWeight.w500,
                      ),

                      cursorColor: colors.primary,

                      onChanged: (value) {
                        context.read<PartnersBloc>().add(
                          PartnersSearchChanged(value),
                        );
                      },

                      decoration: InputDecoration(
                        hintText: 'Search partners...',

                        prefixIcon: const Icon(Icons.search_rounded),

                        suffixIcon: state.searchQuery.isNotEmpty
                            ? const Icon(Icons.manage_search_rounded, size: 20)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ============================================
                    // FILTERS
                    // ============================================
                    Row(
                      children: [
                        Expanded(
                          child: _FilterDropdown<String>(
                            icon: Icons.location_city_outlined,

                            value: state.selectedCity,

                            items: [
                              const DropdownMenuItem(
                                value: 'All',

                                child: Text(
                                  'All cities',

                                  overflow: TextOverflow.ellipsis,
                                ),
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

                        const SizedBox(width: 10),

                        Expanded(
                          child: _FilterDropdown<PartnerSortOption>(
                            icon: Icons.sort_rounded,

                            value: state.sortOption,

                            items: PartnerSortOption.values
                                .map(
                                  (option) =>
                                      DropdownMenuItem<PartnerSortOption>(
                                        value: option,

                                        child: Text(
                                          _sortLabel(option),

                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                )
                                .toList(),

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
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ============================================
                    // RESULTS
                    // ============================================
                    _ResultsBar(
                      visible: state.partners.length,

                      total: state.allPartners.length,

                      filtered:
                          state.searchQuery.isNotEmpty ||
                          state.selectedCity != 'All',
                    ),
                  ],
                ),
              ),

              // ==================================================
              // NO FILTER RESULTS
              // ==================================================
              if (state.partners.isEmpty)
                const Expanded(child: _NoResultsView())
              // ==================================================
              // PARTNER LIST
              // ==================================================
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<PartnersBloc>().add(
                        const PartnersRequested(),
                      );
                    },

                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),

                      itemCount: state.partners.length,

                      separatorBuilder: (_, __) => const SizedBox(height: 12),

                      itemBuilder: (context, index) {
                        final partner = state.partners[index];

                        return _PartnerCard(
                          initial: _getPartnerInitial(partner.naziv),

                          name: partner.naziv ?? 'Unnamed partner',

                          city: partner.mestoNaziv,

                          address: partner.adresa,

                          type: partner.tipPartner,

                          id: partner.id,

                          // ======================================
                          // LOCATION
                          // ======================================
                          onLocation: () {
                            _openPartnerLocation(
                              context,

                              partnerName: partner.naziv ?? 'Unnamed partner',

                              address: partner.adresa,

                              city: partner.mestoNaziv,
                            );
                          },

                          // ======================================
                          // CONNECTIONS
                          // ======================================
                          onConnections: () {
                            _openConnections(
                              context,

                              partner.tipPartner,

                              partner.id,

                              partner.naziv,
                            );
                          },

                          // ======================================
                          // AGREEMENTS
                          // ======================================
                          onAgreements: () {
                            _openAgreements(
                              context,

                              partner.tipPartner,

                              partner.id,

                              partner.naziv,
                            );
                          },

                          // ======================================
                          // CONTACTS
                          // ======================================
                          onContacts: () {
                            _openContacts(
                              context,

                              partner.tipPartner,

                              partner.id,

                              partner.naziv,
                            );
                          },
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
  // SORT LABEL
  // ==========================================================

  static String _sortLabel(PartnerSortOption option) {
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

  // ==========================================================
  // PARTNER LOCATION
  // ==========================================================

  Future<void> _openPartnerLocation(
    BuildContext context, {
    required String partnerName,
    String? address,
    String? city,
  }) async {
    final cleanAddress = address?.trim();

    final cleanCity = city?.trim();

    final hasAddress = cleanAddress != null && cleanAddress.isNotEmpty;

    final hasCity = cleanCity != null && cleanCity.isNotEmpty;

    // ----------------------------------------------------------
    // NO LOCATION INFORMATION
    // ----------------------------------------------------------

    if (!hasAddress && !hasCity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location information is not available for this partner.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // SHOW LOADING DIALOG
    // ----------------------------------------------------------

    showDialog<void>(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return PopScope(
          canPop: false,

          child: AlertDialog(
            content: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,

                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,

                    color: colors.primary,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Text(
                    'Finding business location...',

                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // --------------------------------------------------------
      // BACKEND ADDRESS -> COORDINATES
      // --------------------------------------------------------

      final locationService = PartnerLocationService();

      final coordinates = await locationService.resolvePartnerLocation(
        partnerName: partnerName,

        address: address,

        city: city,
      );

      if (!context.mounted) {
        return;
      }

      // --------------------------------------------------------
      // CLOSE LOADING DIALOG
      // --------------------------------------------------------

      Navigator.of(context, rootNavigator: true).pop();

      // --------------------------------------------------------
      // OPEN IN-APP MAP
      // --------------------------------------------------------

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PartnerMapScreen(
            partnerName: partnerName,

            address: address,

            city: city,

            latitude: coordinates.latitude,

            longitude: coordinates.longitude,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      // --------------------------------------------------------
      // CLOSE LOADING DIALOG
      // --------------------------------------------------------

      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not find a map location for $partnerName.'),
        ),
      );
    }
  }

  // ==========================================================
  // CONNECTIONS
  // ==========================================================

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

  // ==========================================================
  // AGREEMENTS
  // ==========================================================

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

  // ==========================================================
  // CONTACTS
  // ==========================================================

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

  // ==========================================================
  // HELPERS
  // ==========================================================

  static String _getPartnerInitial(String? name) {
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

// ============================================================
// DIRECTORY SUMMARY
// ============================================================

class _DirectorySummary extends StatelessWidget {
  final int partnerCount;

  const _DirectorySummary({required this.partnerCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [AppColors.primary, AppColors.primaryDark],
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),

            blurRadius: 22,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),

              borderRadius: BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.business_rounded,

              color: Colors.white,

              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Partner Directory',

                  style: TextStyle(
                    fontSize: 17,

                    fontWeight: FontWeight.w800,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$partnerCount partners available',

                  style: TextStyle(
                    fontSize: 12,

                    fontWeight: FontWeight.w500,

                    color: Colors.white.withValues(alpha: 0.76),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),

              borderRadius: BorderRadius.circular(18),
            ),

            child: const Row(
              children: [
                Icon(Icons.circle, color: Color(0xFF86EFAC), size: 7),

                SizedBox(width: 5),

                Text(
                  'Live',

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
    );
  }
}

// ============================================================
// FILTER DROPDOWN
// ============================================================

class _FilterDropdown<T> extends StatelessWidget {
  final IconData icon;

  final T value;

  final List<DropdownMenuItem<T>> items;

  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 54,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          if (isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),

              blurRadius: 10,

              offset: const Offset(0, 3),
            ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.16 : 0.07),

              borderRadius: BorderRadius.circular(9),
            ),

            child: Icon(icon, size: 17, color: colors.primary),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,

                isExpanded: true,

                borderRadius: BorderRadius.circular(16),

                dropdownColor: isDark
                    ? colors.surfaceContainerHigh
                    : colors.surface,

                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,

                  size: 20,

                  color: colors.onSurfaceVariant,
                ),

                style: TextStyle(
                  fontSize: 12,

                  fontWeight: FontWeight.w600,

                  color: colors.onSurface,
                ),

                items: items,

                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RESULTS BAR
// ============================================================

class _ResultsBar extends StatelessWidget {
  final int visible;

  final int total;

  final bool filtered;

  const _ResultsBar({
    required this.visible,
    required this.total,
    required this.filtered,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,

          decoration: BoxDecoration(
            color: colors.primary,

            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            filtered ? '$visible of $total partners' : '$total partners',

            style: TextStyle(
              fontSize: 12,

              fontWeight: FontWeight.w600,

              color: colors.onSurfaceVariant,
            ),
          ),
        ),

        if (filtered)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.17 : 0.08),

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.06),
              ),
            ),

            child: Text(
              'Filtered',

              style: TextStyle(
                fontSize: 10,

                fontWeight: FontWeight.w700,

                color: colors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// PARTNER CARD
// ============================================================

class _PartnerCard extends StatelessWidget {
  final String initial;

  final String name;

  final String? city;

  final String? address;

  final int? type;

  final int? id;

  final VoidCallback onLocation;

  final VoidCallback onConnections;

  final VoidCallback onAgreements;

  final VoidCallback onContacts;

  const _PartnerCard({
    required this.initial,
    required this.name,
    required this.city,
    required this.address,
    required this.type,
    required this.id,
    required this.onLocation,
    required this.onConnections,
    required this.onAgreements,
    required this.onContacts,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        // Lighter than the page
        // in dark mode.
        color: isDark ? colors.surfaceContainerHigh : colors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.90)
              : colors.outlineVariant,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.025),

            blurRadius: isDark ? 18 : 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ================================================
              // PARTNER INITIAL TILE
              // ================================================

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,

                    colors: [
                      colors.primary.withValues(alpha: isDark ? 0.24 : 0.14),

                      colors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(
                    color: colors.primary.withValues(
                      alpha: isDark ? 0.24 : 0.08,
                    ),
                  ),
                ),

                child: Center(
                  child: Text(
                    initial,

                    style: TextStyle(
                      fontSize: 20,

                      fontWeight: FontWeight.w800,

                      color: colors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 15,

                        height: 1.25,

                        fontWeight: FontWeight.w700,

                        color: colors.onSurface,
                      ),
                    ),

                    // ============================================
                    // CITY
                    // ============================================
                    if (_hasText(city)) ...[
                      const SizedBox(height: 7),

                      _InfoRow(
                        icon: Icons.location_city_outlined,

                        value: city!,

                        // If there is no address,
                        // put the map button
                        // beside the city.
                        onAction: !_hasText(address) ? onLocation : null,

                        actionIcon: Icons.map_outlined,
                      ),
                    ],

                    // ============================================
                    // ADDRESS
                    // ============================================
                    if (_hasText(address)) ...[
                      const SizedBox(height: 4),

                      _InfoRow(
                        icon: Icons.location_on_outlined,

                        value: address!,

                        // Main location button.
                        onAction: onLocation,

                        actionIcon: Icons.map_outlined,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ====================================================
          // TAGS
          // ====================================================
          if (type != null || id != null) ...[
            const SizedBox(height: 14),

            Wrap(
              spacing: 7,

              runSpacing: 7,

              children: [
                if (type != null)
                  _PartnerInfoChip(
                    icon: Icons.category_outlined,

                    label: 'Type $type',
                  ),

                if (id != null)
                  _PartnerInfoChip(icon: Icons.tag_rounded, label: 'ID $id'),
              ],
            ),
          ],

          const SizedBox(height: 15),

          Divider(color: colors.outlineVariant),

          const SizedBox(height: 12),

          // ====================================================
          // ACTIONS
          // ====================================================
          Row(
            children: [
              Expanded(
                child: _PartnerActionButton(
                  icon: Icons.lan_outlined,

                  label: 'Connections',

                  onTap: onConnections,
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _PartnerActionButton(
                  icon: Icons.description_outlined,

                  label: 'Agreements',

                  onTap: onAgreements,
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _PartnerActionButton(
                  icon: Icons.people_outline_rounded,

                  label: 'Contacts',

                  onTap: onContacts,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

// ============================================================
// PARTNER INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;

  final String value;

  final VoidCallback? onAction;

  final IconData? actionIcon;

  const _InfoRow({
    required this.icon,
    required this.value,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 15, color: colors.onSurfaceVariant),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ),

        // ======================================================
        // MAP BUTTON
        // ======================================================
        if (onAction != null) ...[
          const SizedBox(width: 8),

          Material(
            color: colors.primary.withValues(alpha: isDark ? 0.17 : 0.08),

            borderRadius: BorderRadius.circular(10),

            child: InkWell(
              onTap: onAction,

              borderRadius: BorderRadius.circular(10),

              child: Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),

                  border: Border.all(
                    color: colors.primary.withValues(
                      alpha: isDark ? 0.22 : 0.06,
                    ),
                  ),
                ),

                child: Icon(
                  actionIcon ?? Icons.map_outlined,

                  size: 17,

                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// PARTNER INFO CHIP
// ============================================================

class _PartnerInfoChip extends StatelessWidget {
  final IconData icon;

  final String label;

  const _PartnerInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

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
          Icon(icon, size: 13, color: colors.onSurfaceVariant),

          const SizedBox(width: 5),

          Text(
            label,

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
// PARTNER ACTION BUTTON
// ============================================================

class _PartnerActionButton extends StatelessWidget {
  final IconData icon;

  final String label;

  final VoidCallback onTap;

  const _PartnerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.06),

      borderRadius: BorderRadius.circular(13),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(13),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),

            border: Border.all(
              color: colors.primary.withValues(alpha: isDark ? 0.19 : 0.04),
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),

            child: Column(
              children: [
                Icon(icon, size: 18, color: colors.primary),

                const SizedBox(height: 5),

                FittedBox(
                  fit: BoxFit.scaleDown,

                  child: Text(
                    label,

                    style: TextStyle(
                      fontSize: 10,

                      fontWeight: FontWeight.w700,

                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NO SEARCH RESULTS
// ============================================================

class _NoResultsView extends StatelessWidget {
  const _NoResultsView();

  @override
  Widget build(BuildContext context) {
    return const _CenteredStateView(
      icon: Icons.search_off_rounded,

      title: 'No matching partners',

      message: 'Try another search term or change the city filter.',
    );
  }
}

// ============================================================
// GENERIC CENTERED STATE
// ============================================================

class _CenteredStateView extends StatelessWidget {
  final IconData icon;

  final String title;

  final String message;

  const _CenteredStateView({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 72,
              height: 72,

              decoration: BoxDecoration(
                color: isDark
                    ? colors.surfaceContainerHighest
                    : colors.surfaceContainerHighest.withValues(alpha: 0.60),

                borderRadius: BorderRadius.circular(22),

                border: Border.all(color: colors.outlineVariant),
              ),

              child: Icon(icon, size: 32, color: colors.primary),
            ),

            const SizedBox(height: 18),

            Text(
              title,

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 17,

                fontWeight: FontWeight.w700,

                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              message,

              textAlign: TextAlign.center,

              style: TextStyle(
                height: 1.4,

                fontSize: 12,

                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
