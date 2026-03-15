enum UserRole {
  penjaga,
  pengecek,
}

class AppUser {
  final String id;
  final String name;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.index,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        role: UserRole.values[json['role'] ?? 0],
      );
}
