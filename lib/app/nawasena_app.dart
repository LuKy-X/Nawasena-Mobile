import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/routes.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/home/providers/home_provider.dart';
import 'package:nawasena/features/leaderboard/providers/leaderboard_provider.dart';
import 'package:nawasena/features/profile/providers/profile_provider.dart';
import 'package:nawasena/features/shop/providers/shop_provider.dart';

/// Root widget aplikasi Nawasena.
///
/// Menggunakan MultiProvider agar semua Provider tersedia di seluruh widget tree.
///
/// Arsitektur Provider:
///   AuthProvider       — state autentikasi global (user login, token)
///   HomeProvider       — data courses & learning path
///   LeaderboardProvider — data papan peringkat mingguan
///   ShopProvider       — data toko virtual & saldo
///   ProfileProvider    — state update profil
///
/// Semua Provider di-mount di root (bukan lazy) karena:
/// - AuthProvider perlu ada sejak splash screen
/// - Provider lain diinisialisasi lazy secara default oleh library Provider
///   (hanya di-instantiate saat pertama kali di-read/watch)
class NawasenaApp extends StatelessWidget {
  const NawasenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth — global, harus selalu tersedia
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Feature providers — lazy, dibuat saat pertama kali diakses
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const _App(),
    );
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    // Lock orientasi ke portrait (umum untuk edu-app mobile)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Style status bar — transparent agar konten bisa di bawahnya
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title:                    'Nawasena',
      debugShowCheckedModeBanner: false,
      theme:                    AppTheme.lightTheme,
      initialRoute:             AppRoutes.splash,
      onGenerateRoute:          AppRoutes.onGenerateRoute,
    );
  }
}
