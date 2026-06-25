import 'dart:convert';

/// Model user yang merepresentasikan data dari API endpoint /auth/me
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  // Gamifikasi
  final int xpTotal;
  final int coins;
  final int diamonds;
  final int streakCount;

  // ── Heart Stamina System ────────────────────────────────────────────────
  // heartPoints (0-100) adalah sumber kebenaran, dipakai untuk menggambar
  // bar isi tiap hati di HeartStaminaBar. hasInfiniteHearts = true berarti
  // user Premium — stamina tidak pernah berkurang ("Infinite Hearts").
  final int heartPoints;
  final bool hasInfiniteHearts;

  // Premium
  final bool isPremium;
  final String? premiumValidUntil;

  // Flags
  final bool isGoogleAccount;
  final bool isB2b;

  // Institusi (B2B)
  final InstitutionInfo? institution;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.xpTotal,
    required this.coins,
    required this.diamonds,
    required this.streakCount,
    required this.heartPoints,
    required this.hasInfiniteHearts,
    required this.isPremium,
    this.premiumValidUntil,
    required this.isGoogleAccount,
    required this.isB2b,
    this.institution,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:                 (json['id'] as num?)?.toInt()           ?? 0,
      name:               json['name']           as String?       ?? '',
      email:              json['email']          as String?       ?? '',
      role:               json['role']           as String?       ?? 'general_user',
      avatarUrl:          json['avatar_url']     as String?,
      xpTotal:            (json['xp_total']      as num?)?.toInt() ?? 0,
      coins:              (json['coins']         as num?)?.toInt() ?? 0,
      diamonds:           (json['diamonds']      as num?)?.toInt() ?? 0,
      streakCount:        (json['streak_count']  as num?)?.toInt() ?? 0,
      heartPoints:        (json['heart_points']  as num?)?.toInt() ?? 100,
      hasInfiniteHearts:  json['has_infinite_hearts'] as bool?    ?? false,
      isPremium:          json['is_premium']     as bool?         ?? false,
      premiumValidUntil:  json['premium_valid_until'] as String?,
      isGoogleAccount:    json['is_google_account']  as bool?     ?? false,
      isB2b:              json['is_b2b']         as bool?         ?? false,
      institution: json['institution'] != null
          ? InstitutionInfo.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'role': role,
    'avatar_url': avatarUrl, 'xp_total': xpTotal, 'coins': coins,
    'diamonds': diamonds, 'streak_count': streakCount,
    'heart_points': heartPoints, 'has_infinite_hearts': hasInfiniteHearts,
    'is_premium': isPremium, 'premium_valid_until': premiumValidUntil,
    'is_google_account': isGoogleAccount, 'is_b2b': isB2b,
    'institution': institution?.toJson(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonString) =>
      UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  UserModel copyWith({
    String? name, String? avatarUrl, int? xpTotal,
    int? coins, int? diamonds, int? streakCount,
    int? heartPoints, bool? hasInfiniteHearts,
  }) => UserModel(
    id: id, email: email, role: role,
    name: name ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    xpTotal: xpTotal ?? this.xpTotal,
    coins: coins ?? this.coins,
    diamonds: diamonds ?? this.diamonds,
    streakCount: streakCount ?? this.streakCount,
    heartPoints: heartPoints ?? this.heartPoints,
    hasInfiniteHearts: hasInfiniteHearts ?? this.hasInfiniteHearts,
    isPremium: isPremium,
    premiumValidUntil: premiumValidUntil,
    isGoogleAccount: isGoogleAccount,
    isB2b: isB2b,
    institution: institution,
  );

  /// Jumlah ikon hati untuk tampilan teks ringkas (0-5), dibulatkan ke atas.
  /// Bar isi sesungguhnya tetap pakai [heartPoints] via HeartStaminaBar.
  int get heartsDisplay => hasInfiniteHearts
      ? 5
      : (heartPoints / 20).ceil().clamp(0, 5);

  /// Apakah stamina benar-benar habis (0 poin) dan BUKAN premium?
  bool get isOutOfStamina => !hasInfiniteHearts && heartPoints <= 0;

  bool get isTeacher     => role == 'teacher';
  bool get isStudent     => role == 'student';
  bool get isSchoolAdmin => role == 'school_admin';
  bool get isSuperAdmin  => role == 'superadmin';
  bool get isGeneralUser => role == 'general_user';
}

class InstitutionInfo {
  final int id;
  final String name;
  final String planTier;

  const InstitutionInfo({required this.id, required this.name, required this.planTier});

  factory InstitutionInfo.fromJson(Map<String, dynamic> json) => InstitutionInfo(
    id:       (json['id'] as num?)?.toInt() ?? 0,
    name:     json['name']     as String?   ?? '',
    planTier: json['plan_tier'] as String?  ?? 'free',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'plan_tier': planTier};
}
