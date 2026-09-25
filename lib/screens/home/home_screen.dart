import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';

import '../../bloc/partners/partners_bloc.dart';
import '../../bloc/partners/partners_event.dart';
import '../../bloc/partners/partners_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WELCOME SECTION
              const Text(
                'Welcome 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'What would you like to do today?',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 28),

              // QUICK ACTIONS
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 16),

              // FIRST ROW
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      icon: Icons.grid_view_rounded,
                      title: 'Services',
                      subtitle: 'View services',
                      onTap: () {
                        context.read<NavigationBloc>().add(
                          const NavigationTabChanged(1),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _DashboardCard(
                      icon: Icons.description_outlined,
                      title: 'Requests',
                      subtitle: 'Your requests',
                      onTap: () {
                        // Add functionality later.
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // SECOND ROW
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      icon: Icons.notifications_outlined,
                      title: 'Alerts',
                      subtitle: 'Notifications',
                      onTap: () {
                        context.read<NavigationBloc>().add(
                          const NavigationTabChanged(2),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _DashboardCard(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'Your account',
                      onTap: () {
                        context.read<NavigationBloc>().add(
                          const NavigationTabChanged(3),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // PARTNERS TITLE
              const Text(
                'Partners',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 14),

              // REAL PARTNERS FROM API
              BlocBuilder<PartnersBloc, PartnersState>(
                builder: (context, state) {
                  // LOADING
                  if (state.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // ERROR
                  if (state.errorMessage != null) {
                    return _PartnersError(
                      message: state.errorMessage!,
                      onRetry: () {
                        context.read<PartnersBloc>().add(
                          const PartnersRequested(),
                        );
                      },
                    );
                  }

                  // EMPTY
                  if (state.partners.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 38,
                            color: Color(0xFF94A3B8),
                          ),

                          SizedBox(height: 12),

                          Text(
                            'No partners found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // REAL PARTNER LIST
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.partners.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final partner = state.partners[index];

                      return _PartnerCard(
                        name: partner.naziv ?? 'Unnamed partner',
                        location: partner.mestoNaziv ?? 'Unknown location',
                        address: partner.adresa,
                        tpp: partner.tpp,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // RECENT ACTIVITY
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 38,
                      color: Color(0xFF94A3B8),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'No recent activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Your recent activity will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// PARTNER CARD
class _PartnerCard extends StatelessWidget {
  final String name;
  final String location;
  final String? address;
  final String? tpp;

  const _PartnerCard({
    required this.name,
    required this.location,
    this.address,
    this.tpp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.business_rounded, color: Color(0xFF2563EB)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),

                if (address != null && address!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Text(
                    address!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],

                if (tpp != null && tpp!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),

                  Text(
                    'TPP: $tpp',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PARTNERS ERROR CARD
class _PartnersError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PartnersError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: Color(0xFFDC2626),
          ),

          const SizedBox(height: 12),

          const Text(
            'Could not load partners',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// REUSABLE DASHBOARD CARD
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.circle, color: Colors.transparent),
              ),

              Transform.translate(
                offset: const Offset(11, -35),
                child: Icon(icon, size: 24, color: const Color(0xFF2563EB)),
              ),

              Transform.translate(
                offset: const Offset(0, -15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
