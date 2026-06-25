import 'package:flutter/material.dart';
import 'package:nawasena/features/auth/screens/login_screen.dart';
import 'package:nawasena/features/auth/screens/register_screen.dart';
import 'package:nawasena/features/auth/screens/splash_screen.dart';
import 'package:nawasena/features/home/screens/home_screen.dart';

/// Konstanta nama route.
/// Navigasi push-named digunakan untuk halaman top-level.
/// Navigasi push(MaterialPageRoute) digunakan untuk sub-halaman per fitur.
class AppRoutes {
  AppRoutes._();

  static const String splash   = '/';
  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash:   (_) => const SplashScreen(),
    login:    (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home:     (_) => const HomeScreen(),
  };

  /// Page-transition yang halus untuk semua route
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder == null) {
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings,
      );
    }
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
