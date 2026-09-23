import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';

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

              // QUICK ACTIONS TITLE
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

// Reusable dashboard card
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

              // Position icon over styled container
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
