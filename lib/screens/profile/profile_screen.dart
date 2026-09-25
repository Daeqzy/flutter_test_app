import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/user/user_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              // TITLE
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Manage your account',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 28),

              // PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // PROFILE ICON
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFEFF6FF),
                      child: Icon(
                        Icons.person_rounded,
                        size: 34,
                        color: Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // PROFILE INFORMATION
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<UserBloc, UserState>(
                            buildWhen: (previous, current) =>
                                previous.authenticatedUsername !=
                                current.authenticatedUsername,
                            builder: (context, state) {
                              return Text(
                                state.authenticatedUsername.isNotEmpty
                                    ? state.authenticatedUsername
                                    : 'CODEX User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Account information',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 14),

              // LOGOUT
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.read<UserBloc>().add(const UserLogoutRequested());
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                        SizedBox(width: 14),
                        Text(
                          'Log out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
