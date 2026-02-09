import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user.
///
/// This is a pure Dart class with no JSON annotations.
/// Mapping from DTOs is handled by mappers in the data layer.
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Full display name
  String get fullName => '$firstName $lastName'.trim();

  /// Check if user has a complete profile
  bool get hasCompleteProfile => firstName.isNotEmpty && lastName.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'User($id, $email, $fullName)';
}

/// User role enumeration
enum UserRole {
  citizen,
  admin,
  officer,
  unknown;

  static UserRole fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'citizen' => UserRole.citizen,
      'admin' => UserRole.admin,
      'officer' => UserRole.officer,
      _ => UserRole.unknown,
    };
  }

  String toApiString() => name;
}
