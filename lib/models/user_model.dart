/// User Model
/// Aligned with Schema 014 (public.users) & SRS §3
class UserModel {
  final String id;
  final String fullName;
  final String? workEmail;
  final String? phoneNumber;
  final String role; // 'corporate_employee', 'company_manager', 'super_admin', 'public_user'
  final String gender;
  final String? companyId;
  final String? companyName;
  final String? buildingId;
  final bool workEmailVerified;
  final bool dlVerified;
  final String? dlNumber;
  final String? profilePhotoUrl;
  final String? officeIdPhotoUrl;
  final int trustScore;
  final bool isBanned;
  final double availableBalance;
  final double corporateGrantBalance;
  final List<dynamic>? emergencyContacts;
  final Map<String, dynamic>? corporateAttendance;

  UserModel({
    required this.id,
    required this.fullName,
    this.workEmail,
    this.phoneNumber,
    required this.role,
    this.gender = 'prefer_not_to_say',
    this.companyId,
    this.companyName,
    this.buildingId,
    this.workEmailVerified = false,
    this.dlVerified = false,
    this.dlNumber,
    this.profilePhotoUrl,
    this.officeIdPhotoUrl,
    this.trustScore = 50,
    this.isBanned = false,
    this.availableBalance = 0.0,
    this.corporateGrantBalance = 0.0,
    this.emergencyContacts,
    this.corporateAttendance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final company = json['companies'] as Map<String, dynamic>?;
    final wallet = json['wallets'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      workEmail: json['work_email'] ?? json['email'],
      phoneNumber: json['phone_number'] ?? json['phone'],
      role: json['role'] ?? json['user_type'] ?? 'public_user',
      gender: json['gender'] ?? 'prefer_not_to_say',
      companyId: json['company_id'],
      companyName: company?['name'] ?? json['company_name'],
      buildingId: json['building_id'],
      workEmailVerified: json['work_email_verified'] ?? json['is_email_verified'] ?? false,
      dlVerified: json['dl_verified'] ?? json['is_driver_verified'] ?? false,
      dlNumber: json['dl_number'],
      profilePhotoUrl: json['profile_photo_url'] ?? json['photo_url'],
      officeIdPhotoUrl: json['office_id_photo_url'],
      trustScore: json['trust_score'] ?? json['karma_score'] ?? 50,
      isBanned: json['is_banned'] ?? false,
      availableBalance: (wallet?['available_balance'] ?? json['coin_balance'] ?? 0.0).toDouble(),
      corporateGrantBalance: (wallet?['corporate_grant_balance'] ?? 0.0).toDouble(),
      emergencyContacts: json['emergency_contacts'] as List<dynamic>?,
      corporateAttendance: json['corporate_attendance'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'work_email': workEmail,
      'phone_number': phoneNumber,
      'role': role,
      'gender': gender,
      'company_id': companyId,
      'company_name': companyName,
      'building_id': buildingId,
      'work_email_verified': workEmailVerified,
      'dl_verified': dlVerified,
      'dl_number': dlNumber,
      'profile_photo_url': profilePhotoUrl,
      'office_id_photo_url': officeIdPhotoUrl,
      'trust_score': trustScore,
      'is_banned': isBanned,
      'available_balance': availableBalance,
      'corporate_grant_balance': corporateGrantBalance,
      'emergency_contacts': emergencyContacts,
      'corporate_attendance': corporateAttendance,
    };
  }

  bool get isCorporate => role == 'corporate_employee';
  bool get isCompanyManager => role == 'company_manager';
  bool get isSuperAdmin => role == 'super_admin';
}
