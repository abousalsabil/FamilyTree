enum UserRole { member, moderator, admin }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? linkedMemberId;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.member,
    this.linkedMemberId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.member,
      ),
      linkedMemberId: json['linkedMemberId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'linkedMemberId': linkedMemberId,
    };
  }
}
