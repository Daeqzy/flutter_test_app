import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/partner_contacts/partner_contacts_bloc.dart';
import '../bloc/partner_contacts/partner_contacts_event.dart';
import '../bloc/partner_contacts/partner_contacts_state.dart';

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
      appBar: AppBar(title: Text(partnerName)),

      body: BlocBuilder<PartnerContactsBloc, PartnerContactsState>(
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
                context.read<PartnerContactsBloc>().add(
                  PartnerContactsRequested(tp: tp, p: p),
                );
              },
            );
          }

          // ------------------------------------------------
          // EMPTY
          // ------------------------------------------------

          if (state.contacts.isEmpty) {
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
                      'Contacts',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${state.contacts.length} '
                      'contact${state.contacts.length == 1 ? '' : 's'} found',

                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------
              // CONTACT LIST
              // --------------------------------------------
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PartnerContactsBloc>().add(
                      PartnerContactsRequested(tp: tp, p: p),
                    );
                  },

                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),

                    itemCount: state.contacts.length,

                    separatorBuilder: (_, __) => const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      final contact = state.contacts[index];

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
                              // CONTACT HEADER
                              // ----------------------------

                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,

                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,

                                      borderRadius: BorderRadius.circular(14),
                                    ),

                                    child: Center(
                                      child: Text(
                                        _getInitial(contact.naziv),

                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          contact.naziv ?? 'Unnamed contact',

                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        if (contact.id != null) ...[
                                          const SizedBox(height: 3),

                                          Text(
                                            'Contact #${contact.id}',

                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const Icon(Icons.person_outline_rounded),
                                ],
                              ),

                              // ----------------------------
                              // DIVIDER
                              // ----------------------------
                              if (_hasAnyDetails(
                                tel: contact.tel,
                                mobilen: contact.mobilen,
                                mail: contact.mail,
                                opis: contact.opis,
                              )) ...[
                                const SizedBox(height: 16),

                                const Divider(),

                                const SizedBox(height: 8),
                              ],

                              // ----------------------------
                              // PHONE
                              // ----------------------------
                              if (_hasText(contact.tel))
                                _ContactInfoRow(
                                  icon: Icons.phone_outlined,

                                  label: 'Phone',

                                  value: contact.tel!,

                                  onTap: () {
                                    _openPhone(context, contact.tel!);
                                  },
                                ),

                              // ----------------------------
                              // MOBILE
                              // ----------------------------
                              if (_hasText(contact.mobilen))
                                _ContactInfoRow(
                                  icon: Icons.smartphone_outlined,

                                  label: 'Mobile',

                                  value: contact.mobilen!,

                                  onTap: () {
                                    _openPhone(context, contact.mobilen!);
                                  },
                                ),

                              // ----------------------------
                              // EMAIL
                              // ----------------------------
                              if (_hasText(contact.mail))
                                _ContactInfoRow(
                                  icon: Icons.email_outlined,

                                  label: 'Email',

                                  value: contact.mail!,

                                  onTap: () {
                                    _openEmail(context, contact.mail!);
                                  },
                                ),

                              // ----------------------------
                              // DESCRIPTION
                              // ----------------------------
                              if (_hasText(contact.opis))
                                _ContactInfoRow(
                                  icon: Icons.notes_outlined,

                                  label: 'Description',

                                  value: contact.opis!,

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

  // ----------------------------------------------------------
  // OPEN PHONE APP
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // OPEN EMAIL APP
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // LAUNCH ERROR
  // ----------------------------------------------------------

  void _showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------

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

// ----------------------------------------------------------
// CONTACT INFORMATION ROW
// ----------------------------------------------------------

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  final VoidCallback? onTap;

  const _ContactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // ------------------------------------------------
          // ICON / ACTION
          // ------------------------------------------------

          if (onTap != null)
            IconButton(
              tooltip: label,

              onPressed: onTap,

              icon: Icon(icon, size: 21),

              color: Theme.of(context).colorScheme.primary,

              padding: EdgeInsets.zero,

              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            SizedBox(
              width: 32,
              height: 32,

              child: Icon(icon, size: 19, color: Colors.grey.shade600),
            ),

          const SizedBox(width: 8),

          // ------------------------------------------------
          // LABEL
          // ------------------------------------------------
          SizedBox(
            width: 85,

            child: Text(
              label,

              style: TextStyle(
                color: Colors.grey.shade600,

                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ------------------------------------------------
          // VALUE
          // ------------------------------------------------
          Expanded(
            child: SelectableText(
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
                Icons.people_outline_rounded,

                size: 38,

                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No contacts found',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '$partnerName currently has no contact records.',

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
              'Unable to load contacts',

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
