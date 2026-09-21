import '../models/user.dart';

class UserDataSource {
  // Temporary in-memory fake database.
  final List<Map<String, dynamic>> _users = [
    {'ID': 1, 'USERNAME': 'admin', 'EMAIL': 'admin@example.com'},
    {'ID': 2, 'USERNAME': 'john', 'EMAIL': 'john@example.com'},
    {'ID': 3, 'USERNAME': 'maria', 'EMAIL': 'maria@example.com'},
  ];

  // Login operation
  Future<User> login(String username, String password) async {
    // Simulate waiting for the database.
    await Future.delayed(const Duration(seconds: 2));

    // Temporary fake login credentials.
    final Map<String, dynamic> databaseUser = {
      'ID': 1,
      'USERNAME': 'admin',
      'PASSWORD': '1234',
      'EMAIL': 'admin@example.com',
    };

    // Check username and password.
    if (username == databaseUser['USERNAME'] &&
        password == databaseUser['PASSWORD']) {
      return User.fromMap(databaseUser);
    }

    // Login failed.
    throw Exception('Invalid username or password');
  }

  // Get all users operation
  Future<List<User>> getUsers() async {
    // Simulate waiting for the database.
    await Future.delayed(const Duration(seconds: 2));

    // Convert database rows into User objects.
    return _users.map((row) => User.fromMap(row)).toList();
  }

  // Add a new user operation
  Future<void> addUser(String username, String email) async {
    // Simulate waiting for the database.
    await Future.delayed(const Duration(seconds: 1));

    // Create a new fake database row.
    final Map<String, dynamic> newUser = {
      'ID': _users.length + 1,
      'USERNAME': username,
      'EMAIL': email,
    };

    // Simulate INSERT into the database.
    _users.add(newUser);
  }
}
