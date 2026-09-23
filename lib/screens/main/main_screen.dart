import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';
import '../../bloc/navigation/navigation_state.dart';

import '../home/home_screen.dart';
import '../services/services_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeScreen(),
      ServicesScreen(),
      NotificationsScreen(),
      ProfileScreen(),
    ];

    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('CODEX Computers')),

            body: pages[state.selectedIndex],

            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: GNav(
                    selectedIndex: state.selectedIndex,

                    gap: 8,
                    iconSize: 24,

                    color: const Color(0xFF64748B),
                    activeColor: const Color(0xFF2563EB),

                    tabBackgroundColor: const Color(0xFF2563EB)
                        .withValues(alpha: 0.10),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    duration: const Duration(milliseconds: 350),

                    tabs: const [
                      GButton(icon: Icons.home_outlined, text: 'Home'),
                      GButton(icon: Icons.grid_view_rounded, text: 'Services'),
                      GButton(
                        icon: Icons.notifications_outlined,
                        text: 'Notifications',
                      ),
                      GButton(icon: Icons.person_outline, text: 'Profile'),
                    ],

                    onTabChange: (index) {
                      context.read<NavigationBloc>().add(
                        NavigationTabChanged(index),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
