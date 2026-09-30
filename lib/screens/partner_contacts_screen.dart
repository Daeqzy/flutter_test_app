import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/partner_contacts/partner_contacts_bloc.dart';
import '../bloc/partner_contacts/partner_contacts_event.dart';
import '../bloc/partner_contacts/partner_contacts_state.dart';

import '../widgets/common/app_summary_card.dart';
import '../widgets/common/app_loading_view.dart';
import '../widgets/common/app_error_view.dart';
import '../widgets/common/app_empty_view.dart';

import '../theme/app_theme.dart';

class PartnerContactsScreen extends StatelessWidget {
  final int tp;
  final int p;
  final String partnerName;

  const PartnerContactsScreen({
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
              'Contacts',
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
                  context.read<PartnerContactsBloc>().add(
                    PartnerContactsRequested(tp: tp, p: p),
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
      body: BlocBuilder<PartnerContactsBloc, PartnerContactsState>(
        builder: (context, state) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (state.isLoading) {
            return const AppLoadingView(
              title: 'Loading contacts',
              message: 'Retrieving contact records...',
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (state.errorMessage != null) {
            return AppErrorView(
              title: 'Unable to load contacts',
              message: state.errorMessage!,
              onRetry: () {
                context.read<PartnerContactsBloc>().add(
                  PartnerContactsRequested(tp: tp, p: p),
                );
              },
            );
          }

          // ----------------------------------------------------
          // EMPTY
          // ----------------------------------------------------

          if (state.contacts.isEmpty) {
            return AppEmptyView(
              icon: Icons.people_outline_rounded,
              title: 'No contacts found',
              message: '$partnerName currently has no contact records.',
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
                  icon: Icons.people_alt_outlined,
                  title: 'Contact directory',
                  subtitle:
                      '${state.contacts.length} contact${state.contacts.length == 1 ? '' : 's'} available',
                  detail: partnerName,
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.contact_phone_outlined,
                      size: 19,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // ==================================================
              // CONTACT LIST
              // ==================================================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PartnerContactsBloc>().add(
                      PartnerContactsRequested(tp: tp, p: p),
                    );
                  },

                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),

                    itemCount: state.contacts.length,

                    separatorBuilder: (_, __) => const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      final contact = state.contacts[index];

                      return Container(
                        padding: const EdgeInsets.all(16),

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

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==================================
                            // CONTACT HEADER
                            // ==================================

                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,

                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withValues(
                                          alpha: 0.14,
                                        ),
                                        AppColors.primary.withValues(
                                          alpha: 0.06,
                                        ),
                                      ],
                                    ),

                                    borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: Center(
                                    child: Text(
                                      _getInitial(contact.naziv),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contact.naziv ?? 'Unnamed contact',

                                        maxLines: 2,

                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.25,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),

                                      if (contact.id != null) ...[
                                        const SizedBox(height: 6),

                                        _ContactIdBadge(id: contact.id!),
                                      ],
                                    ],
                                  ),
                                ),

                                Container(
                                  width: 38,
                                  height: 38,

                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7FB),

                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            // ==================================
                            // DETAILS
                            // ==================================
                            if (_hasAnyDetails(
                              tel: contact.tel,
                              mobilen: contact.mobilen,
                              mail: contact.mail,
                              opis: contact.opis,
                            )) ...[
                              const SizedBox(height: 16),

                              const Divider(),

                              const SizedBox(height: 12),
                            ],

                            // ==================================
                            // PHONE
                            // ==================================
                            if (_hasText(contact.tel))
                              _ContactInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: contact.tel!,
                                actionIcon: Icons.call_rounded,
                                onTap: () {
                                  _openPhone(context, contact.tel!);
                                },
                              ),

                            // ==================================
                            // MOBILE
                            // ==================================
                            if (_hasText(contact.mobilen))
                              _ContactInfoRow(
                                icon: Icons.smartphone_outlined,
                                label: 'Mobile',
                                value: contact.mobilen!,
                                actionIcon: Icons.call_rounded,
                                onTap: () {
                                  _openPhone(context, contact.mobilen!);
                                },
                              ),

                            // ==================================
                            // EMAIL
                            // ==================================
                            if (_hasText(contact.mail))
                              _ContactInfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: contact.mail!,
                                actionIcon: Icons.send_outlined,
                                onTap: () {
                                  _openEmail(context, contact.mail!);
                                },
                              ),

                            // ==================================
                            // DESCRIPTION
                            // ==================================
                            if (_hasText(contact.opis))
                              _ContactInfoRow(
                                icon: Icons.notes_outlined,
                                label: 'Description',
                                value: contact.opis!,
                                isLast: true,
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

  // ==========================================================
  // OPEN PHONE APP
  // ==========================================================

  Future<void> _openPhone(BuildContext context, String phoneNumber) async {
    final cleanedNumber = phoneNumber.trim();

    final uri = Uri(scheme: 'tel', path: cleanedNumber);

    try {
      final launched = await launchUrl(uri);

      if (!launched && context.mounted) {
        _showLaunchError(context, 'Could not open the phone app.');
      }
    } catch (_) {
      if (context.mounted) {
        _showLaunchError(context, 'Could not open the phone app.');
      }
    }
  }

  // ==========================================================
  // OPEN EMAIL APP
  // ==========================================================

  Future<void> _openEmail(BuildContext context, String email) async {
    final cleanedEmail = email.trim();

    final uri = Uri(scheme: 'mailto', path: cleanedEmail);

    try {
      final launched = await launchUrl(uri);

      if (!launched && context.mounted) {
        _showLaunchError(context, 'Could not open the email app.');
      }
    } catch (_) {
      if (context.mounted) {
        _showLaunchError(context, 'Could not open the email app.');
      }
    }
  }

  // ==========================================================
  // LAUNCH ERROR
  // ==========================================================

  void _showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  bool _hasAnyDetails({
    required String? tel,
    required String? mobilen,
    required String? mail,
    required String? opis,
  }) {
    return _hasText(tel) ||
        _hasText(mobilen) ||
        _hasText(mail) ||
        _hasText(opis);
  }

  String _getInitial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    return name.trim()[0].toUpperCase();
  }
}
// ============================================================
// CONTACT ID BADGE
// ============================================================

class _ContactIdBadge extends StatelessWidget {
  final int id;

  const _ContactIdBadge({required this.id});

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
// CONTACT INFORMATION ROW
// ============================================================

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  final IconData? actionIcon;
  final VoidCallback? onTap;

  final bool isLast;

  const _ContactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.actionIcon,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),

        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),

          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --------------------------------------------------
            // ICON
            // --------------------------------------------------

            Container(
              width: 36,
              height: 36,

              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),

              child: Icon(icon, size: 17, color: AppColors.primary),
            ),

            const SizedBox(width: 11),

            // --------------------------------------------------
            // LABEL + VALUE
            // --------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  SelectableText(
                    value.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // ACTION
            // --------------------------------------------------
            if (onTap != null) ...[
              const SizedBox(width: 8),

              Material(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      actionIcon ?? Icons.arrow_outward_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
