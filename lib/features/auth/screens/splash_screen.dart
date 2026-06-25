import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/extensions/context_ext.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/auth/screens/login_screen.dart';
import 'package:nawasena/features/home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.checkStoredSession();
    if (!mounted) return;

    if (authProvider.isAuth) {
      context.pushAndRemoveUntil(const HomeScreen());
    } else {
      context.pushAndRemoveUntil(const LoginScreen());
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -_slideAnim.value),
                  child: const MascotWidget(
                    pose: MascotPose.waving,
                    size: 180,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 24),
                Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: Column(
                    children: [
                      const Text(
                        'Nawasena',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sinau Budaya Jawa, Seru!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 32, height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
