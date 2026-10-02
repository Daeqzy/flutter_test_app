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
import '../widgets/common/app_status_badge.dart';

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
              'Agreements',

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
                  context.read<PartnerAgreementsBloc>().add(
                    PartnerAgreementsRequested(tp: tp, p: p),
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
          // VALID AGREEMENTS COUNT
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
                      '${state.agreements.length} '
                      'agreement${state.agreements.length == 1 ? '' : 's'} '
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
                                    Icons.description_outlined,
                                    size: 23,
                                    color: colors.primary,
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

                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.3,
                                          fontWeight: FontWeight.w700,
                                          color: colors.onSurface,
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

                                  AppStatusBadge(
                                    text: status,

                                    color: _isValidStatus(status)
                                        ? AppColors.success
                                        : AppColors.error,

                                    showDot: true,
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 16),

                            Divider(color: colors.outlineVariant),

                            const SizedBox(height: 12),

                            // ==================================
                            // TYPE
                            // ==================================
                            if (_hasText(agreement.vidDogovorShow))
                              AppInfoRow(
                                icon: Icons.category_outlined,
                                label: 'Type',
                                value: agreement.vidDogovorShow!,
                              ),

                            // ==================================
                            // DESCRIPTION
                            // ==================================
                            if (_hasText(agreement.opis))
                              AppInfoRow(
                                icon: Icons.notes_outlined,
                                label: 'Description',
                                value: agreement.opis!,
                              ),

                            // ==================================
                            // DATES
                            // ==================================
                            if (agreement.datumPotpis != null)
                              AppInfoRow(
                                icon: Icons.edit_calendar_outlined,
                                label: 'Signed',
                                value: _formatDate(agreement.datumPotpis!),
                              ),

                            if (agreement.datumOd != null)
                              AppInfoRow(
                                icon: Icons.play_circle_outline_rounded,
                                label: 'From',
                                value: _formatDate(agreement.datumOd!),
                              ),

                            if (agreement.datumDo != null)
                              AppInfoRow(
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

          Flexible(
            child: Text(
              '$number',

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
