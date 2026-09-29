import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';

import '../../bloc/partners/partners_bloc.dart';
import '../../bloc/partners/partners_event.dart';

import '../../repositories/data_repository.dart';

import 'partners_screen.dart';

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
                // --------------------------------------------
                // SERVICES
                // --------------------------------------------

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

                // --------------------------------------------
                // NOTIFICATIONS
                // --------------------------------------------
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
                // --------------------------------------------
                // PARTNERS
                // --------------------------------------------

                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.business_outlined,
                    title: 'Partners',
                    onTap: () {
                      final repository = context.read<DataRepository>();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                PartnersBloc(repository)
                                  ..add(const PartnersRequested()),
                            child: const PartnersScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // --------------------------------------------
                // PROFILE
                // --------------------------------------------
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
            // DASHBOARD INFO
            // ------------------------------------------------
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.dashboard_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CODEX Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Use the quick actions above to access application features.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
