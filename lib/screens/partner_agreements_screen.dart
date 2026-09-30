import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/partner_agreements/partner_agreements_bloc.dart';
import '../bloc/partner_agreements/partner_agreements_event.dart';
import '../bloc/partner_agreements/partner_agreements_state.dart';

import '../theme/app_theme.dart';

import '../widgets/common/app_loading_view.dart';
import '../widgets/common/app_error_view.dart';
import '../widgets/common/app_empty_view.dart';
import '../widgets/common/app_summary_card.dart';
import '../widgets/common/app_info_row.dart';

class PartnerAgreementsScreen extends StatelessWidget {
  final int tp;
  final int p;
  final String partnerName;

  const PartnerAgreementsScreen({
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
              'Agreements',
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
                  context.read<PartnerAgreementsBloc>().add(
                    PartnerAgreementsRequested(tp: tp, p: p),
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
      body: BlocBuilder<PartnerAgreementsBloc, PartnerAgreementsState>(
        builder: (context, state) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (state.isLoading) {
            return const AppLoadingView(
              title: 'Loading agreements',
              message: 'Retrieving agreement records...',
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (state.errorMessage != null) {
            return AppErrorView(
              title: 'Unable to load agreements',
              message: state.errorMessage!,
              onRetry: () {
                context.read<PartnerAgreementsBloc>().add(
                  PartnerAgreementsRequested(tp: tp, p: p),
                );
              },
            );
          }

          // ----------------------------------------------------
          // EMPTY
          // ----------------------------------------------------

          if (state.agreements.isEmpty) {
            return AppEmptyView(
              icon: Icons.description_outlined,
              title: 'No agreements found',
              message: '$partnerName currently has no agreement records.',
            );
          }

          // ----------------------------------------------------
          // ACTIVE AGREEMENTS COUNT
          // ----------------------------------------------------

          final validCount = state.agreements.where((agreement) {
            return _isValidStatus(agreement.status);
          }).length;

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
                  icon: Icons.description_outlined,
                  title: 'Agreement records',
                  subtitle:
                      '${state.agreements.length} agreement${state.agreements.length == 1 ? '' : 's'} available',
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$validCount',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Valid',
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
              // AGREEMENTS LIST
              // ==================================================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PartnerAgreementsBloc>().add(
                      PartnerAgreementsRequested(tp: tp, p: p),
                    );
                  },

                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),

                    itemCount: state.agreements.length,

                    separatorBuilder: (_, __) => const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      final agreement = state.agreements[index];

                      final status = agreement.status?.trim() ?? '';

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
                            // HEADER
                            // ==================================

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Container(
                                  width: 50,
                                  height: 50,

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

                                    borderRadius: BorderRadius.circular(15),
                                  ),

                                  child: const Icon(
                                    Icons.description_outlined,
                                    size: 23,
                                    color: AppColors.primary,
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        agreement.dogovorBr ??
                                            'Unnamed agreement',

                                        maxLines: 2,

                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.3,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),

                                      if (agreement.broj != null) ...[
                                        const SizedBox(height: 6),

                                        _AgreementNumberBadge(
                                          number: agreement.broj!,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                if (status.isNotEmpty) ...[
                                  const SizedBox(width: 8),

                                  _StatusBadge(status: status),
                                ],
                              ],
                            ),

                            const SizedBox(height: 16),

                            const Divider(),

                            const SizedBox(height: 12),

                            // ==================================
                            // TYPE
                            // ==================================
                            if (_hasText(agreement.vidDogovorShow))
                              _AgreementInfoRow(
                                icon: Icons.category_outlined,
                                label: 'Type',
                                value: agreement.vidDogovorShow!,
                              ),

                            // ==================================
                            // DESCRIPTION
                            // ==================================
                            if (_hasText(agreement.opis))
                              _AgreementInfoRow(
                                icon: Icons.notes_outlined,
                                label: 'Description',
                                value: agreement.opis!,
                              ),

                            // ==================================
                            // DATES
                            // ==================================
                            if (agreement.datumPotpis != null)
                              _AgreementInfoRow(
                                icon: Icons.edit_calendar_outlined,
                                label: 'Signed',
                                value: _formatDate(agreement.datumPotpis!),
                              ),

                            if (agreement.datumOd != null)
                              _AgreementInfoRow(
                                icon: Icons.play_circle_outline_rounded,
                                label: 'From',
                                value: _formatDate(agreement.datumOd!),
                              ),

                            if (agreement.datumDo != null)
                              _AgreementInfoRow(
                                icon: Icons.event_available_outlined,
                                label: 'Until',
                                value: _formatDate(agreement.datumDo!),
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
  // HELPERS
  // ==========================================================

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static bool _isValidStatus(String? status) {
    final normalized = status?.trim().toUpperCase() ?? '';

    return normalized == 'ВАЖЕЧКИ';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year;

    return '$day.$month.$year';
  }
}

// ============================================================
// AGREEMENT NUMBER BADGE
// ============================================================

class _AgreementNumberBadge extends StatelessWidget {
  final Object number;

  const _AgreementNumberBadge({required this.number});

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

          Flexible(
            child: Text(
              '$number',

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
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
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toUpperCase();

    // IMPORTANT:
    // exact comparison because НЕВАЖЕЧКИ
    // also contains the word ВАЖЕЧКИ.
    final isValid = normalized == 'ВАЖЕЧКИ';

    final color = isValid ? AppColors.success : AppColors.error;

    return Container(
      constraints: const BoxConstraints(maxWidth: 110),

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

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

          Flexible(
            child: Text(
              status.trim(),

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AGREEMENT INFO ROW
// ============================================================

class _AgreementInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _AgreementInfoRow({
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
              width: 78,

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
