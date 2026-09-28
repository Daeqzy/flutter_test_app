import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/partner_agreements/partner_agreements_bloc.dart';
import '../bloc/partner_agreements/partner_agreements_event.dart';
import '../bloc/partner_agreements/partner_agreements_state.dart';

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
      appBar: AppBar(title: Text(partnerName)),
      body: BlocBuilder<PartnerAgreementsBloc, PartnerAgreementsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () {
                context.read<PartnerAgreementsBloc>().add(
                  PartnerAgreementsRequested(tp: tp, p: p),
                );
              },
            );
          }

          if (state.agreements.isEmpty) {
            return _EmptyView(partnerName: partnerName);
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agreements',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.agreements.length} agreement${state.agreements.length == 1 ? '' : 's'} found',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PartnerAgreementsBloc>().add(
                      PartnerAgreementsRequested(tp: tp, p: p),
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: state.agreements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final agreement = state.agreements[index];

                      final status = agreement.status?.trim() ?? '';

                      return Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          agreement.dogovorBr ??
                                              'Unnamed agreement',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (agreement.broj != null) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            'Agreement #${agreement.broj}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (status.isNotEmpty)
                                    _StatusBadge(status: status),
                                ],
                              ),

                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),

                              if (_hasText(agreement.vidDogovorShow))
                                _AgreementInfoRow(
                                  icon: Icons.category_outlined,
                                  label: 'Type',
                                  value: agreement.vidDogovorShow!,
                                ),

                              if (_hasText(agreement.opis))
                                _AgreementInfoRow(
                                  icon: Icons.notes_outlined,
                                  label: 'Description',
                                  value: agreement.opis!,
                                ),

                              if (agreement.datumPotpis != null)
                                _AgreementInfoRow(
                                  icon: Icons.edit_calendar_outlined,
                                  label: 'Signed',
                                  value: _formatDate(agreement.datumPotpis!),
                                ),

                              if (agreement.datumOd != null)
                                _AgreementInfoRow(
                                  icon: Icons.play_circle_outline,
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

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return '$day.$month.$year';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toUpperCase();

    final bool isValid = normalized == 'ВАЖЕЧКИ';

    final color = isValid ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status.trim(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
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
                Icons.description_outlined,
                size: 38,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No agreements found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$partnerName currently has no agreement records.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

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
              'Unable to load agreements',
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
