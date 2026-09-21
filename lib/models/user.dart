class User {
  final int id;
  final String username;
  final String email;

  const User({required this.id, required this.username, required this.email});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['ID'] as int,
      username: map['USERNAME'] as String,
      email: map['EMAIL'] as String,
    );
  }
}
