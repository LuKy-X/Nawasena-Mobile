import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/extensions/context_ext.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/core/widgets/nawasena_button.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/auth/screens/register_screen.dart';
import 'package:nawasena/features/auth/widgets/auth_text_field.dart';
import 'package:nawasena/features/home/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      context.pushAndRemoveUntil(const HomeScreen());
    } else {
      context.showSnack(auth.errorMessage ?? 'Login gagal.', isError: true);
      auth.clearError();
    }
  }

  Future<void> _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      context.pushAndRemoveUntil(const HomeScreen());
    } else if (auth.errorMessage != null) {
      context.showSnack(auth.errorMessage!, isError: true);
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ── Maskot + Judul ──────────────────────────────────────
                  const MascotWidget(
                    pose: MascotPose.waving,
                    size: 140,
                    animate: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sugeng Rawuh!',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Masuk untuk melanjutkan belajar',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Form Login ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            controller:  _emailCtrl,
                            hint:        'Email kamu',
                            prefixIcon:  Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                              if (!v.contains('@')) return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            controller:       _passCtrl,
                            hint:             'Password kamu',
                            prefixIcon:       Icons.lock_outline,
                            isPassword:       true,
                            textInputAction:  TextInputAction.done,
                            onEditingComplete: _login,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => NawasenaButton(
                              label:     'Masuk',
                              onPressed: auth.isLoading ? null : _login,
                              isLoading: auth.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Divider "atau" ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'atau',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Google SSO ──────────────────────────────────────────
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => GoogleSignInButton(
                      onPressed: auth.isLoading ? null : _googleLogin,
                      isLoading: auth.isLoading,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Link Daftar ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.mediumText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(const RegisterScreen()),
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
