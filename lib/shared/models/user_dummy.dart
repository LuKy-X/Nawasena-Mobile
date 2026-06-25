class UserDummy {
  final String name;
  final String email;
  final String avatarUrl;
  final int streak;
  final int hearts;
  final int diamonds;
  final int xp;
  final bool isPremium;

  const UserDummy({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.streak,
    required this.hearts,
    required this.diamonds,
    required this.xp,
    required this.isPremium,
  });

  static const UserDummy currentUser = UserDummy(
    name: 'Raden Adjie',
    email: 'adjie@nawasena.id',
    avatarUrl: 'https://lh3.googleusercontent.com/a/default-user=s96-c',
    streak: 12,
    hearts: 4,
    diamonds: 85,
    xp: 1250,
    isPremium: false,
  );
}