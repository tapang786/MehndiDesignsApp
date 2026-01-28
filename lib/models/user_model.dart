class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String address;
  final String profileImage;
  final int roleId;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.address,
    required this.profileImage,
    required this.roleId,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      status: json['status'],
      address: json['address'] ?? "",
      profileImage: json['profile_image'],
      roleId: json['role_id'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'address': address,
      'profile_image': profileImage,
      'role_id': roleId,
      'role': role,
    };
  }
}
