class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String studentId;
  final String phoneNumber;
  final String? profilePicture;
  final String faculty;
  final String department;
  final String position;
  final bool isAdmin;
  final bool isStaff;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.phoneNumber,
    this.profilePicture,
    required this.faculty,
    required this.department,
    required this.position,
    required this.isAdmin,
    required this.isStaff,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      studentId: json['student_id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'],
      faculty: json['faculty'] ?? '',
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      isStaff: json['is_staff'] ?? false,
    );
  }
}
