class ProfileModel {
  final String id;
  final String name;
  final String phone;
  final String gender;
  final String address;
  final String dateOfBirth;
  final String imageUrl;
  final String? email;
  final String? mobile;
  final String? role;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.address,
    required this.dateOfBirth,
    required this.imageUrl,
    this.email,
    this.mobile,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? json['mobile'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      imageUrl: json['image_url'] ?? '',
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender,
      'address': address,
      'date_of_birth': dateOfBirth,
      'image_url': imageUrl,
      'email': email,
      'mobile': mobile,
    };
  }
}