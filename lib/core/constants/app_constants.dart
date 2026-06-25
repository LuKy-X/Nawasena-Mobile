class AppConstants {
  AppConstants._();

  static const String appName       = 'Nawasena';
  // Emulator Android: 10.0.2.2 | Device fisik: IP laptop (contoh: 192.168.1.x)
  // Production: https://api.nawasena.id
  static const String baseUrl       = 'http://10.0.2.2:8000/api';

  // Token storage key
  static const String tokenKey      = 'nawasena_access_token';
  static const String userKey       = 'nawasena_user_data';

  // Aset maskot — taruh file PNG di assets/mascots/
  static const String mascotWaving      = 'assets/mascots/mascot_selamat_datang.png';
  static const String mascotThinking    = 'assets/mascots/mascot_ada_ide.png';
  static const String mascotCelebrating = 'assets/mascots/mascot_selesai.png';
  static const String mascotSearching   = 'assets/mascots/mascot_ditemukan.png';
  static const String mascotReading     = 'assets/mascots/mascot_membaca.png';
  static const String mascotPointing    = 'assets/mascots/mascot_ikuti.png';

  // Fallback avatar
  static const String avatarPlaceholder =
      'https://lh3.googleusercontent.com/a/default-user=s96-c';

  // Google SSO — WEB CLIENT ID dari Google Console
  // (Sama dengan serverClientId di flutter dan GOOGLE_CLIENT_ID di Laravel .env)
  static const String googleWebClientId =
      '427236973627-l9pe2ccanbgn2eqiobdbailm8bprrhi0.apps.googleusercontent.com';

  // Durasi animasi
  static const Duration bounceDuration   = Duration(milliseconds: 120);
  static const Duration transitionDuration = Duration(milliseconds: 280);
  static const Duration snackbarDuration = Duration(seconds: 3);
}
