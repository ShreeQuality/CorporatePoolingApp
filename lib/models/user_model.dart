class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String userType; // 'corporate', 'public'
  final String? companyId;
  final bool isEmailVerified;
  final bool isDocumentVerified;
  final bool isDriverVerified;
  final int coinBalance;
  final double karmaScore;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.userType,
    this.companyId,
    required this.isEmailVerified,
    required this.isDocumentVerified,
    required this.isDriverVerified,
    required this.coinBalance,
    required this.karmaScore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      userType: json['user_type'] ?? 'public',
      companyId: json['company_id'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isDocumentVerified: json['is_document_verified'] ?? false,
      isDriverVerified: json['is_driver_verified'] ?? false,
      coinBalance: json['coin_balance'] ?? 0,
      karmaScore: (json['karma_score'] ?? 5.0).toDouble(),
    );
  }
}
