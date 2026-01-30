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
  final String? bio;
  final String? profession;
  final String? gender;
  final String? dob;

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
    this.bio,
    this.profession,
    this.gender,
    this.dob,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      status: json['status']?.toString() ?? "0",
      address: json['address'] ?? "",
      profileImage: json['image'] ?? json['profile_image'] ?? "",
      roleId: json['role_id'] ?? 0,
      role: json['role'] ?? "",
      bio: json['bio'],
      profession: json['profession'],
      gender: json['gender'],
      dob: json['dob']?.toString(),
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
      'bio': bio,
      'profession': profession,
      'gender': gender,
      'dob': dob,
    };
  }
}
