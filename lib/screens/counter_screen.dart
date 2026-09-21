import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/counter/counter_bloc.dart';
import '../bloc/counter/counter_event.dart';
import '../bloc/counter/counter_state.dart';

import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // --------------------
              // COUNTER
              // --------------------
              BlocBuilder<CounterBloc, CounterState>(
                builder: (context, state) {
                  return Text(
                    '${state.counter}',
                    style: const TextStyle(fontSize: 40),
                  );
                },
              ),

              const SizedBox(height: 30),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<CounterBloc>().add(
                        CounterDecrementPressed(),
                      );
                    },
                    child: const Text('-'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CounterBloc>().add(
                        CounterIncrementPressed(),
                      );
                    },
                    child: const Text('+'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CounterBloc>().add(CounterResetPressed());
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              const Divider(),

              const SizedBox(height: 30),

              // --------------------
              // ADD USER
              // --------------------
              const Text(
                'Add User',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: () {
                  final username = _usernameController.text.trim();

                  final email = _emailController.text.trim();

                  if (username.isEmpty || email.isEmpty) {
                    return;
                  }

                  context.read<UserBloc>().add(
                    AddUserRequested(username: username, email: email),
                  );

                  _usernameController.clear();
                  _emailController.clear();
                },
                child: const Text('Add User'),
              ),

              const SizedBox(height: 40),

              const Divider(),

              const SizedBox(height: 30),

              // --------------------
              // USERS
              // --------------------
              const Text(
                'Users',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  context.read<UserBloc>().add(const GetUsersRequested());
                },
                child: const Text('Load Users'),
              ),

              const SizedBox(height: 20),

              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.errorMessage != null) {
                    return Text(state.errorMessage!);
                  }

                  if (state.users.isEmpty) {
                    return const Text('No users loaded.');
                  }

                  return Column(
                    children: state.users.map((user) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '${user.username} - ${user.email}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
